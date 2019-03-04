class AddHashesToPicture < ActiveRecord::Migration
  def up
    add_column :pictures, :schools, :text
    add_column :pictures, :klas, :text
    add_column :pictures, :proefs, :text
    add_column :pictures, :fouts, :text
  end

  def down
    remove_column :pictures, :schools
    remove_column :pictures, :klas
    remove_column :pictures, :proefs
    remove_column :pictures, :fouts
  end
end
