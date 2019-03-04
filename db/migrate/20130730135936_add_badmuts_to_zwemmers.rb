class AddBadmutsToZwemmers < ActiveRecord::Migration
  def up
    add_column :zwemmers, :badmuts, :string
  end

  def down
    remove_column :zwemmers, :badmuts
  end
end
