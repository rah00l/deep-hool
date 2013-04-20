namespace :add_data_into_machine_master do
  desc 'Creating Default Machine Master.....'
	task :start_adding => :environment do
    Machine.find(:all,:select => "distinct MachineName").collect {|a| [a.MachineName]}.collect{|a| MachineMaster.create(:short_name => a.to_s)}
  end
  end