require 'csv'
class MachinedataController < ApplicationController
  layout 'adminlayout'
#  before_filter :login_required,:machine_and_key_collection
#  require 'ruby-debug'
  

  class Time
    def yesterday
      self - 86400
    end
  end
  ################EDIT PREVIOUS RECORD#####################
  def datavalue
  end
  def editprev
    begin
      if(@session[:prevdate]==nil)
        @date=Date.parse(params[:date])
        @session[:prevdate]=@date
      else
        @date=Date.parse(params[:date])  
        @session[:prevdate]=@date
      end
      if(params[:clientdata][:MachineNo]==nil or params[:clientdata][:MachineNo]=="")
        render :update do |page|
          page.alert("PLEASE SELECT MACHINENO")
          page << "document.getElementById('clientdata_MachineNo').focus();"
        end
      else
        @clientdata=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@date}'",@session[:shopname],@session[:Groupid],@session[:MachineName],params[:clientdata][:MachineNo]])        
        if(@clientdata!=nil)
          @clientdata = Machinedata.find(@clientdata.id)
          render :update do |page|
            page.redirect_to url_for(:controller=>'machinedata', :action=>'edit')
          end
        else
          render :update do |page|
            page.alert("NO RECORD FOUND FOR SELECTED MACHINE")
          end
        end
      end
    rescue Exception=>ex
      puts ex.message()
    end
  end
  def edit
    @clientdata=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@session[:prevdate]}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])
    @clientdata = Machinedata.find(@clientdata.id)
  end
  def update
    @clientdata1=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@session[:prevdate]}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])        
    @clientdata = Machinedata.find(@clientdata1.id)
    if(params[:clientdata][:PSRINVALUE]=="" or params[:clientdata][:PSROUTVALUE]=="" or params[:clientdata][:PMTRINVALUE]=="" or params[:clientdata][:PMTROUTVALUE]=="")
      render :update do |page|
        page.alert("PLEASE ENTER DATA")
      end
    else
      if @clientdata.update_attributes(params[:clientdata])
        render :update do |page|
          page.alert("ENTRY UPDATED SUCCESSFULLY")
          page.redirect_to url_for(:controller=>'clientdatas',:action=>'previousdata')
        end
      end
    end
  end
    
  def canceladd
    render :update do |page|
      page.redirect_to url_for(:controller=>'clientdatas', :action=>'previousdata')
    end
  end
    
  def getShop
    begin
      if(params[:ClusterName]!="" or params[:ClusterName]!=nil)
        @session[:ttclustername]=params[:ClusterName]
      end
      @session[:ttshopname]=nil
      render :update do |page|
        page.replace_html 'Shopdiv', :partial => 'shop'
        page << "document.getElementById('machinedata_ShopName').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end

  def setShop
    begin
      if(params[:ShopName]!="" or params[:ShopName]!=nil)
        @session[:ttshopname]=params[:ShopName]
      end
      @session[:ttmachineno]=nil
      render :update do |page|
        page << "document.getElementById('MachineNo').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end

  def getMachine
    begin
      if(params[:MachineNo]!="" or params[:MachineNo]!=nil)
        @session[:ttmachineno]=params[:MachineNo]
      end
      render :update do |page|
        page << "document.getElementById('save').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end

  def showdailydata
    @session[:ttmachineno]=params[:MachineNo]
    @session[:ttdate]=params[:date]
    @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    if(@machinedata!=nil)
      @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
      @totalcoll=0
      @colldata.each do |data|
        if data.CALCULATEBY=='S'
          @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
          @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end
      end
      @session[:ttCOLL1]=@totalcoll
      @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
      @totalcoll=0
      @colldata.each do |data|
        if data.CALCULATEBY=='S'
          @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
          @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end
      end
      @session[:ttCOLL2]=@totalcoll
      @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
      @totalcoll=0
      @colldata.each do |data|
        if data.CALCULATEBY=='S'
          @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
          @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end
      end
      @session[:ttCOLL3]=@totalcoll
      @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
      @totalcoll=0
      @colldata.each do |data|
        if data.CALCULATEBY=='S'
          @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
          @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end
      end
      @session[:ttCOLL4]=@totalcoll
      @keycoll=Counterdata.find(:first,:conditions=>["ClusterName=? and ShopName=? and DATE=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
      if(@keycoll!=nil)
        if(@session[:ttkeyno]=="KEY 1")
          @session[:ttKEYCOLL]=@keycoll.KEY1
        end
        if(@session[:ttkeyno]=="KEY 2")
          @session[:ttKEYCOLL]=@keycoll.KEY2
        end
        if(@session[:ttkeyno]=="KEY 3")
          @session[:ttKEYCOLL]=@keycoll.KEY3
        end
        if(@session[:ttkeyno]=="KEY 4")
          @session[:ttKEYCOLL]=@keycoll.KEY4
        end
      end
      redirect_to  :action=>'showmachinedata'
    else
      flash[:notice] ='<font color=red size=3><b>No Record found.</b></font>'
      render :action=>'dailydata'
    end
  end

  def showmachinedata_new_single
    if params[:commit].eql?("Show Machine Data")
          @session[:ttmachineno]=params[:MachineNo]
          @session[:ttdate]=params[:date]

          @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
          if(@machinedata!=nil)
            @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
            @totalcoll=0
            @colldata.each do |data|
              if data.CALCULATEBY=='S'
                @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              end
            end
            @session[:ttCOLL1]=@totalcoll
            @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
            @totalcoll=0
            @colldata.each do |data|
              if data.CALCULATEBY=='S'
                @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              end
            end
            @session[:ttCOLL2]=@totalcoll
            @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
            @totalcoll=0
            @colldata.each do |data|
              if data.CALCULATEBY=='S'
                @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              end
            end
            @session[:ttCOLL3]=@totalcoll
            @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
            @totalcoll=0
            @colldata.each do |data|
              if data.CALCULATEBY=='S'
                @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
              end
            end
            @session[:ttCOLL4]=@totalcoll
            @keycoll=Counterdata.find(:first,:conditions=>["ClusterName=? and ShopName=? and DATE=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
            if(@keycoll!=nil)
              if(@session[:ttkeyno]=="KEY 1")
                @session[:ttKEYCOLL]=@keycoll.KEY1
              end
              if(@session[:ttkeyno]=="KEY 2")
                @session[:ttKEYCOLL]=@keycoll.KEY2
              end
              if(@session[:ttkeyno]=="KEY 3")
                @session[:ttKEYCOLL]=@keycoll.KEY3
              end
              if(@session[:ttkeyno]=="KEY 4")
                @session[:ttKEYCOLL]=@keycoll.KEY4
              end
            end
      #      redirect_to  :action=>'showmachinedata'
          @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
          @totalcoll=0
          @colldata.each do |data|
            if data.CALCULATEBY=='S'
              @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            else
              @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            end
          end
          @session[:ttCOLL1]=@totalcoll
          @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
          @totalcoll=0
          @colldata.each do |data|
            if data.CALCULATEBY=='S'
              @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            else
              @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            end
          end
          @session[:ttCOLL2]=@totalcoll
          @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
          @totalcoll=0
          @colldata.each do |data|
            if data.CALCULATEBY=='S'
              @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            else
              @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            end
          end
          @session[:ttCOLL3]=@totalcoll
          @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
          @totalcoll=0
          @colldata.each do |data|
            if data.CALCULATEBY=='S'
              @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
            else
              @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i)).round
            end
          end
          @session[:ttCOLL4]=@totalcoll
          begin
            @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
            @session[:ttkeyno]=@machinedata.GROUP_ID
          rescue Exception=>ex
            puts ex.message
          end
          else
            flash[:notice] ='<font color=red size=3><b>No Record found.</b></font>'
      #      render :action=>'dailydata'
          end
    else
      render :action=>'showmachinedata'
    end

  end


  def showmachinedata
#raise params[:machinedata][:ShopName].inspect

#collection_data = machine_and_key_collection(params[:machinedata][:ClusterName],params[:machinedata][:ShopName],params[:MachineNo],params[:date])
# -----------------------------------------------------------------------------------------------------------------------------------------


    @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
      if data.CALCULATEBY=='S'
        @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      else
        @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      end
    end
    @session[:ttCOLL1]=@totalcoll
    @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
      if data.CALCULATEBY=='S'
        @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      else
        @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      end
    end
    @session[:ttCOLL2]=@totalcoll
    @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
      if data.CALCULATEBY=='S'
        @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      else
        @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      end
    end
    @session[:ttCOLL3]=@totalcoll
    @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
      if data.CALCULATEBY=='S'
        @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
      else
        @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i)).round
      end
    end
    @session[:ttCOLL4]=@totalcoll
    begin
      @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
      @session[:ttkeyno]=@machinedata.GROUP_ID
    rescue Exception=>ex
      puts ex.message
    end
  end

  def cancelcounterdata
    render :update do |page|
      page.redirect_to url_for(:controller=>'machinedata', :action=>'machinedata')
    end
  end
  def roundval(val)
    if (val<0)
      if ((val.to_f.to_s.split(".")[1]).to_i<=5)
        return (val).ceil
      else
        return (val).round
      end
    else
      return (val).round
    end
  end
       
  def updatemachinedata
    @prevmachinedata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])-1),@session[:ttmachineno]])
    @prevmachinedata.PSRINVALUE=params[:yesterday][:PSRIN]
    @prevmachinedata.PSROUTVALUE=params[:yesterday][:PSROUT]
    @prevmachinedata.PMTRINVALUE=params[:yesterday][:PMTRIN]
    @prevmachinedata.PMTROUTVALUE=params[:yesterday][:PMTROUT]
    @mdata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])),@session[:ttmachineno]])
    mulby=params[:multiplyby]
    @mdata.SRIN=params[:today][:SRIN]
    @mdata.SROUT=params[:today][:SROUT]
    @mdata.PSRINVALUE=params[:today][:PSRINVALUE]
    @mdata.PSROUTVALUE=params[:today][:PSROUTVALUE]
    @mdata.TSRIN=((params[:today][:TSRIN].to_f)/params[:multiplyby].to_f).round
    @mdata.TSROUT=((params[:today][:TSROUT].to_f)/params[:multiplyby].to_f).round
    @mdata.SRPER=params[:today][:SRPER]
    @mdata.MTRSHORT=params[:today][:MTRSHORT]
    mtrshort = @mdata.MTRSHORT.to_i/mulby.to_i
    @mdata.SRCOLL=((((@mdata.TSRIN.to_f*params[:rate][:SRIN].to_f)-(@mdata.TSROUT.to_f*params[:rate][:SROUT].to_f))/10).round)+mtrshort.to_i####
    @mdata.MTRIN=params[:today][:MTRIN]
    @mdata.MTROUT=params[:today][:MTROUT]
    @mdata.PMTRINVALUE=params[:today][:PMTRINVALUE]
    @mdata.PMTROUTVALUE=params[:today][:PMTROUTVALUE]
    @mdata.TMTRIN=((params[:today][:TMTRIN].to_f)/params[:multiplyby].to_f).round
    @mdata.TMTROUT=((params[:today][:TMTROUT].to_f)/params[:multiplyby].to_f).round
    @mdata.MTRPER=params[:today][:MTRPER]
    @mdata.MTRCOLL=((((@mdata.TMTRIN.to_i*params[:rate][:MRIN].to_i)-(@mdata.TMTROUT.to_i* params[:rate][:MROUT].to_i))/10).round)+mtrshort.to_i
    @mdata.CALCULATEBY=params[:today][:CALCULATEBY]
    @mdata.MTRDIFFIN=params[:today][:MTRDIFFIN]
    @mdata.MTRDIFFOUT=params[:today][:MTRDIFFOUT]
    @mdata.MTRDIFFWHY=params[:today][:MTRDIFFWHY]
    @mdata.LOSS=params[:today][:LOSS]
    @mdata.SHORTREASON=params[:today][:Shortreason]
    @mdata.THIRTYDAYSAVG=(params[:today][:THIRTYDAYSAVG].to_f/params[:multiplyby].to_f).round
    @mdata.TENDAYSAVG=(params[:today][:TENDAYSAVG].to_f/params[:multiplyby].to_f).round
    @mdata.SRAVG=(params[:today][:SRAVG].to_f/params[:multiplyby].to_f).round
    @mdata.SETTING=params[:today][:SETTING]
    @mdata.SCREEN_RATE_IN=params[:rate][:SRIN]
    @mdata.SCREEN_RATE_OUT=params[:rate][:SROUT]
    @mdata.MTR_RATE_IN=params[:rate][:MRIN]
    @mdata.MTE_RATE_OUT=params[:rate][:MROUT]
    if(@prevmachinedata.SETTING!=@mdata.SETTING)
      @mdata.LASTSETTING=params[:yesterday][:SETTING]
    end
    @prevmachinedata.save
    @mdata.save
    Group.find(:all,:select=>'GroupID',:conditions=>["ClusterName=? and ShopName=?",@session[:ttclustername],@session[:ttshopname]]).each do |key|
      check = ShortExtra.find_by_date_and_cluster_name_and_shop_name_and_group_id((Date.parse(@session[:ttdate])),@session[:ttclustername],@session[:ttshopname],key.GroupID)
      unless check.blank?
        machine_data = Machinedata.find(:all,
          :conditions=> ["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID=?",
            @session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])),key.GroupID])
        @tot_short_extra=0
        machine_data.each do |data|
          if data.CALCULATEBY.eql?('S')
            short_extra = (((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
            @tot_short_extra = @tot_short_extra + short_extra
          else
            short_extra =(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
            @tot_short_extra = @tot_short_extra + short_extra
          end
        end
        keys = Counterdata.find(:first,:conditions=>["ClusterName=? and ShopName=? and DATE=?",
            @session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate]))])
        if keys!= nil
          if key.GroupID.eql?('KEY 1')
            keyval=keys.KEY1.to_i
          end
          if key.GroupID=='KEY 2'
            keyval=keys.KEY2.to_i
          end
          if key.GroupID=='KEY 3'
            keyval=@keys.KEY3.to_i
          end
          if key.GroupID=='KEY 4'
            keyval=@keys.KEY4.to_i
          end
        end
        short_extra = (keyval.to_i - @tot_short_extra.to_i)
        check.update_attribute(:short_extra, short_extra)
      end
    end
    redirect_to :action=>"dailydata"
#render :action=>'showmachinedata'

#    render :update do |page|
#      page.redirect_to url_for(:controller=>'machinedata', :action=>'editdata')
#    end
  end



  def updatemachinedata_new
    @prevmachinedata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])-1),@session[:ttmachineno]])
    @prevmachinedata.PSRINVALUE=params[:yesterday][:PSRIN]
    @prevmachinedata.PSROUTVALUE=params[:yesterday][:PSROUT]
    @prevmachinedata.PMTRINVALUE=params[:yesterday][:PMTRIN]
    @prevmachinedata.PMTROUTVALUE=params[:yesterday][:PMTROUT]
    @mdata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])),@session[:ttmachineno]])
    mulby=@session[:multiplyby]
    @mdata.SRIN=params[:today][:SRIN]
    @mdata.SROUT=params[:today][:SROUT]
    @mdata.PSRINVALUE=params[:today][:PSRINVALUE]
    @mdata.PSROUTVALUE=params[:today][:PSROUTVALUE]
    @mdata.TSRIN=((params[:today][:TSRIN].to_f)/@session[:multiplyby].to_f).round
    @mdata.TSROUT=((params[:today][:TSROUT].to_f)/@session[:multiplyby].to_f).round
    @mdata.SRPER=params[:today][:SRPER]
    @mdata.MTRSHORT=params[:today][:MTRSHORT]
    mtrshort = @mdata.MTRSHORT.to_i/mulby.to_i
    @mdata.SRCOLL=((((@mdata.TSRIN.to_f*params[:rate][:SRIN].to_f)-(@mdata.TSROUT.to_f*params[:rate][:SROUT].to_f))/10).round)+mtrshort.to_i####
    @mdata.MTRIN=params[:today][:MTRIN]
    @mdata.MTROUT=params[:today][:MTROUT]
    @mdata.PMTRINVALUE=params[:today][:PMTRINVALUE]
    @mdata.PMTROUTVALUE=params[:today][:PMTROUTVALUE]
    @mdata.TMTRIN=((params[:today][:TMTRIN].to_f)/@session[:multiplyby].to_f).round
    @mdata.TMTROUT=((params[:today][:TMTROUT].to_f)/@session[:multiplyby].to_f).round
    @mdata.MTRPER=params[:today][:MTRPER]
    @mdata.MTRCOLL=((((@mdata.TMTRIN.to_i*params[:rate][:MRIN].to_i)-(@mdata.TMTROUT.to_i* params[:rate][:MROUT].to_i))/10).round)+mtrshort.to_i
    @mdata.CALCULATEBY=params[:today][:CALCULATEBY]
    @mdata.MTRDIFFIN=params[:today][:MTRDIFFIN]
    @mdata.MTRDIFFOUT=params[:today][:MTRDIFFOUT]
    @mdata.MTRDIFFWHY=params[:today][:MTRDIFFWHY]
    @mdata.LOSS=params[:today][:LOSS]
    @mdata.SHORTREASON=params[:today][:Shortreason]
    @mdata.THIRTYDAYSAVG=(params[:today][:THIRTYDAYSAVG].to_f/@session[:multiplyby].to_f).round
    @mdata.TENDAYSAVG=(params[:today][:TENDAYSAVG].to_f/@session[:multiplyby].to_f).round
    @mdata.SRAVG=(params[:today][:SRAVG].to_f/@session[:multiplyby].to_f).round
    @mdata.SETTING=params[:today][:SETTING]
    @mdata.SCREEN_RATE_IN=params[:rate][:SRIN]
    @mdata.SCREEN_RATE_OUT=params[:rate][:SROUT]
    @mdata.MTR_RATE_IN=params[:rate][:MRIN]
    @mdata.MTE_RATE_OUT=params[:rate][:MROUT]
    if(@prevmachinedata.SETTING!=@mdata.SETTING)
      @mdata.LASTSETTING=params[:yesterday][:SETTING]
    end
    @prevmachinedata.save
    @mdata.save
    Group.find(:all,:select=>'GroupID',:conditions=>["ClusterName=? and ShopName=?",@session[:ttclustername],@session[:ttshopname]]).each do |key|
      check = ShortExtra.find_by_date_and_cluster_name_and_shop_name_and_group_id((Date.parse(@session[:ttdate])),@session[:ttclustername],@session[:ttshopname],key.GroupID)
      unless check.blank?
        machine_data = Machinedata.find(:all,
          :conditions=> ["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID=?",
            @session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])),key.GroupID])
        @tot_short_extra=0
        machine_data.each do |data|
          if data.CALCULATEBY.eql?('S')
            short_extra = (((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
            @tot_short_extra = @tot_short_extra + short_extra
          else
            short_extra =(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
            @tot_short_extra = @tot_short_extra + short_extra
          end
        end
        keys = Counterdata.find(:first,:conditions=>["ClusterName=? and ShopName=? and DATE=?",
            @session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate]))])
        if keys!= nil
          if key.GroupID.eql?('KEY 1')
            keyval=keys.KEY1.to_i
          end
          if key.GroupID=='KEY 2'
            keyval=keys.KEY2.to_i
          end
          if key.GroupID=='KEY 3'
            keyval=@keys.KEY3.to_i
          end
          if key.GroupID=='KEY 4'
            keyval=@keys.KEY4.to_i
          end
        end
        short_extra = (keyval.to_i - @tot_short_extra.to_i)
        check.update_attribute(:short_extra, short_extra)
      end
    end
#    redirect_to :action=>"dailydata"
#render :action=>'showmachinedata'

    redirect_to :controller=>'machinedata', :action=>'editdata'
#    render :update do |page|
#      page.redirect_to url_for(:controller=>'machinedata', :action=>'editdata')
#    end
  end

  def showcollection
    render :update do |page|
      page.redirect_to url_for(:controller=>'machinedata', :action=>'collection')
    end
  end

  ImportPath="assets/imports"
  def import_file_name_format(ext)
    FileUtils.mkdir_p("#{RAILS_ROOT}/#{ImportPath}/upload_n_update")
    file_path = "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}_orig.#{ext}"
    path = File.join(ImportPath, "/upload_n_update/#{file_path}")
    return path
  end

  def data_upload
    #    file_path = save_data_file(params[:import_file])
    file_path = "/home/rahul/Desktop/abc/exp_20120210.csv"
    if File.extname(file_path)==".csv"
      @csv_records = parse_csv_file(file_path)
      @csv_records.each_with_index do |column,i|
        machinedata_parsing_csv(column,i)
      end
    end
    redirect_to :controller=>'machinedata', :action=>'file_upload'
    flash[:confirm] = '<font color=green size=4><b>DATA SUCCESSFULLY UPLOADED.</b></font>'
  end

  def file_upload
  end

  def machinedata_parsing_csv(column,i)
    data = utf8_value(column[0]).split(';')
    Machinedata.update_machinedata(data)
  end

  def parse_csv_file(file_path)
    @csv_records = []
    #    FasterCSV.new(File.open(file_path), :headers => :first_row)do |row|
    CSV::Reader.parse(File.new(file_path, "r").read) do |row|
      @csv_records << row
    end
    @csv_records
  end

  def utf8_value(val)
    !val.blank? ? Iconv.conv("UTF-8//IGNORE", "US-ASCII", val.to_s.strip.gsub("'","`")) : nil
  end

  def save_data_file(import_file)
    ext = import_file.split(".").last
    path = import_file_name_format(ext)
    File.open(path, "wb") { |f| f.write(File.new(import_file, "r")) }
    return path
  end

  def editdata
#    raise editdata
  end

  def editdaily_data
#    debugger
    if params[:machinedata][:ClusterName] && params[:machinedata][:ShopName] && params[:date] && params[:MachineNo] && params[:date] && params[:multiplyby]
#      @mc=Machinedata.find_first(["CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and TRANS_DATE=?",@session[:ttclustername],@session[:ttshopname],@session[:ttkeyno],@session[:ttmachineno],@session[:ttdate]])
      key_recored = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?",
          "#{params[:machinedata][:ClusterName]}","#{params[:machinedata][:ShopName]}","#{params[:date]}","#{params[:MachineNo]}"])

      @key = key_recored.GROUP_ID  unless key_recored.blank?
