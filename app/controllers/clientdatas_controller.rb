  class ClientdatasController < ApplicationController
    layout 'adminlayout'
    require 'chronic'
    #  require 'ruby-debug'
    before_filter :login_required

    def showreadingmistakes
      session[:ttdate1]=params[:date1]
      @session[:crname]=params[:machinedata][:ClusterName]
    end

    def index
      list
      render :action => 'list'
    end

    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify :method => :post, :only => [ :destroy, :create, :update ],
      :redirect_to => { :action => :list }

    def list
      @clientdata_pages, @clientdatas = paginate :clientdatas, :per_page => 10
    end

    def show
      @clientdata = Clientdata.find(params[:id])
    end

    def new
      @clientdata = Clientdata.new
    end

    #METHOD WHILE CREATING A NEW clientdata
    def create
      @time=Time.now().strftime("%H:%M:%S")
      @stime=@time.split(":")
      @totalsec=@stime[0].to_i*3600+@stime[1].to_i*60+@stime[2].to_i
      render :update do |page|
        if params[:clientdata][:ScreenIN]==""
          page.replace_html 'clientdata_div', :partial => 'clientdatas_new'
        else
          if((params[:clientdata][:ShopName]==nil or params[:clientdata][:ShopName]=="") and @session[:shopname]!=nil)
            params[:clientdata][:ShopName]=@session[:shopname]
          end

          if((params[:clientdata][:GroupID]==nil or params[:clientdata][:GroupID]=="") and @session[:Groupid]!=nil)
            params[:clientdata][:GroupID]=@session[:Groupid]
          end

          if((params[:clientdata][:MachineNo]==nil or params[:clientdata][:MachineNo]=="") and @session[:MachineNo]!=nil)
            params[:clientdata][:MachineNo]=@session[:MachineNo]
          end
          if((params[:clientdata][:MachineName]==nil or params[:clientdata][:MachineName]=="") and @session[:MachineName]!=nil)
            params[:clientdata][:MachineName]=@session[:MachineName]
          end
          @count=Machine.count(:conditions=>["GroupID=? and ShopName=? and MachineNo=? and MachineName=?",
              params[:clientdata][:GroupID],
              params[:clientdata][:ShopName],
              params[:clientdata][:MachineNo],
              params[:clientdata][:MachineName]])
          if @count.to_i!=0
            @date=Date.parse(params[:clientdata][:Date])
            @duprecord=Clientdata.find_first(["ShopName=? and GroupID=? and MachineNo=?  and  date=?",
                params[:clientdata][:ShopName],
                params[:clientdata][:GroupID],
                params[:clientdata][:MachineNo],
                @date])
            if(@duprecord!=nil)
              @dtime=@duprecord.Created_Time.strftime("%H:%M:%S").split(":")
              @totalsecd=@dtime[0].to_i*3600+@dtime[1].to_i*60+@dtime[2].to_i
              if( (@totalsec.to_i-@totalsecd.to_i).to_i<=1 )
                page.replace_html 'clientdata_div', :partial => 'clientdatas_new'
              else
                page.redirect_to url_for(:controller=>'clientdatas',:action=>'confirmduplicate')
              end
            else
              @cluster=Shop.find_first(["ShopName=?",params[:clientdata][:ShopName]])
              params[:clientdata][:ClusterName]=@cluster.ClusterName
              params[:clientdata][:Created_Time]=@time
              @clientdata = Clientdata.new(params[:clientdata])
              @mno=@session[:MachineNo]
              if @clientdata.save
                @session[:MachineNo]=nil
                @session[:MachineName]=nil
                page.replace_html 'clientdata_div', :partial => 'clientdatas_new'
                page << "jQuery('#loader').hide();"
                page << "document.getElementsByName('save')[0].disabled = 1;"
                page << "document.getElementById('clientdata_MachineNo').focus();"
                page << "document.getElementById('clientdata_MachineName').value = '';"

              else
                page.replace_html 'clientdata_div', :partial => 'clientdatas_new'
              end
            end
          else
            page.replace_html 'clientdata_div', :partial => 'clientdatas_new'
          end
        end
      end
    end


    def update_machine
      begin
        @session[:MachineNo]=nil
        @session[:MachineName]=nil
        @session[:Groupid]=params[:GroupID]
        render :update do |page|
          page.replace_html 'MachineNodiv', :partial => 'machine'
          page.replace_html 'MachineNamediv', :partial => 'machinename'
          page << "document.getElementById('clientdata_MachineNo').focus();"
        end

      rescue Exception=>ex
        puts ex.message()
      end
    end
    def update_machineprev
      begin

        @session[:MachineNo]=nil
        puts params[:GroupID]
        @session[:Groupid]=params[:GroupID]
        render :update do |page|
          page.replace_html 'MachineNodiv', :partial => 'machineprev'
          page.replace_html 'MachineNamediv', :partial => 'machinenameprev'
          page << "document.getElementById('clientdata_MachineNo').focus();"
        end

      rescue Exception=>ex
        puts ex.message()
      end
    end



    def update_machinename
      begin
        if(params[:MachineNo]!=nil)
          @machinename=Machine.find_first(["ShopName=? and GroupID=? and MachineNo=?",@session[:shopname],@session[:Groupid],params[:MachineNo]])
        else
          @machinename=Machine.find_first(["ShopName=? and GroupID=? and MachineNo=?",@session[:shopname],@session[:Groupid],@session[:mcno]])
        end
        if(@machinename==nil)
          render :update do |page|
            page.alert("No Machine Found")
            @session[:mcno]=nil
            page << "document.getElementById('clientdata_MachineNo').options[0].value='';"
            page << "document.getElementById('clientdata_MachineNo').options[0].text='';"
            page << "document.getElementById('clientdata_MachineNo').focus();"
          end
        else
          render :update do |page|
            if(params[:MachineNo]!=nil)
              @session[:MachineNo]=params[:MachineNo]
              page << "document.getElementById('clientdata_MachineNo').options[0].value='';"
              page << "document.getElementById('clientdata_MachineNo').options[0].text='';"
            else
              @session[:MachineNo]=@session[:mcno]
            end
            @session[:MachineName]=@machinename.MachineName
            page.replace_html 'MachineNamediv', :partial => 'machinename'
            page << "document.getElementById('clientdata_ScreenIN').focus();"
          end
        end
      rescue Exception=>ex
        puts ex.message
      end
    end


    def showmc
      @session[:mcno]=params[:MachineNo]
    end

    ########CHECK FOR MACHINENO IF CLICKED ON SCREEN IN#####################
    def checkmachineno
      if(params[:MachineNo]!=nil)
        @machinename=Machine.find_first(["ShopName=? and GroupID=? and MachineNo=?",@session[:shopname],@session[:Groupid],params[:MachineNo]])
      else
        @machinename=Machine.find_first(["ShopName=? and GroupID=? and MachineNo=?",@session[:shopname],@session[:Groupid],@session[:mcno]])
      end
      if(@machinename==nil)
        render :update do |page|
          page.alert("No Machine Found")
          @session[:mcno]=nil
          page << "document.getElementById('clientdata_MachineNo').options[0].value='';"
          page << "document.getElementById('clientdata_MachineNo').options[0].text='';"
          page << "document.getElementById('clientdata_MachineNo').focus();"
        end
      else
      end
    end


    def update_machinenameprev
      begin
        @machinename=Machine.find_first(["ShopName=? and MachineNo=?",@session[:shopname],params[:MachineNo]])
        @session[:MachineNo]=params[:MachineNo]
        @session[:MachineName]=@machinename.MachineName
        render :update do |page|
          page.replace_html 'MachineNamediv', :partial => 'machinenameprev'
          page << "document.getElementById('clientdata_ScreenIN').focus();"
        end
      rescue Exception=>ex
        puts ex.message
      end
    end

    def getGroup
      begin
        @session[:Groupid]=nil
        @session[:MachineName]=nil
        if(params[:ShopName]!="" )
          @session[:shopname]=params[:ShopName]
        end
        render :update do |page|
          page.replace_html 'KeyIDdiv', :partial => 'group'
          page.replace_html 'MachineNodiv', :partial => 'machine'
          page.replace_html 'MachineNamediv', :partial => 'machinename'
          page << "document.getElementById('clientdata_GroupID').focus();"
        end
      rescue Exception=>exc
        puts exc.message
      end
    end


    def getGroupprev
      begin
        if (params[:ShopName]=='SHOP1')
        end
        @session[:Groupid]=nil
        if(params[:ShopName]!="" )
          @session[:shopname]=params[:ShopName]
        end
        render :update do |page|
          page.replace_html 'KeyIDdiv', :partial => 'groupprev'
          page.replace_html 'MachineNodiv', :partial => 'machineprev'
          page.replace_html 'MachineNamediv', :partial => 'machinenameprev'
          page << "document.getElementById('clientdata_GroupID').focus();"
        end
      rescue Exception=>exc
        puts exc.message
      end
    end

    def edit
      @clientdata=Clientdata.find(:first,:conditions=>["ShopName=? and GroupID=? and MachineNo=? and Date='#{@session['date']}'",@session[:shopname],@session[:Groupid],session['machime_no']])
      @clientdata = Clientdata.find(@clientdata.id)
    end

    def update
      @clientdata1=Clientdata.find(:first,:conditions=>["ShopName=? and GroupID=? and MachineName=? and MachineNo=? and Date='#{@session['date']}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])
      @clientdata = Clientdata.find(@clientdata1.id)
      if(params[:clientdata][:ScreenIN]=="" or params[:clientdata][:ScreenOUT]=="" or params[:clientdata][:MeterIN]=="" or params[:clientdata][:MeterOUT]=="")
        render :update do |page|
          page.alert("PLEASE ENTER DATA")
        end
      else
        if @clientdata.update_attributes(params[:clientdata])
          render :update do |page|
            page.alert("ENTRY UPDATED SUCCESSFULLY")
            page.redirect_to url_for(:controller=>'clientdatas',:action=>'new')
          end
        end
      end
    end

    def destroy
      @clientdata=Clientdata.find(:first,:conditions=>["ShopName=? and GroupID=? and MachineName=? and MachineNo=? and Date='#{@session['date']}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])
      Clientdata.find(@clientdata.id).destroy
      render :update do |page|
        page.alert("ENTRY DELETED SUCCESSFULLY")
        page.redirect_to url_for(:controller=>'clientdatas',:action=>'new')
      end
    end

    def backtolist
      @session['date']=Date.parse(params[:clientdata][:Date])
      session['machime_no'] = params[:clientdata][:MachineNo]
      if params[:clientdata][:MachineNo]==nil || params[:clientdata][:MachineNo]==""
        render :update do |page|
          page.alert("PLEASE SELECT MACHINENO")
          page << "document.getElementById('clientdata_MachineNo').focus();"
        end
      else
        @clientdata = Clientdata.find(:first,
          :conditions=>["ShopName=? and GroupID=? and MachineNo=? and Date='#{@session['date']}'",@session[:shopname],@session[:Groupid],params[:clientdata][:MachineNo]])
        if(@clientdata!=nil)
          @clientdata = Clientdata.find(@clientdata.id)
          abc = Countercollection.find_by_sql("select count(*) as countcheck from countercollections where shopname='#{@clientdata.ShopName}' and date='#{@session['date']}'")
          if abc[0].countcheck.to_i == 0
            render :update do |page|
              page.redirect_to url_for(:controller=>'clientdatas', :action=>'edit')
            end
          else
            render :update do |page|
              page.alert("DATA ALREADY SUBMITED CAN NOT EDIT")
            end
          end
        else
          render :update do |page|
            page.alert("NO RECORD FOUND FOR SELECTED MACHINE")
          end
        end
      end
    end


    def canceladd
      render :update do |page|
        page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
      end
    end

    #SHORT REASON CODE FOR ENTRING THE SHORTS FOR SPECIFIC MACHINE
    def checkshort
      begin
        if(params[:clientdata][:ShopName]=="" and @session[:shopname]==nil) #IF SHOPID NOT SELECTED THEN
          session[:errmsg]="Please select ShopID"
          render :update do |page|
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        elsif(params[:clientdata][:GroupID]=="" and @session[:Groupid]==nil)#IF SHOPID NOT SELECTED THEN
          session[:errmsg]="Please select GroupID"
          render :update do |page|
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        elsif(params[:clientdata][:MachineName]=="" or @session[:MachineNo]==nil or params[:clientdata][:MachineNo]=="" ) #IF SHOPID NOT SELECTED THEN
          session[:errmsg]="Please Select MachineNo"
          render :update do |page|
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        else
          if(params[:clientdata][:GroupID]==nil or  params[:clientdata][:GroupID]=="")
            @session['shortgroupid']=@session[:Groupid]
          else
            @session['shortgroupid']=params[:clientdata][:GroupID]
          end

          if(params[:clientdata][:MachineName]==nil or params[:clientdata][:MachineName]=="")
            @session['shortmachinename']=@session[:MachineName]
          else
            @session['shortmachinename']=params[:clientdata][:MachineName]
          end

          if(params[:clientdata][:ShopName]=="" or params[:clientdata][:ShopName]==nil)
            @session['shortshop']=@session[:shopname]
          else
            @session['shortshop']=params[:clientdata][:ShopName]
          end
          @session['shortmachineno']=params[:clientdata][:MachineNo]
          @session['shortdate']=Date.parse(params[:clientdata][:Date])
          @date=Date.parse(params[:clientdata][:Date])
          @s=Clientdata.find_first(["ShopName=? and GroupID=? and MachineNo=? and Date=?",@session['shortshop'],@session['shortgroupid'],@session['shortmachineno'],@date])
          if(@s!=nil)
            @abc = Countercollection.find_by_sql("select count(*) as countcheck from countercollections where shopname='#{@session['shortshop']}' and date='#{@session['date']}'")
            if @abc[0].countcheck.to_i == 0
              render :update do |page|
                page.redirect_to url_for(:controller=>'clientdatas', :action=>'short')
              end
            else
              render :update do |page|
                page.alert("DATA ALREADY SUBMITED CAN NOT EDIT")
              end
            end
          else
            session[:errmsg]="Reading Missing in Data Entry Screen."
            render :update do |page|
              page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
            end
          end

        end
      rescue Exception=>ex
        puts ex.message
      end

    end

    def saveshort
      begin
        @s=Clientdata.find_first(["ShopName=? and GroupID=? and MachineNo=? and MachineName=? and Date=?",@session['shortshop'],@session['shortgroupid'],@session['shortmachineno'],@session['shortmachinename'],@session['shortdate']])
        if(@s!=nil)
          if(params[:clientdata][:Machineshort]==nil)
            session[:errmsg]="Please select ShopID"
            redirect_to :controller=>'clientdatas',:action => 'short'
          elsif(params[:clientdata][:Shortreason]==nil)
            session[:errmsg]="Please select ShopID"
            render :update do |page|
              page.redirect_to url_for(:controller=>'clientdatas', :action=>'short')
            end
          else
            begin
              @short=params[:clientdata][:Machineshort].to_i/10
              @s.Machineshort="-#{@short}"
              @s.Shortreason=params[:clientdata][:Shortreason]
              @s.save
            rescue Exception=>ex
              puts ex.message()
            end
            redirect_to :controller=>'clientdatas',:action => 'new'
          end
        else
          render :update do |page|
            page.alert("Please Enter its details first")
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        end
      rescue Exception=>ex
        puts ex.message
      end
    end

    def entrydata
      render :update do |page|
        page.redirect_to url_for( :action=>'new')
      end
    end

    #COUNTERCOLLECTION CODE FOR CHECKING WHETHER ALL ENTRIES HAS BEEN FILLED
    #FOR THAT SHOP IF YES MAY MOVE TO COUNTER COLLECTION ADDING SCREEN
    def checkcounter
      begin
        if (params[:clientdata][:ShopName]=="" or params[:clientdata][:ShopName]==nil) and @session[:shopname]==nil #IF SHOPID NOT SELECTED THEN
          session[:errmsg]="Please select ShopID"
          render :update do |page|
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        else
          if(params[:clientdata][:ShopName]=="" and @session[:shopname]!=nil)
            params[:clientdata][:ShopName]=@session[:shopname]
          end
          ########CHECK MACHINE COUNT ###########################
          @mcount=Machine.count(["ShopName=?",params[:clientdata][:ShopName]]) #MACHINE COUNT WITH GIVEN SHOPID
          @date=Date.parse(params[:clientdata][:Date])
          @c=Clientdata.find_by_sql("select count(distinct Machineno) as mccount from clientdatas where ShopName='#{params[:clientdata][:ShopName]}' and Date='#{@date}' and status=0")
          #########CHECK WHETHER MACHINE COUNT AND ENTRY COUNT MATCHING OR NOT
          if(@mcount==@c[0].mccount.to_i and @mcount!=0 and @c[0].mccount.to_i!=0)

            #########IF DATA IS ENTRED ALL THEN FOR RECORD PRESENT IN PREVIOUS RECORD OR NOT
            @pcount=Previousrecord.count(["ShopName=?",params[:clientdata][:ShopName]])  #PREVIOUSRECORD COUNT WITH SELECTED SHOPID
            @session['shop']=params[:clientdata][:ShopName]
            @session['date']=params[:clientdata][:Date]

            if(@pcount==0)
              @session['shop']=params[:clientdata][:ShopName]
              @session['date']=params[:clientdata][:Date]
              render :update do |page|
                page.redirect_to url_for(:controller=>'previousrecords', :action=>'new')
              end
            else
              #####CHECK FOR COUNTER COLLECTION COUNT #######################
              @date=Date.parse(params[:clientdata][:Date])
              @ccount=Countercollection.count(["ShopName=? and Date=?",params[:clientdata][:ShopName],@date])
              if(@ccount==0)
                @p1=Countercollection.find_by_sql("select Cash as 'cash',Credit as 'credit' from countercollections where Date<'#{@date}'and ShopName='#{params[:clientdata][:ShopName]}' order by Date desc limit 1")
                if(@p1[0]!=nil)
                  @session['credit']=@p1[0].credit
                  @session['cash']=@p1[0].cash
                  @session['obal']=@p1[0].credit.to_i+@p1[0].cash.to_i
                else
                  @p=Previousrecord.find_first(["ShopName=?",params[:clientdata][:ShopName]])

                  @session['credit']=@p.Xcredit
                  @session['cash']=@p.Xcash
                  @session['obal']=@p.Xcredit.to_i+@p.Xcash.to_i
                end
                @session['date']=@date
                @session['sname']=params[:clientdata][:ShopName]
                render :update do |page|
                  page.redirect_to url_for(:controller=>'countercollections', :action=>'new')
                end
              else
                @date=Date.parse(params[:clientdata][:Date])
                @counter=Countercollection.find_first(["ShopName=? and Date=?",params[:clientdata][:ShopName],@date])
                @session['sname']=@counter.ShopName
                @p=Countercollection.find_by_sql("select Cash as 'cash',Credit as 'credit' from countercollections where Date<'#{@date}'and ShopName='#{params[:clientdata][:ShopName]}' order by Date desc limit 1")
                if(@p[0]!=nil)
                  @session['credit']=@p[0].credit
                  @session['cash']=@p[0].cash
                  @session['obal']=@p[0].credit.to_i+@p[0].cash.to_i
                else
                  @p=Previousrecord.find_first(["ShopName=?",params[:clientdata][:ShopName]])
                  @session['credit']=@p.Xcredit
                  @session['cash']=@p.Xcash
                  @session['obal']=@p.Xcredit.to_i+@p.Xcash.to_i
                end
                @session['total1']=@counter.Cash.to_i+@counter.Exp.to_i+@counter.HC.to_i+@counter.Credit.to_i+@counter.Short_Ext.to_i
                @session['total2']=@counter.Openingbal.to_i+@counter.KEY1.to_i+@counter.KEY2.to_i+@counter.KEY3.to_i+@counter.KEY4+@counter.Outstanding.to_i
                @session['id']=@counter.id
                @abc = Countercollection.find_by_sql("select count(*) as countcheck from countercollections where shopname='#{@session['shop']}' and date='#{@date}'")
                if @abc[0].countcheck.to_i == 0
                  render :update do |page|
                    page.redirect_to url_for(:controller=>'countercollections', :action=>'edit',:id=>@counter.id)
                  end
                else
                  render :update do |page|
                    page.alert("DATA ALREADY SUBMITED CAN NOT EDIT")
                  end
                end

              end
            end
          else
            if(@mcount==0 and @c==0)
              session[:errmsg]="NO MACHINES MAPPED TO THE SELECTED SHOP"
              render :update do |page|
                page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
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

    def checkcounter111
      begin
        if (params[:clientdata][:ShopName]=="" or params[:clientdata][:ShopName]==nil) and @session[:shopname]==nil #IF SHOPID NOT SELECTED THEN
          session[:errmsg]="Please select ShopID"
          render :update do |page|
            page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
          end
        else
          if(params[:clientdata][:ShopName]=="" and @session[:shopname]!=nil)
            params[:clientdata][:ShopName]=@session[:shopname]
          end
          @mcount=Machine.count(["ShopName=?",params[:clientdata][:ShopName]]) #MACHINE COUNT WITH GIVEN SHOPID
          @date=Date.parse(params[:clientdata][:Date])
          @c =Clientdata.count(["ShopName=? and Date=? ",params[:clientdata][:ShopName],"#{@date}"])  #ENTRY COUNT WITH GIVEN SHOPID AND DATE
          if(@mcount==@c and @mcount!=0 and @c!=0)
            @date=Date.parse(params[:clientdata][:Date])
            @ccount=Countercollection.count(["ShopName=? and Date=?",params[:clientdata][:ShopName],@date])
            if(@ccount==0)
              @p=Shop.find_first(["ShopName=?",params[:clientdata][:ShopName]])
              @session['shop']=@p.ShopName
              @session['credit']=@p.Credit
              @session['cash']=@p.Cash
              #@session['obal']=@p.Xcredit.to_i+@p.Xcash.to_i
              @session['obal']=@p.OpeningBal
              @session['date']=@date
              @session['sname']=params[:clientdata][:ShopName]
              render :update do |page|
                page.redirect_to url_for(:controller=>'countercollections', :action=>'new')
              end
            else
              @date=Date.parse(params[:clientdata][:Date])
              @counter=Countercollection.find_first(["ShopName=? and Date=?",params[:clientdata][:ShopName],@date])
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
          else
            if(@mcount==0 and @c==0)
              session[:errmsg]="NO MACHINES MAPPED TO THE SELECTED SHOP"
              render :update do |page|
                page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
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


    def missingrecordslist
      if(params[:clientdata][:ShopName]==""  and @session[:shopname]==nil)
        session[:errmsg]="Please select ShopName"
        render :update do |page|
          page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
        end
      else
        if(params[:clientdata][:ShopName]=="")
          @session['shop']=@session[:shopname]
        else
          @session['shop']=params[:clientdata][:ShopName]
        end
        @session['date']=params[:clientdata][:Date]
        @session['date']=Date.parse(@session['date'])
        puts
        render :update do |page|
          page.redirect_to url_for(:controller=>'clientdatas', :action=>'missingrecords')
        end
      end
    end

    def cancelentry
      render :update do |page|
        page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
      end
    end

    def showdata
      session[:testval]=params[:datevalue]
      render :update do |page|
        page.replace_html('griddisp',:partial=>'edetails')
      end
    end

    #DATA WILL BE SEND TO SERVER AND DUMPPED IN .SQL BACKUP FILE
    def createdata
      @result=User.login_type(@session['uname'],@session['pass'])
      begin
        render :update do |page|
          shopval=params[:clientdatas][:ShopName]
          for i in 0..shopval.length-1
            times=((Time.now().strftime("%H:%M:%S")).to_s).split(':')
            @con=Configuration.find(1)
            @folderpath=@con.FilesFolderPath
            if times[0].to_i>=@con.noofhours.to_i
              date=Date.today.strftime("%Y%m%d")
            else
              date=(Date.today-1).strftime("%Y%m%d")
            end
            fname="#{shopval[i]}_"+Date.parse(session[:dateval]).strftime("%Y%m%d")+".csv"
            total=0
            count=0
            @t= Clientdata.find(:all,:conditions=>["ShopName in (?) and status=0 and date=? ",shopval[i],session[:dateval]])
            FasterCSV.open(fname, "w") do |csv|
              for sname in @t
                @a=[sname.ClusterName,sname.ShopName,sname.Date,sname.GroupID,sname.MachineNo,sname.ScreenIN,sname.ScreenOUT,sname.MeterIN,sname.MeterOUT,sname.Machineshort,sname.Shortreason,sname.status,';']
                csv<< @a
              end
            end
            total=0
            count=0
            @t= Countercollection.find(:all,:conditions=>["ShopName in (?) and status=0 and date=? ",shopval[i],session[:dateval]])

            FasterCSV.open(fname, "a") do |csv|
              csv<< "COUNTER"
              for cdata in @t
                @a=[cdata.ClusterName,cdata.ShopName,cdata.Date,cdata.Cash,cdata.Exp,cdata.HC,cdata.Credit,cdata.Short_Ext,cdata.Openingbal,cdata.KEY1,cdata.KEY2,cdata.KEY3,cdata.KEY4,cdata.Outstanding,cdata.status,cdata.Total,';']
                csv<< @a
              end
            end

            pw=Dir.pwd()
            Dir.chdir(pw)
            filename=pw.to_s+"/"+fname
            begin
              if File.directory?("#{@folderpath}")
                FileUtils.copy(filename, "#{@folderpath}")
                FileUtils.rm_r(filename)
              else
                FileUtils.mkdir_p "#{@folderpath}"
                FileUtils.copy(filename, "#{@folderpath}")
              end
            rescue Exception=>ex
              puts ex.message()
            end
            @statusflag= Clientdata.find(:all,:conditions=>["ShopName in (?) and status=0 and date=?",shopval[i],session[:dateval]])
            @statusflag.each do |c|
              c.status=1
              c.save
            end
            @counterstatusflag= Countercollection.find(:all,:conditions=>["ShopName in (?) and status=0 and date=?",shopval[i],session[:dateval]])
            @counterstatusflag.each do |c|
              c.status=1
              c.save
            end
          end
          page.alert("FILE HAS BEEN CREATED SUCCESSFULLY")
          page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
        end
      rescue Exception=>ex
        puts ex.message
      end
    end


    #METHOD WHILE CREATING A NEW clientdata
    def createpreviousdata
      if params[:clientdata][:ScreenIN]==""
        flash[:notice]="Screen IN can't be empty"
        render :action => 'previousdata'
      else
        if((params[:clientdata][:ShopName]==nil or params[:clientdata][:ShopName]=="") and @session[:shopname]!=nil)
          params[:clientdata][:ShopName]=@session[:shopname]
        end
        if((params[:clientdata][:GroupID]==nil or params[:clientdata][:GroupID]=="") and @session[:Groupid]!=nil)
          params[:clientdata][:GroupID]=@session[:Groupid]
        end
        if((params[:clientdata][:MachineNo]==nil or params[:clientdata][:MachineNo]=="") and @session[:MachineNo]!=nil)
          params[:clientdata][:MachineNo]=@session[:MachineNo]
        end
        if((params[:clientdata][:MachineName]==nil or params[:clientdata][:MachineName]=="") and @session[:MachineName]!=nil)
          params[:clientdata][:MachineName]=@session[:MachineName]
        end
        @date=Date.parse(params[:date])
        if(@session[:prevdate]==nil)
          @date=Date.parse(params[:date])
          @session[:prevdate]=@date
        else
          @date=@session[:prevdate]
        end
        @duprecord=Machinedata.find_first(["Shop_Name=? and Group_ID=? and Machine_No=? and Machine_Name=?  and trans_date=?",params[:clientdata][:ShopName],params[:clientdata][:GroupID],params[:clientdata][:MachineNo],params[:clientdata][:MachineName],@date])
        if(@duprecord!=nil)
          flash[:notice]="<font color=red size=4><b>DUPLICATE PREVIOUS DATA ENTRY FOR MACHINE No. #{params[:clientdata][:MachineNo]}</b></font> "
          render :action => 'previousdata'
        else
          @cluster=Shop.find_first(["ShopName=?",params[:clientdata][:ShopName]])
          params[:clientdata][:ClusterName]=@cluster.ClusterName
          @data=Machinedata.new
          @data.CLUSTER_NAME=params[:clientdata][:ClusterName]
          @data.SHOP_NAME=params[:clientdata][:ShopName]
          @data.GROUP_ID=params[:clientdata][:GroupID]
          @data.TRANS_DATE=params[:date]
          @data.MACHINE_NO=params[:clientdata][:MachineNo]
          @data.MACHINE_NAME=params[:clientdata][:MachineName]
          @data.SRIN=0
          @data.SROUT=0
          @data.MTRIN=0
          @data.MTROUT=0
          @data.PSRINVALUE=params[:clientdata][:ScreenIN]
          @data.PSROUTVALUE=params[:clientdata][:ScreenOUT]
          @data.PMTRINVALUE=params[:clientdata][:MeterIN]
          @data.PMTROUTVALUE=params[:clientdata][:MeterOUT]
          @data.LASTSETTING="A"
          @data.SETTING=params[:clientdata][:Setting]+" " +@date.strftime("%d/%m").to_s
          if @data.save
            flash[:confirm] = '<font color=green size=4><b>PREVIOUS DATA ENTRY WAS SUCCESSFULLY CREATED.</b></font>'
            params[:clientdata][:ScreenIN]=""
            @session[:MachineNo]=nil
            @session[:MachineName]=nil
            render :action => 'previousdata'
          else
            render :action => 'previousdata'
          end
        end
      end
    end

    def checkupdate
    end

    def resetdata
      @s=Clientdata.find_first(["ShopName=? and GroupID=? and MachineNo=? and Date='#{@session['shortdate']}'",@session['shortshop'],@session['shortgroupid'],@session['shortmachineno']])
      @s.Machineshort=0
      @s.Shortreason=""
      @s.save
      render :update do |page|
        page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
      end
    end

  end
