class CreateDailyReportCustoms < ActiveRecord::Migration
  def self.up
    create_table :daily_report_customs do |t|
      t.column :cluster_name, :string
      t.column :hc, :float
      t.column :exp, :float
    end
  end

  def self.down
    drop_table :daily_report_customs
  end
end
