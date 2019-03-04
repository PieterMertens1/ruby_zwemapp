class AddProefIdToResultaats < ActiveRecord::Migration
  def up
    add_column :resultaats, :proef_id, :integer
  end
  def down
    remove_column :resultaats, :proef_id, :integer
  end
end
