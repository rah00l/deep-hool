class Changedatatypeofhcexp < ActiveRecord::Migration
  def self.up
    change_column :daily_report_customs, :hc ,:string
    change_column :daily_report_customs, :exp ,:string
  end

  def self.down
  end
end
