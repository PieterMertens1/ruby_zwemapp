class CreateApplicaties < ActiveRecord::Migration
  def change
    create_table :applicaties do |t|
      t.boolean :rapportperiode

      t.timestamps
    end
  end
end
