class CreateQuoterings < ActiveRecord::Migration
  def change
    create_table :quoterings do |t|
      t.integer :proef_id
      t.text :content

      t.timestamps
    end
  end
end
