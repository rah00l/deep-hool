class AddMachineTypeIdToMachines < ActiveRecord::Migration
  def self.up
    add_column :machines, :machine_type_id,:integer
  end

  def self.down
    remove_column :machines, :machine_type_id
  end
end
