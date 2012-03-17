class EntriesController < ApplicationController
  layout 'adminlayout'
  before_filter :login_required
  #Method for creating data to be sent to server
  #whose data of all machines filled in entry
  #table according to the date selected

  def showshop
    render :update do |page|
      page.replace_html 'shoplistdiv', :partial => 'shoplist'
    end 
  end

  def getdate
    @session['shopdate']=params[:Date]
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'createdata')
    end 
  end


  def cleardate1
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'cleardata')
    end 
  end


  def dateselect
    s=[]
    @session['shopdate']=nil
    @session['shopdate']=params[:Date]
  end

  def refreshmaster
    render :update do |page|
      page << "document.getElementById('aux_div').style.visibility = 'visible'"
      page.alert "Data send to server properly"
      page.redirect_to url_for(:action=>'new')
    end                      
  end

  def showdata
    session[:dateval]=params[:datevalue]
    render :update do |page|
      page.replace_html('griddisp',:partial=>'edetails')
    end 
  end
  

  #DATA WILL BE SEND TO SERVER AND DUMPPED IN .SQL BACKUP FILE
  def createdata
    begin
      @t= Entry.find(:all,:conditions=>["ShopName in (?) and status=0",params[:Entries][:ShopName]])
      @t.each do |c|
        c.status=1
        c.save
      end
      date=Time.now().strftime("%Y%m%d")
      @cluster=Shop.find_first(["ShopName=?",params[:Entries][:ShopName]])
      fname="#{@cluster.ClusterName}_#{params[:Entries][:ShopName]}_"+date+".sql"
      total=0
      count=0
      @t= Entry.find(:all,:conditions=>["ShopName in (?) and status=1 ",params[:Entries][:ShopName]])
      FasterCSV.open(fname, "w") do |csv|
        for sname in @t
          @a=[sname.ClusterName,sname.ShopName,sname.Date,sname.GroupID,sname.MachineNo,sname.ScreenIN,sname.ScreenOUT,sname.MeterIN,sname.MeterOUT,sname.Machineshort,sname.Shortreason,sname.status]
          csv<< @a
        end
      end
      pw=Dir.pwd()
      Dir.chdir(pw)
      filename=pw.to_s+"/"+fname
      render :update do |page|
        page << "document.getElementById('aux_div').style.visibility = 'visible'"
        page.redirect_to url_for(:controller=>'entries', :action=>'new')
      end
    rescue Exception=>ex
      puts ex.message
    end
  end

  def cleardata
  end

  def missingrecordslist
    if(params[:entry][:ShopName]==""  and @session[:shopname]==nil)
      session[:errmsg]="Please select ShopName"
      render :update do |page|
        page.redirect_to url_for(:controller=>'entries', :action=>'new')
      end
    else
      if(params[:entry][:ShopName]=="")
        @session['shop']=@session[:shopname]
      else
        @session['shop']=params[:entry][:ShopName]
      end
      @session['date']=params[:entry][:Date]
      @session['date']=Date.parse(@session['date'])
      render :update do |page|
        page.redirect_to url_for(:controller=>'entries', :action=>'missingrecords')
      end
    end 
  end

  def saveshort
    begin
      @s=Entry.find_first(["ShopName=? and GroupID=? and MachineName=? and Date=?",@session['shortshop'],@session['shortgroupid'],@session['shortmachinename'],@session['shortdate']])
      if(@s!=nil)
        if(params[:entry][:Machineshort]==nil)
          session[:errmsg]="Please select ShopID"
          redirect_to :controller=>'entries',:action => 'short'
        elsif(params[:entry][:Shortreason]==nil)
          session[:errmsg]="Please select ShopID"
          redirect_to :controller=>'entries',:action => 'short'
        else
          @s.Machineshort=params[:entry][:Machineshort]
          @s.Shortreason=params[:entry][:Shortreason]
          @s.save
          redirect_to :controller=>'entries',:action => 'new'
        end
      else
        render :update do |page|
          page.alert("Please Enter its details first")
          page.redirect_to url_for(:controller=>'entries', :action=>'new')
        end
      end
    rescue Exception=>ex
      puts ex.message
    end
  end

  #SHORT REASON CODE FOR ENTRING THE SHORTS FOR SPECIFIC MACHINE
  def checkshort
    begin
      params[:entry][:ShopName]==""
      if(params[:entry][:ShopName]=="" and @session[:shopname]==nil) #IF SHOPID NOT SELECTED THEN
        session[:errmsg]="Please select ShopID"
        render :update do |page|
          page.redirect_to url_for(:controller=>'entries', :action=>'new')
        end
      elsif(params[:entry][:GroupID]=="" and @session[:Groupid]==nil)#IF SHOPID NOT SELECTED THEN
        session[:errmsg]="Please select GroupID"
        render :update do |page|
          page.redirect_to url_for(:controller=>'entries', :action=>'new')
        end
      elsif(params[:entry][:MachineName]=="" and @session[:MachineNo]==nil) #IF SHOPID NOT SELECTED THEN
        session[:errmsg]="Please select MachineNo"
        render :update do |page|
          page.redirect_to url_for(:controller=>'entries', :action=>'new')
        end
      else
        if(params[:entry][:GroupID]==nil or  params[:entry][:GroupID]=="")
          @session['shortgroupid']=@session[:Groupid]
        else
          @session['shortgroupid']=params[:entry][:GroupID]
        end
        if(params[:entry][:MachineName]==nil or params[:entry][:MachineName]=="")
          @session['shortmachinename']=@session[:MachineName]
        else
          @session['shortmachinename']=params[:entry][:MachineName]
        end
        if(params[:entry][:ShopName]=="" or params[:entry][:ShopName]==nil)
          @session['shortshop']=@session[:shopname]
        else
          @session['shortshop']=params[:entry][:ShopName]
        end
        @session['shortdate']=Date.parse(params[:entry][:Date])
        @date=Date.parse(params[:entry][:Date])
        @s=Entry.find_first(["ShopName=? and GroupID=? and MachineName=? and Date=?",@session['shortshop'],@session['shortgroupid'],@session['shortmachinename'],@date])
        if(@s!=nil)
          render :update do |page|
            page.redirect_to url_for(:controller=>'entries', :action=>'short')
          end
        else
          session[:errmsg]="Please Enter Screen Details for Shop #{@session['shortshop']} "
          render :update do |page|
            page.redirect_to url_for(:controller=>'entries', :action=>'new')
          end
        end
      end
    rescue Exception=>ex
      puts ex.message
    end
  end

  #COUNTERCOLLECTION CODE FOR CHECKING WHETHER ALL ENTRIES HAS BEEN FILLED
  #FOR THAT SHOP IF YES MAY MOVE TO COUNTER COLLECTION ADDING SCREEN
  def checkcounter
    begin
      if (params[:entry][:ShopName]=="" or params[:entry][:ShopName]==nil) and @session[:shopname]==nil #IF SHOPID NOT SELECTED THEN
        session[:errmsg]="Please select ShopID"
        render :update do |page|
          page.redirect_to url_for(:controller=>'entries', :action=>'new')
        end
      else
        if(params[:entry][:ShopName]=="" and @session[:shopname]!=nil)
          params[:entry][:ShopName]=@session[:shopname]
        end
        @mcount=Machine.count(["ShopName=?",params[:entry][:ShopName]]) #MACHINE COUNT WITH GIVEN SHOPID
        @date=Date.parse(params[:entry][:Date])
        @c =Entry.count(["ShopName=? and Date=? ",params[:entry][:ShopName],@date])  #ENTRY COUNT WITH GIVEN SHOPID AND DATE
        if(@mcount==@c and @mcount!=0 and @c!=0)
          @pcount=Previousrecord.count(["ShopName=?",params[:entry][:ShopName]])  #PREVIOUSRECORD COUNT WITH SELECTED SHOPID
          @session['shop']=params[:entry][:ShopName]
          @session['date']=params[:entry][:Date]
          if(@pcount==0)
            @session['shop']=params[:entry][:ShopName]
            @session['date']=params[:entry][:Date]
            render :update do |page|
              page.redirect_to url_for(:controller=>'previousrecords', :action=>'new')
            end
          else
            @date=Date.parse(params[:entry][:Date])
            @ccount=Countercollection.count(["ShopName=? and Date=?",params[:entry][:ShopName],@date])
            if(@ccount==0)
              @p=Previousrecord.find_first(["ShopName=?",params[:entry][:ShopName]])
              @session['credit']=@p.Xcredit
              @session['cash']=@p.Xcash
              @session['obal']=@p.Openingbal
              @session['date']=@date
              @session['sname']=params[:entry][:ShopName]
              render :update do |page|
                page.redirect_to url_for(:controller=>'countercollections', :action=>'new')
              end
            else
              @date=Date.parse(params[:entry][:Date])
              @counter=Countercollection.find_first(["ShopName=? and Date=?",params[:entry][:ShopName],@date])
              @session['sname']=@counter.ShopName
              @session['obal']=@counter.Openingbal
              @session['credit']=@counter.Credit
              @session['cash']=@counter.Cash
              @session['total1']=@counter.Cash.to_i+@counter.Exp.to_i+@counter.HC.to_i+@counter.Credit.to_i+@counter.Short_Ext.to_i
              @session['total2']=@counter.Openingbal.to_i+@counter.KEY1.to_i+@counter.KEY2.to_i+@counter.KEY3.to_i+@counter.KEY4+@counter.Outstanding.to_i
              @session['id']=@counter.id
              render :update do |page|
                page.redirect_to url_for(:controller=>'countercollections', :action=>'edit',:id=>@counter.id)
              end
            end
          end
        else
          if(@mcount==0 and @c==0)
            session[:errmsg]="NO MACHINES MAPPED TO THE SELECTED SHOP"
            render :update do |page|
              page.redirect_to url_for(:controller=>'entries', :action=>'new')
            end
          else
            render :update do |page|
              page.redirect_to url_for(:action=>'confirm')
            end
          end
        end
      end
    rescue Exception=>ex
      puts ex.message
    end
  end
   
  def backtolist
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'list')
    end  
  end

  def redirect_entrydata
    @session['msg']="Record saved successfully!"
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'list')
    end  
  end

  def entrydata
    render :update do |page|
      page.redirect_to url_for( :action=>'new')
    end  
  end

  def update_group
    @session[:shopid]=params[:ShopID]
    render :update do |page|
      page.replace_html 'shopnamediv', :partial => 'shopname'
    end
  end

  def update_machine
    begin
      @session[:MachineNo]=nil
      @session[:Groupid]=params[:GroupID]
      render :update do |page|
        page.replace_html 'MachineNodiv', :partial => 'machine'
        page.replace_html 'MachineNamediv', :partial => 'machinename'
        page << "document.getElementById('entry_MachineNo').focus();"
      end 
    rescue Exception=>ex
      ex.message
    end
  end

  def update_machinename
    begin
      @machinename=Machine.find_first(["ShopName=? and MachineNo=?",@session[:shopname],params[:MachineNo]])
      @session[:MachineNo]=params[:MachineNo]
      @session[:MachineName]=@machinename.MachineName
      render :update do |page|
        page.replace_html 'MachineNamediv', :partial => 'machinename'
        page << "document.getElementById('entry_ScreenIN').focus();"
      end
    rescue Exception=>ex
      ex.message
    end
  end

  def getGroup
    begin
      @session[:Groupid]=nil
      if(params[:ShopName]!="" or params[:ShopName]!=nil)
        @session[:shopname]=params[:ShopName]
      end
      render :update do |page|
        page.replace_html 'KeyIDdiv', :partial => 'group'
        page.replace_html 'MachineNodiv', :partial => 'machine'
        page.replace_html 'MachineNamediv', :partial => 'machinename'
        page << "document.getElementById('entry_GroupID').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end


  def modify
    begin
      @entry = Entry.find_first(["ShopID=? and GroupID=? and MachineNo=? and MachineName=?",session[:shopid],session[:Groupid],session[:machineno],session[:machinename]])
    rescue Exception=>ex
      ex.message
    end
  end

  def dataentry
    @session[:shopid]=""
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list
    @entry_pages, @entries = paginate :entries, :per_page => 10
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def new
    @entry = Entry.new
  end

  def data
    begin
      @entry = Entry.new(params[:entry])
      if @entry.save
        flash[:notice] = 'Entry was successfully created.'
        render :action=>'new'
      else
        render :action => 'new'
      end
    rescue Exception=>ex
      ex.message
    end
  end

  #METHOD WHILE CREATING A NEW ENTRY
  def create
    begin
      if params[:entry][:ScreenIN]==""
        flash[:notice]="Screen IN can't be empty"
        render :action => 'new'
      else
        if((params[:entry][:ShopName]==nil or params[:entry][:ShopName]=="") and @session[:shopname]!=nil)
          params[:entry][:ShopName]=@session[:shopname]
        end
        if((params[:entry][:GroupID]==nil or params[:entry][:GroupID]=="") and @session[:Groupid]!=nil)
          params[:entry][:GroupID]=@session[:Groupid]
        end
        if((params[:entry][:MachineNo]==nil or params[:entry][:MachineNo]=="") and @session[:MachineNo]!=nil)
          params[:entry][:MachineNo]=@session[:MachineNo]
        end
        if((params[:entry][:MachineName]==nil or params[:entry][:MachineName]=="") and @session[:MachineName]!=nil)
          params[:entry][:MachineName]=@session[:MachineName]
        end
        @entry1=Entry.find_first(["ShopName=? and GroupID=? and MachineNo=? and MachineName=? and date=?",params[:entry][:ShopName],params[:entry][:GroupID],params[:entry][:MachineNo],params[:entry][:MachineName],Date.parse(params[:entry][:Date])])
        @entry = Entry.new(params[:entry])
        if(@entry1!=nil)
          flash[:notice]="<font color=red size=3><b>DUPLICATE ENTRY FOR MACHINE No. #{params[:entry][:MachineNo]}</b></font> "
          render :action => 'new'
        else
          @cluster=Shop.find_first(["ShopName=?",params[:entry][:ShopName]])
          params[:entry][:ClusterName]=@cluster.ClusterName
          @entry = Entry.new(params[:entry])
          if @entry.save
            flash[:confirm] = '<font color=green size=3><b>Entry was successfully created.</b></font>'
            @session[:MachineNo]=nil
            @session[:MachineName]=nil
            render :action => 'new'
          else
            render :action => 'new'
          end
        end
      end
    rescue Exception=>ex
      ex.message
    end
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = 'Entry was successfully updated.'
      redirect_to :action=>'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Entry.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def canceladd
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'list')
    end
  end

  def cancelentry
    render :update do |page|
      page.redirect_to url_for(:controller=>'entries', :action=>'new')
    end
  end
end
