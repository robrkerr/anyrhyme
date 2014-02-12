require 'word_matcher'

class Query
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :exactly, :direction, :num_syllables
  validates :exactly, inclusion: { in: ["exactly", "at-least"],
    message: "must be either 'exactly' or 'at-least', not '%{value}'." }
  validates :direction, inclusion: { in: ["beginning", "ending"],
    message: "must be either 'beginning' or 'ending', not '%{value}'." }
  validates :num_syllables, numericality: { greater_than_or_equal_to: 0 }

  def initialize params = {}
    @number_of_results = params["limit"] ? params["limit"].to_i : false
    @syllables = []
    1.upto(5) { |i|
      string = params["syllable#{i}"]
      @syllables << parse_syllable_string(string) if string
    }
    @num_syllables = params["num"].to_i
    @exactly = params["exactly"]
    @direction = params["direction"]
    if params["front_syllable"]
      @front_syllable = parse_syllable_string(params["front_syllable"])
    end
  end

  def parse_syllable_string string
    syllable = string.gsub(",","&,&").split(",").each_with_index.map { |chunk,i| 
      chunk = chunk.gsub("&","")
      if i == 1
        chunk = chunk.gsub("-","")
      end
      if chunk[0]=="~" 
        [chunk[1..-1].downcase,false]
      else
        [chunk.downcase,true]
      end  
    }
    syllable
  end

  def persisted?
    false
  end

  def words_to_show
    @words_to_show_cached ||= run_query
  end

  def total_num_syllables
    @num_syllables + @syllables.length + (@front_syllable ? 1 : 0)
  end

  def match_at_least_num
    @exactly=="at-least"
  end

  def match_direction_reversed
    @direction=="ending"
  end

  def run_query
    pronunciations = WordMatcher.find_words(@syllables, 
                                            total_num_syllables, 
                                            match_at_least_num, 
                                            @front_syllable, 
                                            match_direction_reversed, 
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
            {
              word_class: word_lexeme["word_class"],
              word_gloss: word_lexeme["gloss"]
            }
          else 
            nil
          end
        }.compact
        { name: words[id].first["label"], lexemes: lexemes, word_id: id}
      }.sort_by { |word| -word[:lexemes].length }
      { 
        primary_word: words_sorted.first, 
        other_words: words_sorted[1..-1], 
        even_tag: (i%2==1) ? "even" : "odd",
        pronunciation_label: pronunciations[i].label, 
        pronunciation_label: pronunciations[i].label, 
        pronunciation_label_with_syllable_breaks: pronunciations[i].label_with_syllable_breaks,
        syllables: syllables.reverse.map { |s| s.detailed_syllable },
        num_syllables: syllables.length 
      }
    }
  end
end
