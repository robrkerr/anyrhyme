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
    @result_offset = params["offset"] ? params["offset"].to_i : false
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
    @defined = params["defined"] ? (params["defined"]=="true") : false
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
    run_query
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
    results = WordMatcher.find_words(@syllables, 
                                      total_num_syllables, 
                                      match_at_least_num, 
                                      @front_syllable, 
                                      match_direction_reversed, 
                                      @defined,
                                      @number_of_results,
                                      @result_offset)
    results.map { |word|
      {
        spelling: word.spelling, 
        pronunciation: word.pronunciation_label,
        lexemes: JSON.parse(word.lexeme_string),
        syllables: JSON.parse(word.syllable_string),
        id: word.id
      }
    }
  end
end
