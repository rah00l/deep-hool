class ChangeUpdatedAtInUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :updated_at, :date
  end

  def self.down
    change_column :users, :updated_at, :datetime
  end
end
