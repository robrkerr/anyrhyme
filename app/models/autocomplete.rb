class Autocomplete
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  def initialize params = {}
  	@term = params[:term]
  	@number_of_results = params["limit"] ? params["limit"].to_i : 5
  end

  def results
    return [] if @term == ""
    NewWord.where("spelling LIKE ?", "#{@term}%").limit(@number_of_results).map { |w| 
    	{
        :label => w.spelling, 
        :pronunciation_label => w.pronunciation_label,
        # :syllables => w.detailed_syllables,
        :lexemes => w.lexeme_string,
        # :num_syllables => w.num_syllables,
        # :last_stressed_syllable => w.last_stressed_syllable,
        :id => w.id
      }
    }
  end

end
