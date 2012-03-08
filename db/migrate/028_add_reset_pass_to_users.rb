class AddResetPassToUsers < ActiveRecord::Migration
  def self.up
        add_column :users, :reset_pass,:string
  end

  def self.down
            remove_column :users, :reset_pass,:string

  end
end
