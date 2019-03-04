class AddKleurcodeVanToOvergangs < ActiveRecord::Migration
  def up
    add_column :overgangs, :kleurcode_van, :string
  end
  def down
    remove_column :overgangs, :kleurcode_van, :string
  end
end
