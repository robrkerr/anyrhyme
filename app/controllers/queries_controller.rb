class QueriesController < ApplicationController
  
  def show
    @query = Query.new params
    respond_to do |format|
      format.json { render :json => @query.words_to_show.to_json }
    end
  end
end
