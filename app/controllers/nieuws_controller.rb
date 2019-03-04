class NieuwsController < ApplicationController
	def index
		@nieuws = Nieuw.order('created_at DESC').all
	end
	def new
		@nieuw = Nieuw.new
    	respond_to do |format|
      		format.html # new.html.erb
      		format.json { render json: @nieuw }
    	end
	end
	def create
    @nieuw = Nieuw.new(params[:nieuw])
    respond_to do |format|
      if @nieuw.save
        format.html { redirect_to nieuws_path, notice: 'Nieuws werd succesvol aangemaakt.' }
        format.json { render json: @nieuw, status: :created, location: @nieuw }
      else
        format.html { render action: "new" }
        format.json { render json: @nieuw.errors, status: :unprocessable_entity }
      end
    end
  end
end