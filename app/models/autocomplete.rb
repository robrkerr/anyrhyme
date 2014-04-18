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
        spelling: w.spelling, 
        pronunciation: w.pronunciation_label,
        lexemes: JSON.parse(word.lexeme_string),
        syllables: JSON.parse(word.syllable_string),
        id: w.id
      }
    }
  end

end
