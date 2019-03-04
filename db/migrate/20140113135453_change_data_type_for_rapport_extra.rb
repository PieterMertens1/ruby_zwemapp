class ChangeDataTypeForRapportExtra < ActiveRecord::Migration
  def up
  	change_table :rapports do |t|
  		t.change :extra, :text, :limit => nil
  	end
  end

  def down
  	change_table :rapports do |t|
  		t.change :extra, :string
  	end
  end
end
