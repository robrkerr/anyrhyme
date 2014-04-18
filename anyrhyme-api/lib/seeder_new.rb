require 'ar_helper'

class Seeder
  def initialize output=true
    @output = output
  end

  def clear_tables
  	# Phoneme.delete_all
  	# Segment.delete_all
    # SegmentPhoneme.delete_all
    NewSyllable.delete_all
    NewWord.delete_all
  end

  def clear_lexemes
    NewWord.update_all(:lexeme_string => [].to_json)
  end

  def seed_phonemes phonemes
    Phoneme.create!(phonemes)
  end

  def seed_words words, source
  	new_words = words.map { |w| 
    	{
    		spelling: w[:name],
    		pronunciation_label: get_pronunciation_label(w[:syllables]),
    		lexeme_string: [].to_json, 
        syllable_string: w[:syllables].to_json,
    		source: source,
    		syllables: w[:syllables]
    	}
    }
    word_id_lookup = populate_words new_words
    segments = get_all_syllable_segments(new_words.map { |w| w[:syllables]}.flatten)
    segment_id_lookup = populate_segments segments
    populate_syllables new_words, word_id_lookup, segment_id_lookup
  end

  def seed_lexemes word_lexemes, source
    spelling_to_word_ids = ArHelper.new.find_ids_with_single_column NewWord, "spelling", word_lexemes.keys
    populate_lexemes word_lexemes, spelling_to_word_ids, source
  end

  def seed_extra_word_lexemes word_relations, source
    add_extra_word_lexemes word_relations, source
  end  

  private

  def populate_words words
    columns = [:spelling, :pronunciation_label, :syllable_string, :lexeme_string, :source]
    already_existing = ArHelper.new.find_ids_with_multiple_columns NewWord, columns[0..1], words.map { |w| [w[:spelling],w[:pronunciation_label]]}
    values_to_insert = words.map { |w| 
    	columns.map { |k| w[k] } unless already_existing.has_key?([w[:spelling],w[:pronunciation_label]]) 
    }.compact
    NewWord.transaction do
      NewWord.import columns, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_multiple_columns NewWord, columns[0..1], values_to_insert.map { |v| v[0..1] }
    new_ids = new_records.keys.map { |k| new_records[k][0] }
    new_values = new_records.keys.map { |k| 
    	{spelling_word_id: "#{k[0]}_#{new_records[k][0]}"}
    }
    NewWord.update(new_ids, new_values)
    return new_records
  end

  def populate_segments segments
    columns = [:segment_type,:label]
    already_existing = ArHelper.new.find_ids_with_multiple_columns Segment, columns[0..1], segments
    values_to_insert = segments.reject { |segment| already_existing.has_key?(segment) }
    Segment.transaction do
      Segment.import columns, values_to_insert.uniq, :validate => false
    end
    new_records = ArHelper.new.find_ids_with_multiple_columns Segment, columns[0..1], values_to_insert.map { |v| v[0..1] }
    segment_id_lookup = already_existing.merge(new_records) { |k,v1,v2| 
      v1 + v2
    }
    phoneme_name_to_id = get_phoneme_name_to_id_hash
    columns = [:segment_id,:phoneme_id]
    values_to_insert = []
    new_records.each { |(_,label),segment_ids|
      ph_ids = label.split("-").map { |ph| phoneme_name_to_id[ph] }
      ph_ids.each { |ph_id| values_to_insert << [segment_ids[0],ph_id] }
    }
    SegmentPhoneme.transaction do
      SegmentPhoneme.import columns, values_to_insert.uniq, :validate => false
    end
    segment_id_lookup
  end

  def populate_syllables words, word_id_lookup, segment_id_lookup
  	columns = [
  		:spelling_word_id, :position, :r_position, 
			:onset_id, :nucleus_id, :coda_id, 
  		:onset_label, :nucleus_label, :coda_label, 
  		:stress, :label
  	]
    values_to_insert = []
    words.each { |word| 
    	word_id = word_id_lookup[[word[:spelling],word[:pronunciation_label]]][0]
      if word_id
        word[:syllables].each_with_index { |s,i| 
          r_i = word[:syllables].length-i-1
          onset_label = get_segment_label(s[:onset])
          onset_id = segment_id_lookup[[0,onset_label]][0]
          nucleus_label = get_segment_label(s[:nucleus])
          nucleus_id = segment_id_lookup[[1,nucleus_label]][0]
          coda_label = get_segment_label(s[:coda])
          coda_id = segment_id_lookup[[2,coda_label]][0]
          label = get_syllable_label(s)
          values_to_insert << [
          	"#{word[:spelling]}_#{word_id}", i, r_i,
          	onset_id, nucleus_id, coda_id,
          	onset_label, nucleus_label, coda_label,
          	s[:stress], label
          ]
        }
      end
    }
    NewSyllable.transaction do
      NewSyllable.import columns, values_to_insert.uniq, :validate => false
    end
  end

  def populate_lexemes word_lexemes, spelling_to_word_ids, source
    lexemes_to_add = Hash.new { |h,k| h[k] = {lexemes: []} }
    word_lexemes.each { |spelling,lexeme|
      spelling_to_word_ids[spelling].each { |word_id|
        word = NewWord.find(word_id)
        lexemes_to_add[word_id][:lexemes] << lexeme
        lexemes_to_add[word_id][:word] = word
      }
    }
    word_ids = lexemes_to_add.keys
    lexeme_additions = lexemes_to_add.keys.map { |k| 
      string = lexemes_to_add[k][:word].lexeme_string
      if string.length > 0
        existing_lexemes = JSON.parse(string)
      else
        existing_lexemes = []
      end
      new_lexemes = lexemes_to_add[k][:lexemes].map { |lexemes| 
        lexemes.map { |lexeme|
          {
            source: source,
            word_class: lexeme[:word_class],
            gloss: lexeme[:gloss]
          }
        }
      }.flatten
      {lexeme_string: (existing_lexemes + new_lexemes).to_json }
    }
    NewWord.update(word_ids, lexeme_additions)
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
    syllables.map { |s| get_syllable_label(s) }.join(" . ")
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
