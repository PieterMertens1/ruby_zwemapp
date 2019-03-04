class AddSchoolAndKlasToRapport < ActiveRecord::Migration
	def up
	    add_column :rapports, :school, :string
	    add_column :rapports, :klas, :string
  	end

  	def down
    	remove_column :rapports, :school, :string
    	remove_column :rapports, :klas, :string
  	end
end
