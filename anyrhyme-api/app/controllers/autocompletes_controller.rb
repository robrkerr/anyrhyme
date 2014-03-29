class AutocompletesController < ApplicationController
  
  def show
  	number_of_results = params["limit"] ? params["limit"].to_i : 5
  	words = auto_complete(params[:term],number_of_results)
    respond_to do |format|
      format.json { render :json => words.to_json }
    end
  end

  private

  def auto_complete term, number
    return [] if term == ""
    words = Spelling.where("label LIKE ?", "#{term}%").limit(number).map { |sp| sp.words }.flatten
    words.map { |w| {
        :label => w.name, 
        :pronunciation_label => w.pronunciation.label,
        :pronunciation_label_with_syllable_breaks => w.pronunciation.label_with_syllable_breaks,
        :syllables => w.detailed_syllables,
        :lexemes => w.lexemes,
        :num_syllables => w.num_syllables,
        :last_stressed_syllable => w.last_stressed_syllable,
        :id => w.id
      }
    }
  end
end
