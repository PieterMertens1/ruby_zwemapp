class AddVerborgenToKlas < ActiveRecord::Migration
  def up
    add_column :klas, :verborgen, :boolean
  end

  def down
    remove_column :klas, :verborgen
  end
end
