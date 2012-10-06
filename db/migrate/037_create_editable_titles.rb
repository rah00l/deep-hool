class CreateEditableTitles < ActiveRecord::Migration
  def self.up
    create_table :editable_titles do |t|
      t.column :content, :string
    end
  end

  def self.down
    drop_table :editable_titles
  end
end
