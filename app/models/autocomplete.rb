class Autocomplete
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  def initialize params = {}
  	@term = params[:term]
  	@number_of_results = params["limit"] ? params["limit"].to_i : 5
    @type = params["type"]
  end

  def results
    return [] if @term == ""
    if (@type == "onset") || (@type == "nucleus") || (@type == "coda")
      if @type == "onset"
        type_id = 0
      elsif @type == "nucleus"
        type_id = 1
      else
        type_id = 2
      end
      Segment.where("segment_type = ? AND label LIKE ?", type_id, "#{@term}%").order("label").limit(@number_of_results).map { |segment| 
        {
          label: segment.label,
          id: segment.id
        }
      }
    else
      Word.where("spelling LIKE ?", "#{@term}%").order("spelling").limit(@number_of_results).map { |word| 
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

end