#      @multiply_by = key_recored.MULTIPLY_BY.to_i unless key_recored.blank?
      @machine_data = Machinedata.find_first(["CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and TRANS_DATE=?",
          params[:machinedata][:ClusterName],params[:machinedata][:ShopName],@key,params[:MachineNo],params[:date]]) unless key_recored.blank?

      @session[:ttclustername],@session[:ttshopname],@session[:ttkeyno],@session[:ttdate],@session[:ttmachineno] = params[:machinedata][:ClusterName],params[:machinedata][:ShopName],@key,params[:date],params[:MachineNo]
      @session[:multiplyby] = params[:multiplyby]
      render :update do |page|
          page << "jQuery('#loader').hide();"
           if @machine_data.blank? 
            page.alert("NO RECORD FOUND");
            page << "jQuery('#parent_dailydata_div').hide();"
          end
          page << "jQuery('#parent_dailydata_div').show();"
          page.replace_html 'parent_dailydata_div', :partial => 'parent_dailydata_part'
          page << "document.getElementById('yesterday_PSRIN').focus();"
#          page << "document.getElementById('MachineNo').value = #{@multiply_by}"
      end
    end
   
  end

#  protected
  def machine_and_key_collection(cluster_name,shop_name,machine_no,date)
    machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",cluster_name,shop_name,date,machine_no])
    if machinedata.present?
      colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID=?",cluster_name,shop_name,date,machinedata.GROUP_ID])
      totalcoll=0
      colldata.each do |data|
        if data.CALCULATEBY=='S'
          totalcoll = (totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
          totalcoll = (totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end
      end
      tot_coll = totalcoll
    end
    key = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?",cluster_name,shop_name,date,machine_no])
    return key,tot_coll
  end
end
