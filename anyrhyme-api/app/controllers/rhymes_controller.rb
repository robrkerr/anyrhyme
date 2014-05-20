class RhymesController < ApplicationController
  
  def show
    if params["word"][/\d/]
      word = Word.find(params["word"].to_i)
    else
      matching_words = Word.where("spelling LIKE ?", "#{params["word"]}")
      word = matching_words.first if matching_words.length > 0
    end
    respond_to do |format|
      if word 
        format.json { redirect_to match_route(word) }
      else
        format.json { render :json => [].to_json }
      end
    end
  end

  private

  def match_route word
    num = last_stressed_syllable(word) || 0
    num = ((word.syllables.length - num) > 3) ? (word.syllables.length - 3) : num
    word_syllables = word.syllables[num..-1]
    syllables_str = word_syllables.each_with_index.map { |s,i|
      str = (i==0) ? "~" : ""
      str + "#{s.onset.label},#{s.nucleus.label},#{s.coda.label}"
    }.join("/")
    "/match/beginning/with/exactly/#{num}/syllables/and/" + syllables_str + ".json"
  end

  def last_stressed_syllable word
    word.syllables.rindex { |s| s.stress > 0 }
  end

end
