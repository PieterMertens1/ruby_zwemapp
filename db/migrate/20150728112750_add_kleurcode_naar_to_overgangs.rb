class AddKleurcodeNaarToOvergangs < ActiveRecord::Migration
  def up
    add_column :overgangs, :kleurcode_naar, :string
  end
  def down
    add_column :overgangs, :kleurcode_naar, :string
  end
end
