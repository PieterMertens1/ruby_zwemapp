class OvergangsController < ApplicationController
	def destroy
	    @overgang = Overgang.find(params[:id])
	    @overgang.destroy

	    respond_to do |format|
	      format.html { redirect_to zwemmer_path(@overgang.zwemmer), notice: 'Overgang werd succesvol verwijderd.' }
	      format.json { head :no_content }
	    end
	 end
end