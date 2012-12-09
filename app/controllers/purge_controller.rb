class PurgeController < ApplicationController
  layout 'adminlayout'
#require 'ruby-debug'
  def purge_master_tables
#    debugger
    if params[:to_date].to_date >=params[:from_date].to_date
      begin
        debugger

        machine_data_max_date = Machinedata.maximum(:trans_date)
        puts machine_data_max_date
        going_to_purge_record_count = Machinedata.find(:all,:conditions => ["trans_date!=? and trans_date>=? and trans_date<=?",machine_data_max_date,params[:from_date],params[:to_date]]).count

        puts "-before count--"*3
        puts going_to_purge_record_count
        puts "---"*12

        count = Machinedata.delete_all(["trans_date!=? and trans_date>=? and trans_date<=?",machine_data_max_date,params[:from_date],params[:to_date]])

        puts "-after count--"*3
        puts count
        puts "---"*12

        short_extra_max_date = ShortExtra.maximum(:date)
        puts short_extra_max_date

        count_defore = ShortExtra.find(:all,:conditions => ["date!=? and date>=? and date<=?",short_extra_max_date,params[:from_date],params[:to_date]]).count
        puts "-before count--"*3
        puts count_defore
        puts "---"*12

        count_after = ShortExtra.delete_all(["date!=? and date>=? and date<=?",short_extra_max_date,params[:from_date],params[:to_date]])

        puts "-before count--"*3
        puts count_after
        puts "---"*12

      rescue Exception => e
      end
      flash[:notice] ='<font color=green size=3><b>Purge Data Successfully .</b></font>'
#      session[:msg]="Purge Data Successfully "
    else
      puts "in else"
      flash[:notice] ='<font color=red size=3><b>Please select proper dates</b></font>'
		end
		redirect_to :action=>'purgemain_modi'
  end


  ###################################################################################################################

  # AS In Side application provided purging option for tables ,following listed tables
  # had option for purging.
  # For first 3 listed below had auto purging option and last 2 provided UI for purge.

  # 1. Counter collection - auto_purge
  # 2. Client data - auto_purge
  # 3. Counter collection - auto_purge

  # 4. Machine data - manual purge
  # 5. Short Extra  - manual purge

  # Following methods currently not in use . Only above 'purge_master_tables' method is use full for Data Purging.
  #
  ###################################################################################################################


#  def purgedatafirst
#		if params[:enddate].to_date >=params[:startdate].to_date
#			@shopes=Countercollection.find(:all,:select => 'DISTINCT ShopName')
#      for item in @shopes
#        @maxdate = Countercollection.find_by_sql("select max(date)as max
#														from countercollections
#														where shopname='#{item.ShopName}'
#														and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'#")
#        for a in @maxdate
#          @maxdate1=a.max
#        end
#        begin
#
#          Countercollection.find_by_sql("delete
#												from countercollections
#												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'
#												and Date!='#{@maxdate1}' and ShopName = '#{item.ShopName}'
#												and status=1#")
#        rescue Exception => e
#        end
#        @countacc = Countercollection.count(:conditions => "Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}' and status=1")
#      end
#      @shopes=Clientdata.find(:all,:select => 'DISTINCT ShopName')
#      for item in @shopes
#        @maxdate = Clientdata.find_by_sql("select max(date)as max
#																from clientdatas
#																where shopname='#{item.ShopName}'
#																and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'#")
#        for a in @maxdate
#          item.ShopName
#          @maxdate1=a.max
#        end
#        begin
#          Clientdata.find_by_sql( "delete
#												from clientdatas
#												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'
#												and Date!='#{@maxdate1}'and ShopName = '#{item.ShopName}'
#												and status=1#")
#        rescue Exception => e
#        end
#      end
#      session[:msg]="Purge Data Successfully "
#    else
#      puts "in else"
#      session[:msg]="Please select proper dates"
#		end
#		redirect_to :action=>'purgemain'
#  end
#  def Counterdata
#		if params[:enddate].to_date >=params[:startdate].to_date
#			@shopes=Counterdata.find(:all,:select => 'DISTINCT ShopName')
#      for item in @shopes
#        @maxdate = Countercollection.find_by_sql("select max(date)as max
#																			from Counterdatas
#																			where shopname='#{item.ShopName}'
#																			and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'#")
#        for a in @maxdate
#          @maxdate1=a.max
#        end
#
#        begin
#          Countercollection.find_by_sql("delete
#												from Counterdatas
#												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'
#												and Date!='#{@maxdate1}' and ShopName = '#{item.ShopName}'#")
#        rescue Exception => e
#        end
#      end
#      session[:msg]="Purge Data Successfully "
#
#		else
#      session[:msg]="Please select proper dates"
#		end
#		redirect_to :action=>'purgecounterdata'
#	end
#
#  def Machinedata
#		if params[:enddate].to_date >=params[:startdate].to_date
#			@shopes=Machinedata.find(:all,:select => 'DISTINCT Shop_Name')
#      for item in @shopes
#        @maxdate = Countercollection.find_by_sql("select max(TRANS_DATE)as max
#																			from Machinedatas
#																			where Shop_Name='#{item.Shop_Name}'
#																			and TRANS_DATE<='#{params[:enddate]}' and TRANS_DATE>='#{params[:startdate]}'#")
#
#        for a in @maxdate
#          @maxdate1=a.max
#        end
#        begin
#          Countercollection.find_by_sql("delete
#												from Machinedatas
#												where TRANS_DATE<='#{params[:enddate]}' and TRANS_DATE>='#{params[:startdate]}'
#												and TRANS_DATE!='#{@maxdate1}' and Shop_Name = '#{item.Shop_Name}'#")
#        rescue Exception => e
#        end
#      end
#      session[:msg]="Purge Data Successfully "
#    else
#      session[:msg]="Please select proper dates"
#		end
#		redirect_to :action=>'purgemachinedata'
#	end
end