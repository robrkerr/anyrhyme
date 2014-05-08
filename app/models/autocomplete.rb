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
