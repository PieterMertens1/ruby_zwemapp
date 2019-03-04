class AddNieuwToZwemmers < ActiveRecord::Migration
  def up
    add_column :zwemmers, :nieuw, :boolean
  end
   def down
    remove_column :zwemmers, :nieuw, :boolean
  end
end
