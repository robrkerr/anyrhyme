require 'ar_helper'

class Seeder
  def initialize output=true
    @output = output
  end

  def clear_phonemes
    Phoneme.delete_all
  end

  def seed_phonemes phonemes
    Phoneme.create!(phonemes)
  end

  def clear_words
    Spelling.delete_all
    Word.delete_all
    Pronunciation.delete_all
    Syllable.delete_all
    Segment.delete_all
    SegmentPhoneme.delete_all
  end

  def seed_words words, source
    spellings = words.map { |w| w[:name]}
    spelling_to_id = populate_spellings spellings
    pronunciation_labels = words.map { |w| get_pronunciation_label(w[:syllables]) }
    pronunciation_to_id, new_pronunciation_to_id = populate_pronunciations pronunciation_labels
    populate_words spellings, pronunciation_labels, spelling_to_id, pronunciation_to_id, source
    segments = get_all_syllable_segments(words.map { |w| w[:syllables]}.flatten)
    segment_type_and_label_to_id = populate_segments segments
    pronunciation_syllables = words.map { |w| w[:syllables] }
    populate_syllables pronunciation_syllables, new_pronunciation_to_id, segment_type_and_label_to_id
  end

  def clear_lexemes
    Lexeme.delete_all
    WordLexeme.delete_all
  end

  def seed_lexemes word_lexemes, source
    all_lexemes = []
    max_id = Lexeme.select("max(entry_id)").first.attributes["max"].to_i
    word_lexemes.each { |spelling,lexemes| lexemes.each { |lexeme| 
        all_lexemes << [spelling, lexeme[:entry_id] + max_id + 1,
                          lexeme[:word_class], lexeme[:gloss]]
    } }
    lexeme_to_id = populate_lexemes all_lexemes
    populate_word_lexemes all_lexemes, lexeme_to_id, source
  end

  def seed_extra_word_lexemes word_relations, source
    add_extra_word_lexemes word_relations, source
  end  

  private

  def populate_spellings spellings
    columns = [:label]
    already_existing = ArHelper.new.find_ids_with_single_column Spelling, columns[0], spellings
    values_to_insert = spellings.map { |spelling| [spelling] unless already_existing.has_key?(spelling) }.compact
    Spelling.transaction do
      Spelling.import columns, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_single_column Spelling, columns[0], values_to_insert.map { |val| val[0] }
    already_existing.merge(new_records)
  end

  def populate_pronunciations labels
    columns = [:label]
    already_existing = ArHelper.new.find_ids_with_single_column Pronunciation, columns[0], labels
    values_to_insert = labels.map { |label| [label] unless already_existing.has_key?(label) }.compact
    Pronunciation.transaction do
      Pronunciation.import columns, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_single_column Pronunciation, columns[0], values_to_insert.map { |val| val[0] }
    return already_existing.merge(new_records), new_records
  end

  def populate_words spellings, labels, spelling_to_id, pronunciation_to_id, source
    columns = [:spelling_id, :pronunciation_id, :source]
    ids = spellings.zip(labels).map { |sp,lab| [spelling_to_id[sp], pronunciation_to_id[lab]] }
    already_existing = ArHelper.new.find_ids_with_multiple_columns Word, columns[0..1], ids
    values_to_insert = ids.map { |id| [id[0],id[1],source] unless already_existing.has_key?(id) }.compact
    Word.transaction do
      Word.import columns, values_to_insert.uniq, :validate => false
    end
  end

  def populate_segments segments
    columns = [:segment_type,:label]
    already_existing = ArHelper.new.find_ids_with_multiple_columns Segment, columns[0..1], segments
    values_to_insert = segments.reject { |segment| already_existing.has_key?(segment) }
    Segment.transaction do
      Segment.import columns, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_multiple_columns Segment, columns[0..1], values_to_insert.map { |v| v[0..1] }
    segment_type_and_label_to_id = already_existing.merge(new_records)
    phoneme_name_to_id = get_phoneme_name_to_id_hash
    columns = [:segment_id,:phoneme_id]
    values_to_insert = []
    new_records.each { |(_,label),segment_id|
      ph_ids = label.split("-").map { |ph| phoneme_name_to_id[ph] }
      ph_ids.each { |ph_id| values_to_insert << [segment_id,ph_id] }
    }
    SegmentPhoneme.transaction do
      SegmentPhoneme.import columns, values_to_insert.uniq, :validate => false
    end
    segment_type_and_label_to_id
  end

  def populate_syllables pronunciation_syllables, pronunciation_to_id, segment_type_and_label_to_id
    columns = [:pronunciation_id,:position,:r_position,
                    :onset_id,:nucleus_id,:coda_id,:stress,:label]
    values_to_insert = []
    pronunciation_syllables.each { |syllables| 
      pronunciation_id = pronunciation_to_id[get_pronunciation_label(syllables)]
      if pronunciation_id
        syllables.each_with_index { |s,i| 
          r_i = syllables.length-i-1
          onset_id = segment_type_and_label_to_id[[0,get_segment_label(s[:onset])]]
          nucleus_id = segment_type_and_label_to_id[[1,get_segment_label(s[:nucleus])]]
          coda_id = segment_type_and_label_to_id[[2,get_segment_label(s[:coda])]]
          label = get_syllable_label(s)
          values_to_insert << [pronunciation_id,i,r_i,onset_id,nucleus_id,coda_id,s[:stress],label]
        }
      end
    }
    Syllable.transaction do
      Syllable.import columns, values_to_insert.uniq, :validate => false
    end
  end

  def populate_lexemes lexemes
    columns = [:entry_id,:word_class,:gloss]
    lexeme_entries = lexemes.map { |lex| lex[1..3]}
    already_existing = ArHelper.new.find_ids_with_single_column Lexeme, columns[0], lexeme_entries.map { |lex| lex[0] }
    values_to_insert = lexeme_entries.reject { |entry| already_existing.has_key?(entry[0]) }
    Lexeme.transaction do
      Lexeme.import columns.dup, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_single_column Lexeme, columns[0], values_to_insert.map { |v| v[0] }
    already_existing.merge(new_records)
  end

  def populate_word_lexemes lexemes, lexeme_to_id, source
    spellings = lexemes.map { |lex| lex[0]}
    spelling_to_id = ArHelper.new.find_ids_with_single_column Spelling, :label, spellings
    columns = [:word_id, :lexeme_id, :source]
    id_pairs = []
    lexemes.each { |spelling,entry_id,word_class,gloss|
      if spelling_to_id[spelling]
        Spelling.find(spelling_to_id[spelling]).words.each { |word| 
          id_pairs << [word.id, lexeme_to_id[entry_id]]
        }
      end
    }
    already_existing = ArHelper.new.find_ids_with_multiple_columns WordLexeme, columns[0..1], id_pairs
    values_to_insert = id_pairs.reject { |id_pair| already_existing.has_key?(id_pair) }.uniq.map { |v| v << source }
    WordLexeme.transaction do
      WordLexeme.import columns, values_to_insert, :validate => false
    end
  end

  def add_extra_word_lexemes word_relations, source
    words = word_relations.flatten(2).map { |w| [w] }
    _, words_hash = partition_new_and_existing Word, [:name], words, words
    columns = [:word_id, :lexeme_id, :source]
    values = []
    word_relations.each { |base_word,related_words|
      lex_ids = WordLexeme.where(:word_id => words_hash[[base_word]].id)
                          .map(&:lexeme_id)
      related_words.each { |related_word|
        lex_ids.each { |lex_id|
          values << [words_hash[[related_word]].id, lex_id]
        }
      }
    }
    WordLexeme.transaction do
      WordLexeme.import columns, values.map { |v| v << source; v}.uniq, :validate => false
    end
  end

  def get_phoneme_name_to_id_hash
    hash = Phoneme.all.group_by { |ph| ph.name }
    hash.each_key { |name| hash[name] = hash[name].first.id }
    hash
  end

  def get_pronunciation_label syllables
    syllables.map { |s| get_syllable_label(s) }.join("-")
  end

  def get_syllable_label s
    [s[:onset], s[:nucleus].first + s[:stress].to_s, s[:coda]].flatten.join("-")
  end

  def get_segment_label segment
    segment.join("-")
  end

  def partition_new_and_existing table, fields, all_value_sets, entries
    new_entries = []; existing = {}
    

    ### how to do this better??!!!

    existing = Hash[table.all.map { |row|
      key = fields.map { |field| row.attributes[field.to_s] }
      all_value_sets.include?(key) ? [key,row] : nil
    }.compact]
    new_entries = all_value_sets.zip(entries).map { |values, entry| 
      existing.has_key?(values) ? nil : entry
    }.compact
    return new_entries, existing
  end

  def get_all_syllable_segments syllables
    segments = []
    syllables.each { |s| 
      segments << [0,get_segment_label(s[:onset])]
      segments << [1,get_segment_label(s[:nucleus])]
      segments << [2,get_segment_label(s[:coda])]
    }
    segments.uniq
  end
end
