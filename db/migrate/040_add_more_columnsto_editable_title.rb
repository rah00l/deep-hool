class AddMoreColumnstoEditableTitle < ActiveRecord::Migration
  def self.up
        add_column :editable_titles ,:value_for_hrk,:string
        add_column :editable_titles ,:value_for_lat,:string
        add_column :editable_titles ,:value_for_mrl,:string
  end

  def self.down
    remove_column :editable_titles, :value_for_hrk
    remove_column :editable_titles, :value_for_lat
    remove_column :editable_titles, :value_for_mrl
  end
end
