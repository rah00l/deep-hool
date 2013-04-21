class Craetetablemachinemaster < ActiveRecord::Migration
  def self.up
    create_table :machine_masters do |t|
      t.column :short_name, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :machine_types
  end
end
