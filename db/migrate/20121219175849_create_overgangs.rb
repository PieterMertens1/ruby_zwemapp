class CreateOvergangs < ActiveRecord::Migration
  def change
    create_table :overgangs do |t|
      t.integer :zwemmer_id
      t.string :van
      t.string :naar
      t.string :lesgever

      t.timestamps
    end
  end
end
