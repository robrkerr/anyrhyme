require 'word_matcher'

class Query
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :text, :match_details

  def initialize params = {}
    @number_of_results = params["limit"] ? params["limit"].to_i : 13
    @syllables = []
    1.upto(5) { |i|
      string = params["syllable#{i}"]
      @syllables << parse_syllable_string(string) if string
    }
    @num_syllables = params["num"].to_i + @syllables.length
    @exactly = params["exactly"]=="exactly"
    @direction = params["direction"]!="beginning"
    if params["front_syllable"]
      @front_syllable = parse_syllable_string(params["front_syllable"])
      @num_syllables += 1
    end
  end

  def parse_syllable_string string
    string.split(",").map { |chunk| 
      if chunk[0]=="~" 
        [chunk[1..-1],false]
      else
        [chunk,true]
      end  
    }
  end

  def persisted?
    false
  end

  def words_to_show
    @words_to_show_cached ||= run_query
  end

  def run_query
    pronunciations = WordMatcher.find_words(@syllables, 
                                            @num_syllables, 
                                            !@exactly, 
                                            @front_syllable, 
                                            @direction, 
                                            @number_of_results)
    pron_ids = pronunciations.map { |pron| pron.id }
    linked_results = Word.select("pronunciation_id, words.id, spellings.label, lexemes.word_class, lexemes.gloss")
                         .where(:pronunciation_id => pron_ids)
                         .joins("LEFT JOIN spellings ON spellings.id = words.spelling_id
                                 LEFT JOIN word_lexemes ON word_lexemes.word_id = words.id
                                 LEFT JOIN lexemes ON lexemes.id = word_lexemes.lexeme_id")
                         .map(&:attributes)
                         .group_by { |r| r["pronunciation_id"] }
    pron_id_to_syllables = Syllable.where(:pronunciation_id => pron_ids).order("position ASC").group_by(&:pronunciation_id)
    pron_ids.map { |id| linked_results[id] }.each_with_index.map { |pron_words,i| 
      syllables = pron_id_to_syllables[pronunciations[i].id]
      words = pron_words.group_by { |w| w["id"] }
      words_sorted = words.keys.map { |id| 
        lexemes = words[id].each_with_index.map { |word_lexeme,j|
          if word_lexeme["word_class"] && word_lexeme["gloss"]
            "#{j+1}: (" + word_lexeme["word_class"] + ") " + word_lexeme["gloss"] + "."
          else 
            nil
          end
        }.compact
        { name: words[id].first["label"], num_syllables: syllables.length, 
                        lexemes: lexemes, word_id: id}
      }.sort_by { |word| -word[:lexemes].length }
      { primary_word: words_sorted.first, 
        other_words: words_sorted[1..-1], 
        even_tag: (i%2==0) ? "even" : "odd",
        pronunciation_label: pronunciations[i].label, 
        syllables: syllables.reverse }
    }
  end
end
