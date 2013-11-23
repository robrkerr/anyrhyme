class RhymesController < ApplicationController
  
  def show
    if params["word"][/\d/]
      word = Word.find(params["word"].to_i)
    else
      word = Spelling.where("label LIKE ?", "#{params["word"]}").first.words.first
    end
    respond_to do |format|
      format.json { redirect_to match_route(word) }
    end
  end

  private

  def match_route word
    num = word.last_stressed_syllable
    num = ((word.syllables.length - num) > 3) ? (word.syllables.length - 3) : num
    word_syllables = word.syllables[num..-1]
    syllables_str = word_syllables.each_with_index.map { |s,i|
      str = (i==0) ? "~" : ""
      str + "#{s.onset.label},#{s.nucleus.label},#{s.coda.label}"
    }.join("/")
    "/match/beginning/with/exactly/#{num}/syllables/and/" + syllables_str + ".json"
  end
end
