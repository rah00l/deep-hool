class Addostocounterdatas < ActiveRecord::Migration
  def self.up
    add_column :counterdatas ,:os ,:integer
  end

  def self.down
    remove_column :counterdatas ,:os
  end
end
