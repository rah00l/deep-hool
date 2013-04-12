class AddFilefolderImpAndBackupfolderImpToConfigurations < ActiveRecord::Migration
  def self.up
    add_column :configurations ,:filefolder_imp,:string
    add_column :configurations ,:backupfolder_imp,:string
  end

  def self.down
    remove_column :configurations ,:filefolder_imp
    remove_column :configurations ,:backupfolder_imp
  end
end
