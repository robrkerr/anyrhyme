class AutocompletesController < ApplicationController
  
  def show
    @autocomplete = Autocomplete.new params
    respond_to do |format|
      format.json { render :json => @autocomplete.results.to_json }
    end
  end

end
