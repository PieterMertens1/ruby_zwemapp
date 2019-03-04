class LesgeversHaveAndBelongToManyRoles < ActiveRecord::Migration
  def self.up
    create_table :lesgevers_roles, :id => false do |t|
      t.references :role, :lesgever  
     end
  end

  def self.down
    drop_table :lesgevers_roles
  end
end
