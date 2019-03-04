# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class School < ActiveRecord::Base
  has_many :klas
  validates_presence_of :name

  def week
  	w = self.klas.each.detect{|k| k.tweeweek==false }
  	return w ? true : false
  end
  def tweeweek
  	w = self.klas.each.detect{|k| k.tweeweek }
  	return w ? true : false
  end
  def to_xls
    book = Spreadsheet::Workbook.new

    klas.order(:name).each do |k|
      sheet = book.create_worksheet :name => k.name
      sheet.column(1).width = 20
      sheet.column(3).width = 35
      k.zwemmers.order(:name).each_with_index do |z, zi|
        sheet[1+zi,1] = self.name
        sheet[1+zi,2] = k.name
        sheet[1+zi,3] = z.name
        sheet[1+zi,4] = z.groepvlag > 0 ? Groep.find(z.groepvlag).niveau.name : z.groep.niveau.name
      end
    end

    spreadsheet = StringIO.new
    book.write spreadsheet
    return spreadsheet.string
  end
end
