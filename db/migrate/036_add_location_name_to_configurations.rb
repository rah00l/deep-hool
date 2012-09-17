class AddLocationNameToConfigurations < ActiveRecord::Migration
  def self.up
    add_column :configurations ,:location_name,:string
  end

  def self.down
    remove_column :configurations ,:location_name
  end
end
