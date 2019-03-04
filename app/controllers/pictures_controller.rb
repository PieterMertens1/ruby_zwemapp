class PicturesController < ApplicationController
  before_filter :authenticate_lesgever!

  def show
  	picture = Picture.find(params[:id])
  	respond_to do |format|
	  	format.xls do
	    	send_data( picture.to_xls, :filename => "dilkom_stats_#{picture.created_at.strftime("%d-%m-%Y")}.xls" )
	    end
	end
  end
  def create
  	if not params[:picture][:name].empty?
	  	niveaus_hash = Hash[ Niveau.order(:position).map{|n| [n.position, [n.name, n.kleurcode, n.id]]}]
	  	proefs_hash = Hash[ Proef.where(nietdilbeeks: false).map{|p| [p.id, [p.content,p.niveau_id, p.belangrijk, p.position]]}]
	  	fouts_hash = Hash[ Fout.all.map{|f| [f.id, [f.name,f.proef_id, f.position]]}]
		cat_dilb_wekelijks = {}
		(1..6).each do |i|
		 	cat_dilb_wekelijks[i] = get_freqs(Kla.where(tweeweek: false, nietdilbeeks: false).where("name like ?", "#{i}%"))
		end
		cat_dilb_tweewekelijks = {}
		(1..6).each do |i|
		 	cat_dilb_tweewekelijks[i] = get_freqs(Kla.where(tweeweek: true, nietdilbeeks: false).where("name like ?", "#{i}%"))
		end
		cat_nietdilb = {}
		(1..6).each do |i|
		 	cat_nietdilb[i] = get_freqs(Kla.where(nietdilbeeks: true).where("name like ?", "#{i}"))
		end
		schools = Hash.new
		School.all.each do |s|
		 	schools[s.id] = Hash.new
		    (1..6).each do |i|
		      schools[s.id][i] = get_freqs(s.klas.select{|k| k.name[0] == i.to_s})
		    end
		end
		details_hash = Hash[ Zwemmer.all.map{|z| [z.id, [(z.groepvlag > 0 ? Groep.find(z.groepvlag).niveau.position : z.groep.niveau.position), z.kla.name, (z.kla.tweeweek ? "2" : "w")+(z.kla.nietdilbeeks ? "n" : "d"), z.kla.id]]}]
		totals_hash = {"categories" => {"cat_dilb_week" => cat_dilb_wekelijks, "cat_dilb_tweeweek" => cat_dilb_tweewekelijks, "cat_nietdilb" => cat_nietdilb}, "schools" => schools}
		schools_hash = Hash[ School.all.map{|s| [s.id, s.name]}]
		klas_hash = Hash[ Kla.all.map{|k| [k.id, [k.name, k.school.id, k.tweeweek, k.verborgen]]}]
		p = Picture.new(name: params[:picture][:name], niveaus: niveaus_hash, totals: totals_hash, details: details_hash, schools: schools_hash, klas: klas_hash, proefs: proefs_hash, fouts: fouts_hash)
		if p.save
		  	redirect_to fronts_singlestat_path, notice: 'Foto werd succesvol gemaakt.'
		else
		    redirect_to fronts_singlestat_path, notice: 'Foto kon niet bewaard worden.'
		end
	else
		redirect_to fronts_singlestat_path, notice: 'Vul een beschrijving in voor de foto.'
	end
  end

  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    redirect_to fronts_singlestat_path, notice: 'Foto werd succesvol verwijderd.'
  end
end