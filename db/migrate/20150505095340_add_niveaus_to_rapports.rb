class AddNiveausToRapports < ActiveRecord::Migration
  def up
	add_column :rapports, :niveaus, :string
  end

  def down
    remove_column :rapports, :niveaus, :string
  end
end
