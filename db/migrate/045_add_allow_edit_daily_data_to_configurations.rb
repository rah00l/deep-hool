class AddAllowEditDailyDataToConfigurations < ActiveRecord::Migration
  def self.up
    add_column :configurations ,:allow_edit_daily_data ,:boolean ,:default => true
  end

  def self.down
    remove_column :configurations ,:allow_edit_daily_data
  end
end
