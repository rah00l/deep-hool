class AddContentTypeToEditableTitle < ActiveRecord::Migration
  def self.up
    add_column :editable_titles ,:content_type,:string
  end

  def self.down
    remove_column :editable_titles, :content_type
  end
end
