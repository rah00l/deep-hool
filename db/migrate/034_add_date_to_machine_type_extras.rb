class AddDateToMachineTypeExtras < ActiveRecord::Migration
  def self.up
    add_column :machine_type_exrtas, :date,:date
  end

  def self.down
    remove_column :machine_type_exrtas, :date
  end
end
