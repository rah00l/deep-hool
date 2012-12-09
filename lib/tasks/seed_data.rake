namespace :seed_data do
  desc 'Set default values at editable_titles'
	task :editable_titles => :environment do
    EditableTitle.find_or_create_by_content_type('first half')
    EditableTitle.find_or_create_by_content_type('second half')
  end
end
