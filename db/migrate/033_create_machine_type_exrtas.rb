class CreateMachineTypeExrtas < ActiveRecord::Migration
  def self.up
    create_table :machine_type_exrtas do |t|
      t.column :cluster_name, :string
      t.column :shop_name, :string
      t.column :group_id, :string
      t.column :machine_type_id, :integer
      t.column :percent_value, :integer
    end
  end

  def self.down
    drop_table :machine_type_exrtas
  end
end
