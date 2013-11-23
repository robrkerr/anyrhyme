class QueriesController < ApplicationController
  
  def show
    @query = Query.new params
    if @query.valid?
      respond_to do |format|
        format.json { render :json => @query.words_to_show.to_json }
      end
    else
      flash[:alert] = []
      flash[:alert] << "Invalid url: #{request.env['PATH_INFO']}"
      @query.errors.full_messages.each { |msg|
        flash[:alert] << msg
      }
      redirect_to root_path
    end
  end
end
