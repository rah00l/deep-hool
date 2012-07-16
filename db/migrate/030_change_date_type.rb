class ChangeDateType < ActiveRecord::Migration
  def self.up
    change_column :daily_report_customs, :hc ,:integer
    change_column :daily_report_customs, :exp ,:integer
  end

  def self.down
  end
end
