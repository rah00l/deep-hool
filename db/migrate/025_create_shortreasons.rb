class CreateShortreasons < ActiveRecord::Migration
  def self.up
    create_table :shortreasons do |t|
    end
  end

  def self.down
    drop_table :shortreasons
  end
end
