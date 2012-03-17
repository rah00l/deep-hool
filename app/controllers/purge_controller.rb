class PurgeController < ApplicationController
  layout 'adminlayout'
  def purgedatafirst
		if params[:enddate].to_date >=params[:startdate].to_date
			@shopes=Countercollection.find(:all,:select => 'DISTINCT ShopName')
      for item in @shopes
        @maxdate = Countercollection.find_by_sql("select max(date)as max
														from countercollections 
														where shopname='#{item.ShopName}'
														and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'")
        for a in @maxdate
          @maxdate1=a.max
        end
        begin
							
          Countercollection.find_by_sql("delete
												from countercollections 
												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}' 
												and Date!='#{@maxdate1}' and ShopName = '#{item.ShopName}'
												and status=1")
        rescue Exception => e
        end
        @countacc = Countercollection.count(:conditions => "Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}' and status=1")
      end
      @shopes=Clientdata.find(:all,:select => 'DISTINCT ShopName')
      for item in @shopes
        @maxdate = Clientdata.find_by_sql("select max(date)as max
																from clientdatas 
																where shopname='#{item.ShopName}'
																and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'")
        for a in @maxdate
          item.ShopName
          @maxdate1=a.max
        end
        begin
          Clientdata.find_by_sql( "delete
												from clientdatas 
												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}' 
												and Date!='#{@maxdate1}'and ShopName = '#{item.ShopName}'
												and status=1")
        rescue Exception => e
        end
      end
      session[:msg]="Purge Data Successfully "
    else
      puts "in else"
      session[:msg]="Please select proper dates"
		end
		redirect_to :action=>'purgemain'							
  end
  def Counterdata
		if params[:enddate].to_date >=params[:startdate].to_date
			@shopes=Counterdata.find(:all,:select => 'DISTINCT ShopName')
      for item in @shopes
        @maxdate = Countercollection.find_by_sql("select max(date)as max
																			from Counterdatas 
																			where shopname='#{item.ShopName}'
																			and Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}'")
        for a in @maxdate
          @maxdate1=a.max
        end
				
        begin
          Countercollection.find_by_sql("delete
												from Counterdatas 
												where Date<='#{params[:enddate]}' and Date>='#{params[:startdate]}' 
												and Date!='#{@maxdate1}' and ShopName = '#{item.ShopName}'")
        rescue Exception => e
        end
      end
      session[:msg]="Purge Data Successfully "
          
		else
      session[:msg]="Please select proper dates"
		end
		redirect_to :action=>'purgecounterdata'							
	end
    
  def Machinedata
		if params[:enddate].to_date >=params[:startdate].to_date
			@shopes=Machinedata.find(:all,:select => 'DISTINCT Shop_Name')
      for item in @shopes
        @maxdate = Countercollection.find_by_sql("select max(TRANS_DATE)as max
																			from Machinedatas 
																			where Shop_Name='#{item.Shop_Name}'
																			and TRANS_DATE<='#{params[:enddate]}' and TRANS_DATE>='#{params[:startdate]}'")
						
        for a in @maxdate
          @maxdate1=a.max
        end
        begin
          Countercollection.find_by_sql("delete
												from Machinedatas 
												where TRANS_DATE<='#{params[:enddate]}' and TRANS_DATE>='#{params[:startdate]}' 
												and TRANS_DATE!='#{@maxdate1}' and Shop_Name = '#{item.Shop_Name}'")
        rescue Exception => e
        end
      end
      session[:msg]="Purge Data Successfully "
    else
      session[:msg]="Please select proper dates"
		end
		redirect_to :action=>'purgemachinedata'							
	end
end