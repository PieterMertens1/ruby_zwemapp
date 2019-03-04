# == Schema Information
#
# Table name: niveaus
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  kleurcode  :string(255)
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Niveau < ActiveRecord::Base
  default_scope order('position') 
  has_many :groeps
  has_many :proefs
  validates_presence_of :name, :kleurcode
  validates_uniqueness_of :name, message: "bestaat al"
  after_update :badmuts_veranderen 
  acts_as_list
  #methode gebruikt in fouts_form om in grouped_collection_select de proefs geordend te kunnen weergeven
  def proefssorted
  	proefs.order(:position)
  end

  def self.to_xls
    book = Spreadsheet::Workbook.new
    format_niveau_name = Spreadsheet::Format.new :weight => :bold, :size => 18,:horizontal_align => :centre
    format_kolom_header = Spreadsheet::Format.new :weight => :bold, :size => 12,:horizontal_align => :centre
    Niveau.order(:position).each do |niveau|
      current_row = 4
      sheet = book.create_worksheet :name => niveau.name
      sheet.row(1).default_format = format_niveau_name
      sheet.row(3).default_format = format_kolom_header
      sheet[1,2] = niveau.name.upcase
      sheet[3,1] = "PROEVEN"
      sheet[3,2] = "FOUTEN"
      sheet.column(1).width = 85
      sheet.column(2).width = 55
      niveau.proefs.where(nietdilbeeks: false).order(:position).each_with_index do |proef, pi|
        sheet[current_row,1] = "#{pi+1}. #{proef.content}"
        proef.fouts.order(:position).each_with_index do |fout, fi|
          sheet[current_row,2] = fout.name
          current_row += 1
        end
        current_row += (proef.fouts.count > 0) ? 1 : 2
      end
    end

    spreadsheet = StringIO.new
    book.write spreadsheet
    return spreadsheet.string
  end

  def badmuts_veranderen
    Zwemmer.where(badmuts: self.name_was).update_all(badmuts: self.name) if self.name_changed?
  end
end
