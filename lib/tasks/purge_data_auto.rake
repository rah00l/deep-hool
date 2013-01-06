#Data Purging functionality :-
namespace :purge_data do
  desc 'Daily Purging Data For Client_Date CounterCollection  And Counter_Data..!'
	task :auto => :environment do
    count_coll_max_date = Countercollection.maximum(:date)
    Countercollection.delete_all(["date!=? and status=?",count_coll_max_date,1])

    client_data_max_date = Clientdata.maximum(:date)
    Clientdata.delete_all(["date!=? and status=?",client_data_max_date,1])

#    count_data_max_date = Countercollection.maximum(:date)
#    Counterdata.delete_all(["date!=? and status=?",count_data_max_date,1])

  end
end

