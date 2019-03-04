class Picture < ActiveRecord::Base
  attr_accessible :details, :name, :totals, :niveaus, :schools, :klas, :proefs, :fouts
  validates :name, :presence => true
  serialize :niveaus, Hash
  serialize :totals, Hash
  serialize :details, Hash
  serialize :schools, Hash
  serialize :klas, Hash
  serialize :proefs, Hash
  serialize :fouts, Hash

  def to_xls
  	book = Spreadsheet::Workbook.new
    ### niveaus sheet ###
  	sheet = book.create_worksheet :name => "niveaus, proeven en fouten"
    sheet[1,2] = "niveau id"
    sheet[1,3] = "niveau naam"
    sheet[1,4] = "niveau positie"
    sheet[1,5] = "proef"
    sheet[1,6] = "belangrijk?"
    sheet[1,7] = "fout"
    sheet.column(5).width = 85
    counter = 2
    proefs = self.proefs
    fouts = self.fouts
  	self.niveaus.sort_by{|nk,nv| nk}.each do |k,v|
      sheet[counter,2] = v[2]
      sheet[counter,3] = v[0]
      sheet[counter,4] = k
      counter += 1
      niveau_proefs = proefs.select{|p_k, p_v| p_v[1] == v[2]}.sort_by{|p_k, p_v| p_v[3]}
      niveau_proefs.each do |np_k, np_v|
        sheet[counter,5] = np_v[0]
        sheet[counter,6] = np_v[2]
        counter += 1
        proef_fouts = fouts.select{|f_k, f_v| f_v[1] == np_k}.sort_by{|f_k, f_v| f_v[2]}
        proef_fouts.each do |pf_k, pf_v|
          sheet[counter,7] = pf_v[0]
          counter += 1
        end
      end
  	end
    ### zwemmers sheet ###
    sheet = book.create_worksheet :name => "zwemmers"
    self.details.each_with_index do |(k, v), di|
    	sheet[1,2] = "zwemmer id"
    	sheet[1,3] = "klasnaam"
    	sheet[1,4] = "klas id"
    	sheet[1,5] = "niveau"
    	sheet[di+2,2] = k
      	sheet[di+2,3] = v[1]
      	sheet[di+2,4] = v[3] if v[3]
      	sheet[di+2,5] = v[0]
    end
    ### scholen en klassen sheet ###
    sheet = book.create_worksheet :name => "scholen en klassen"
    sheet[1,2] = "school id"
    sheet[1,3] = "schoolnaam"
    sheet[1,4] = "klas id"
    sheet[1,5] = "klasnaam"
    sheet[1,6] = "2-wekelijks"
    sheet[1,7] = "verborgen"
    klassen = self.klas
    counter = 2
    self.schools.each do |k, v|
      school_klassen = klassen.select{|kl_k, kl_v| kl_v[1] == k}
      school_klassen = school_klassen.sort_by{|sk_k, sk_v| sk_v[0]}
      sheet[counter,2] = k
      sheet[counter,3] = v
      school_klassen.each do |sk_k, sk_v|
        sheet[counter,4] = sk_k
        sheet[counter,5] = sk_v[0]
        sheet[counter,6] = sk_v[2]
        sheet[counter,7] = (sk_v[3] == true) ? true : false
        counter += 1
      end
      counter += 1
    end
    spreadsheet = StringIO.new
    book.write spreadsheet
    return spreadsheet.string
  end
end

# h2 = {1=>2, 2=>1,3=>5,4=>4}
# h = {"d"=>{"kriebel"=>{6=>[6,4,10,9,8,7]}}}
# p = Picture.create(name:"didi", totals:h, details:h2)