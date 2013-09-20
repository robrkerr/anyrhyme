require 'word_matcher'

class Query
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :word, :id, :text, :match_details, :match_string
  attr_accessor :word_type, :dictionary
  validate :found_a_word

  def found_a_word
    if @word
      true
    else
      errors[:base] << "The word you entered doesn't match any we know of."
      false
    end
  end

  def initialize params = {}
    @match_string = params[:match_string] || ""
    @word_type = params[:word_type] || ""
    @dictionary = params[:dictionary] || "0"
    @auto_complete = params[:autocomplete] || "words"
    @term = params[:term] || false
    @number_of_results = 13
    if params[:id].present?
      @id = params[:id].to_i
      @word = Word.find(@id)
      @text = @word.name
    else
      @text = params[:text].present? ? parse_text(params[:text]) : ""
      @word = Spelling.where(:label => @text).try(&:first).try(&:words).try(&:first) || nil
      @id = @word.id if @word
    end
    if @word
      if @match_string == ""
        @match_details = parse_match_string perfect_rhyme_match_string
      else
        @match_details = parse_match_string @match_string
      end
    end
  end

  def parse_match_string string
    string.split(",").map { |e|
      if e.include?(":")
        split_e = e.split(":")
        if split_e.length == 2
          [split_e[0].to_i,split_e[1]!="false"]
        else
          split_e.map { |ee|
            split_ee = ee.split(";")
            [split_ee[0],split_ee[1]!="false"]
          }
        end
      else
        false
      end
    }
  end

  def parse_text text
    # text.downcase.split(" ").last.split("-").last
    text.downcase.split(" ").last
  end

  def persisted?
    false
  end

  def perfect_rhyme_match_string
    num = @word.last_stressed_syllable
    num = ((@word.syllables.length - num) > 3) ? (@word.syllables.length - 3) : num
    word_syllables = @word.syllables[num..-1]
    word_syllables_str = word_syllables.each_with_index.map { |s,i|
      if i == 0
        "#{s.onset.label};false:#{s.nucleus.label}#{s.stress};true:#{s.coda.label};true" 
      else
        "#{s.onset.label};true:#{s.nucleus.label}#{s.stress};true:#{s.coda.label};true" 
      end
    }.join(",")
    return "false,0:true," + (["false,"]*num).join("") + word_syllables_str + ",false,false"
  end

  def vowels_only_match_string
    num = @word.last_stressed_syllable
    num = ((@word.syllables.length - num) > 3) ? (@word.syllables.length - 3) : num
    word_syllables = @word.syllables[num..-1]
    word_syllables_str = word_syllables.each_with_index.map { |s,i|
      if i == 0
        "#{s.onset.label};false:#{s.nucleus.label}#{s.stress};true:*;true" 
      else
        "*;true:#{s.nucleus.label}#{s.stress};true:*;true" 
      end
    }.join(",")
    return "false,0:true," + (["false,"]*num).join("") + word_syllables_str + ",false,false"
  end

  def portmanteau1_match_string
    num = @word.syllables.length - 1
    word_syllables = @word.syllables[-1..-1]
    word_syllables_str = word_syllables.map { |s|
      "#{s.onset.label};true:#{s.nucleus.label}#{s.stress};true:#{s.coda.label};true" 
    }.join(",")
    return "false,false," + (["false,"]*num).join("") + word_syllables_str + ",1:true,false"
  end

  def portmanteau2_match_string
    num = @word.syllables.length - 1
    word_syllables = @word.syllables[0..0]
    word_syllables_str = word_syllables.map { |s|
      "#{s.onset.label};true:#{s.nucleus.label}#{s.stress};true:#{s.coda.label};true" 
    }.join(",")
    return "false,1:true," + word_syllables_str + ([",false"]*num).join("") + ",false,false"
  end

  def match_total_syllables
    num = @match_details[0] ? 1 : (@match_details[-1] ? 1 : 0)
    num += (@match_details[1] ? @match_details[1][0] : (@match_details[-2] ? @match_details[-2][0] : 0))
    return num + match_word_syllables
  end

  def match_word_syllables
    return @match_details[2..-3].inject(0) { |s,e| e ? s+1 : s }
  end

  def match_at_least
    return @match_details[1] ? @match_details[1][1] : (@match_details[-2] ? @match_details[-2][1] : false)
  end

  def match_to_first
    return !!@match_details[-1] || !!@match_details[-2]
  end

  def match_from_first
    return !@match_details[-3]
  end

  def syllable_diagram_object_presence syllable_num
    return (@match_details[syllable_num]) ? "" : "no_syllable"
  end

  def syllable_diagram_object_colour syllable_num, chunk_num
    if @match_details[syllable_num]
      chunk = @match_details[syllable_num][chunk_num]
      if chunk[0]=="*"
        return "blue"
      elsif chunk[1]
        return "green"
      else
        return "red"
      end
    else
      return "blue"
    end
  end

  def syllable_diagram_object_phoneme syllable_num, chunk_num
    if @match_details[syllable_num]
      return @match_details[syllable_num][chunk_num][0]
    else
      return "*"
    end
  end

  def syllable_diagram_object_match syllable_num, chunk_num
    if @match_details[syllable_num]
      chunk = @match_details[syllable_num][chunk_num]
      if chunk[0]!="*" && chunk[1]
        return "checked=checked"
      end
    end
    return ""
  end

  def syllable_diagram_object_antimatch syllable_num, chunk_num
    if @match_details[syllable_num]
      chunk = @match_details[syllable_num][chunk_num]
      if chunk[0]!="*" && !chunk[1]
        return "checked=checked"
      end
    end
    return ""
  end

  def syllable_diagram_object_leading
    if @match_details[1]
      if @match_details[-2]
        # error
      end
      leading = @match_details[1]
    elsif @match_details[-2]
      leading = @match_details[-2]
    else
      return ""
    end
    if leading[1]
      return "#{leading[0]}+"
    else
      return "#{leading[0]}"
    end
  end

  def auto_complete number
    if @auto_complete == "words"
      auto_complete_words number
    elsif @auto_complete == "segments"
      auto_complete_segments number
    else
      []
    end
  end

  def auto_complete_words number
    return [] unless @term
    words = Spelling.where("label LIKE ?", "#{@term}%").limit(number).map { |sp| sp.words }.flatten
    words.map { |w| {
        :label => w.name, 
        :phonetic_label => w.pronunciation.label,
        :num_syllables => w.num_syllables,
        :id => w.id
      }
    }
  end

  # def auto_complete_segments number
  #   return [] unless @term
  #   if reversed_mode
  #     segments = Segment.select([:id,:label,:segment_type])
  #                    .where(["label LIKE ? AND segment_type > ?", "#{@term}%", 0])
  #                    .order(:label)
  #                    .limit(number)
  #     segments.map { |segment| {
  #         :label => segment.label, 
  #         :id => segment.id,
  #         :type => segment.segment_type
  #       }
  #     }
  #   else
  #     segments = Segment.select([:id,:label,:segment_type])
  #                       .where(["label LIKE ? AND segment_type < ?", "#{@term}%", 2])
  #                       .order(:label)
  #                       .limit(number)
  #     segments.map { |segment| {
  #         :label => segment.label, 
  #         :id => segment.id,
  #         :type => segment.segment_type
  #       }
  #     }
  #   end
  # end

  def dictionary_results text
    spelling = Spelling.where(label: text).first
    words = spelling.words
    linked_results = Word.select("words.id, lexemes.word_class, lexemes.gloss")
                         .where(:id => words.map(&:id))
                         .joins("LEFT JOIN word_lexemes ON word_lexemes.word_id = words.id
                                 LEFT JOIN lexemes ON lexemes.id = word_lexemes.lexeme_id")
                         .map(&:attributes)
                         .group_by { |r| r["id"] }
    word_id_to_syllables = Syllable.where(:pronunciation_id => words.map(&:pronunciation_id))
                                   .order("position ASC").group_by(&:pronunciation_id)
    words.each_with_index.map { |word,i| 
      syllables = word_id_to_syllables[word.pronunciation_id]
      lexemes = linked_results[word.id].each_with_index.map { |word_lexeme,j|
        if word_lexeme["word_class"] && word_lexeme["gloss"]
          "#{j+1}: (" + word_lexeme["word_class"] + ") " + word_lexeme["gloss"] + "."
        else 
          nil
        end
      }.compact
      word_hash = { name: spelling.label, num_syllables: syllables.length, 
                        lexemes: lexemes, word_id: word.id }
      { primary_word: word_hash, 
        other_words: [], 
        even_tag: (i%2==0) ? "even" : "odd",
        pronunciation_label: syllables.map(&:label).join("-"), 
        syllables: reversed_mode ? syllables : syllables.reverse }
    }
  end

  def params
    basic_params optional_params
  end

  def toggle_params
    basic_params({}, true)
  end

  def basic_params hash={}, toggle=false
    if (@dictionary == "1")
      hash[:text] = @text unless @text == ""
      hash[:dictionary] = "1" unless toggle
    elsif toggle
      hash[:text] = @text unless @text == ""
      hash[:dictionary] = "1"
    else
      hash[:text] = @text unless (@id || @text=="")
      hash[:id] = @id
    end
    hash
  end

  def optional_params hash={}
    if valid?
      hash[:word_type] = @word_type if @word_type.present?
      hash[:match_string] = @match_string if @match_string.present?
    end
    hash
  end

  def rhyming_link word_id
    # optional_params.merge({:id => word_id})
    {:id => word_id}
  end

  def words_to_show
    if @words_to_show_cached 
      # return that
    elsif !valid?
      @words_to_show_cached = []
    elsif dictionary_mode
      @words_to_show_cached = dictionary_results @word.name
    else
      @words_to_show_cached = run_query
    end
    @words_to_show_cached
  end

  def dictionary_mode
    @dictionary=="1"
  end

  def reversed_mode
    @reverse=="1"
  end

  def reversed_tag
    reversed_mode ? "reversed" : "normal_order"
  end

  def run_query
    pronunciations = WordMatcher.find_words(@match_details[2..-3], 
                                            match_total_syllables, 
                                            match_at_least, 
                                            (match_to_first ? @match_details[-1] : @match_details[0]), 
                                            match_to_first, 
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
        syllables: reversed_mode ? syllables : syllables.reverse }
    }
  end

  def num_syllables_filter_options
    labels = ["","1","2","3","4","5","6","7+"]
    vals = ["",1,2,3,4,5,6,7]
    labels.zip(vals)
  end

  def word_type_filter_options
    opts = ["","noun","adj","adv","verb"]
    opts.zip(opts)
  end

end
