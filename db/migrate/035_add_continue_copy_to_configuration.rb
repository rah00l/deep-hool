class AddContinueCopyToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configurations, :copy_continue, :boolean,:default => true
  end

  def self.down
    remove_column :configurations, :copy_continue, :boolean
  end
end
