class Countercollection < ActiveRecord::Base
  
  validates_uniqueness_of :Date , :scope => [:ClusterName,:ShopName],:message=> "Duplicate Entry"
  validates_presence_of :HC,:Outstanding
  validate :check_os_in_multiples_of_five_hundred

  after_create :create_and_send_csv_file

  def check_os_in_multiples_of_five_hundred
    if self.Outstanding.to_i % 500 != 0
      self.errors.add_to_base("PLEASE ENTER AMOUNT IN MULTIPLES OF  0  OR  500 ")
    end
  end

  private

  def create_and_send_csv_file
    fname="#{self[:ShopName]}_"+ self[:Date].strftime("%Y%m%d")+".csv"
    create_file(self[:ShopName],self[:Date],fname)
  end



  def create_file(shop_name,date,fname)
    begin
      con = Configuration.find_by_location_name('shivraj')
      con_next = Configuration.find_by_location_name('anand')
      folderpath = con.FilesFolderPath  if !con.blank? && con.copy_continue?
      folderpath_next = con_next.FilesFolderPath  if !con_next.blank? && con_next.copy_continue?

      ###################################################################### Writing into file begins from here
      total=0
      count=0
      #          @t= Clientdata.find(:all,:conditions=>["ShopName in (?) and status=0 and date=? ",shopval[i],session[:dateval]])
      clientdada = Clientdata.find_all_by_ShopName_and_status_and_Date(shop_name,0,date)

      
      FasterCSV.open(fname, "w") do |csv|
        for sname in clientdada
          a=[sname.ClusterName,sname.ShopName,sname.Date,sname.GroupID,sname.MachineNo,sname.ScreenIN,sname.ScreenOUT,sname.MeterIN,sname.MeterOUT,sname.Machineshort,sname.Shortreason,sname.status,';']
          csv<< a
        end
      end
      total=0
      count=0
      #          @t= Countercollection.find(:all,:conditions=>["ShopName in (?) and status=0 and date=? ",shopval[i],session[:dateval]])
      counter_collection = Countercollection.find_all_by_ShopName_and_status_and_Date(shop_name,0,date)
      FasterCSV.open(fname, "a") do |csv|
        csv<< "COUNTER"
        for cdata in counter_collection
          a = [cdata.ClusterName,cdata.ShopName,cdata.Date,cdata.Cash,cdata.Exp,cdata.HC,cdata.Credit,cdata.Short_Ext,cdata.Openingbal,cdata.KEY1,cdata.KEY2,cdata.KEY3,cdata.KEY4,cdata.Outstanding,cdata.status,cdata.Total,';']
          csv<< a
        end
      end
      pw=Dir.pwd()
      Dir.chdir(pw)
      filename=pw.to_s+"/"+fname

      ###################################################################### Writing into file begins from here
      send_file(filename,folderpath,folderpath_next)
      #          @statusflag= Clientdata.find(:all,:conditions=>["ShopName in (?) and status=0 and date=?",shopval[i],session[:dateval]])
      #          change_clientdata_status = Clientdata.find_all_by_ShopName_status_date(shop_name,0,date)
      clientdada.collect{ |client_data| [client_data.update_attribute("status",1)] }
      counter_collection.collect{ |counter_data| [counter_data.update_attribute("status",1)] }

      #          change_flags.each do |c|
      #            c.status=1
      #            c.save
      #          end
      #          @counterstatusflag= Countercollection.find(:all,:conditions=>["ShopName in (?) and status=0 and date=?",shopval[i],session[:dateval]])
      #
      #          @counterstatusflag.each do |c|
      #            c.status=1
      #            c.save
      #          end
    rescue Exception=>ex
      puts ex.message
    end
  end


  def send_file(file_name,folder_path0,folder_path1)
    begin
      unless folder_path0.blank?
        if File.directory?("#{folder_path0}")
          FileUtils.copy(file_name, "#{folder_path0}")
          #              FileUtils.rm_r(filename)
        else
          FileUtils.mkdir_p "#{folder_path0}"
          FileUtils.copy(file_name, "#{folder_path0}")
        end
      end

      unless folder_path1.blank?
        if File.directory?("#{folder_path1}")
          FileUtils.copy(file_name, "#{folder_path1}")
          FileUtils.rm_r(file_name)
        else
          FileUtils.mkdir_p "#{folder_path1}"
          FileUtils.copy(file_name, "#{folder_path1}")
        end
      end
    rescue Exception=>ex
      puts ex.message()
    end
  end
  
end


