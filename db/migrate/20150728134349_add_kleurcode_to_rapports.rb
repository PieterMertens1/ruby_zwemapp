class AddKleurcodeToRapports < ActiveRecord::Migration
  def up
    add_column :rapports, :kleurcode, :string
  end
  def down
    remove_column :rapports, :kleurcode, :string
  end
end
