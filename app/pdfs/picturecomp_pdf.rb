class PicturecompPdf < Prawn::Document
require_dependency 'foo.rb'
include Foo
	def initialize(p1, p2)
		super(:margin => 20)
		picture1 = Picture.find(p1)
		picture2 = Picture.find(p2)
		text "Statistieken - vergelijking", align: :center, size: 14
		move_down 10
		text "foto 1: #{picture1.name} (#{picture1.created_at.strftime("%d/%m/%Y")})"
		text "foto 2: #{picture2.name} (#{picture2.created_at.strftime("%d/%m/%Y")})"
		move_down 10
		draw_tables(p1, p2)
	end
	def draw_tables(p1, p2)
		c = picture_comparison(p1.to_i, p2.to_i)
		text "Algemeen", :style => :bold, :align => :center
		move_down 10
		table c['totals'] do |t|
			t.position = :center
		end
		move_down 10
		text "Details", :style => :bold, :align => :center
		move_down 10
		table c['rows'] do |t|
			t.position = :center
		end
	end
end