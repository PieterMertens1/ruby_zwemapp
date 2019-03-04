class AddOvervlagToRapports < ActiveRecord::Migration
  def change
    add_column :rapports, :overvlag, :boolean
  end

  def down
    remove_column :rapports, :overvlag
  end
end
