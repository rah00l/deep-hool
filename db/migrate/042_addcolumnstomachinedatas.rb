class Addcolumnstomachinedatas < ActiveRecord::Migration
  def self.up
    add_column :machinedatas ,:created_at ,:datetime
    add_column :machinedatas ,:updated_at ,:datetime
  end

  def self.down
    remove_column :machinedatas ,:created_at
    remove_column :machinedatas ,:updated_at
  end
end
