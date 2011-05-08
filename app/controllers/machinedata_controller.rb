class MachinedataController < ApplicationController
layout 'adminlayout'
 before_filter :login_required
class Time
  def yesterday
    self - 86400
  end
end

################EDIT PREVIOUS RECORD#####################

def datavalue
  puts "--------- ---------------------"
  puts "------------------------------"
  
  puts "------------------------------"
  puts "------------------------------"
  puts "------------------------------"
end

def editprev
    begin
      puts "in editprev" 
      puts params[:date]
    #@session['date']=Date.parse(params[:date])
     if(@session[:prevdate]==nil)
             
        @date=Date.parse(params[:date])
        puts @date
        @session[:prevdate]=@date
         else           
        @date=Date.parse(params[:date])  
        @session[:prevdate]=@date
    end
    
    
    if(params[:clientdata][:MachineNo]==nil or params[:clientdata][:MachineNo]=="")
    #session[:errmsg]="PLEASE SELECT MACHINENO"
    render :update do |page|
    page.alert("PLEASE SELECT MACHINENO")
    page << "document.getElementById('clientdata_MachineNo').focus();"
    #page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
    end  
    else
        puts "in else"
         puts @date
        puts @session[:shopname]
        puts @session[:Groupid]
        puts @session[:MachineName]
        puts params[:clientdata][:MachineNo]
        
        @clientdata=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@date}'",@session[:shopname],@session[:Groupid],@session[:MachineName],params[:clientdata][:MachineNo]])        
        
        if(@clientdata!=nil)
        @clientdata = Machinedata.find(@clientdata.id)
        puts "**********************************"
       
        puts @session['date']
        render :update do |page|
            page.redirect_to url_for(:controller=>'machinedata', :action=>'edit')
        end  
        else
            #session[:errmsg]="NO RECORD FOUND FOR SELECTED MACHINE"
            render :update do |page|
            page.alert("NO RECORD FOUND FOR SELECTED MACHINE")
           # page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
    end 
        end
    end
    rescue Exception=>ex
    puts ex.message()
    end
end
def edit
     
     @clientdata=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@session[:prevdate]}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])        
        puts @clientdata.id
        @clientdata = Machinedata.find(@clientdata.id)
      
      
    #@clientdata = Clientdata.find(params[:id])
  end
def update
    @clientdata1=Machinedata.find(:first,:conditions=>["SHOP_NAME=? and GROUP_ID=? and MACHINE_NAME=? and MACHINE_NO=? and TRANS_DATE='#{@session[:prevdate]}'",@session[:shopname],@session[:Groupid],@session[:MachineName],@session[:MachineNo]])        
    @clientdata = Machinedata.find(@clientdata1.id)
    puts "aasasas"
    puts params[:clientdata][:PSRINVALUE]
     
   
    if(params[:clientdata][:PSRINVALUE]=="" or params[:clientdata][:PSROUTVALUE]=="" or params[:clientdata][:PMTRINVALUE]=="" or params[:clientdata][:PMTROUTVALUE]=="")
        render :update do |page|
        page.alert("PLEASE ENTER DATA")
            end
        else
           
        if @clientdata.update_attributes(params[:clientdata])
        #flash[:notice] = 'Clientdata was successfully updated.'
        # render :action => 'edit'
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
	   
        #page.replace_html 'MachineNodiv', :partial => 'machine'
        #page << "document.getElementById('machinedata_MachineNo').focus();"
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
    puts "in daily data121212"
    puts params[:ClusterName]
    puts params[:date]
    puts params[:ShopName]
    puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    puts params[:MachineNo]
    @session[:ttmachineno]=params[:MachineNo]
    @session[:ttdate]=params[:date]
    
    puts @session[:ttclustername]
    puts @session[:ttshopname]
    puts @session[:ttdate]
    puts @session[:ttmachineno]
    
    #@machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
 
    @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    if(@machinedata!=nil)
        puts "in if"
=begin        
    @colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@machinedata.GROUP_ID])
    @totalcoll=0
    @colldata.each do |data|
        puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=@totalcoll.to_i+data.SRCOLL.to_i
              else
                  @totalcoll=@totalcoll+data.MTRCOLL.to_i
        end    
       puts @totalcoll       
    end
    puts "TOTAL COll"
    puts @totalcoll
    
    
    
    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL]=@totalcoll
=end    

#####Collection for KEY1###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end    
       puts @totalcoll       
    end
    puts "TOTAL COll"
    puts @totalcoll
    
    
    
    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    
    @session[:ttCOLL1]=@totalcoll
#########END KEY1############

#####Collection for KEY2###########


@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end    
       puts @totalcoll       
    end
    puts "TOTAL COll"
    puts @totalcoll
    
    
    
    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL2]=@totalcoll
#########END KEY2############

#####Collection for KEY3###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end    
       puts @totalcoll       
    end
    puts "TOTAL COll"
    puts @totalcoll
    
    
    
    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL3]=@totalcoll
#########END KEY3############

#####Collection for KEY4###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_i+(((((data.TSRIN.to_i*data.SCREEN_RATE_IN.to_i)-(data.TSROUT.to_i*data.SCREEN_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_i*data.MTR_RATE_IN.to_i)-(data.TMTROUT.to_i*data.MTE_RATE_OUT.to_i))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i))
        end    
       puts @totalcoll       
    end
    puts "TOTAL COll"
    puts @totalcoll
    
    
    
    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL4]=@totalcoll
#########END KEY4############



    #@@totalcoll=@totalcoll
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
    puts @session[:ttKEYCOLL]
    redirect_to  :action=>'showmachinedata'
    else
        puts "in if"
        flash[:notice] ='<font color=red size=3><b>No Record found.</b></font>' 
        render :action=>'dailydata'
    
    
    end
end


def showmachinedata
#####Collection for KEY1###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 1'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        end
       puts @totalcoll
    end
    puts "TOTAL COll"
    puts @totalcoll



    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])

    @session[:ttCOLL1]=@totalcoll
    #raise @session[:ttCOLL1].inspect
#########END KEY1############

#####Collection for KEY2###########


@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 2'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        end
       puts @totalcoll
    end
    puts "TOTAL COll"
    puts @totalcoll



    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL2]=@totalcoll
#########END KEY2############

#####Collection for KEY3###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 3'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        end
       puts @totalcoll
    end
    puts "TOTAL COll"
    puts @totalcoll



    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL3]=@totalcoll
#########END KEY3############

#####Collection for KEY4###########

@colldata = Machinedata.find_all(["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID='KEY 4'",@session[:ttclustername],@session[:ttshopname],@session[:ttdate]])
    @totalcoll=0
    @colldata.each do |data|
        #puts "in LOOP"
        if data.CALCULATEBY=='S'
                  @totalcoll=(@totalcoll.to_f+(((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f)).round
        else
                @totalcoll=(@totalcoll+(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_i)).round
        end
       puts @totalcoll
    end
    puts "TOTAL COll"
    puts @totalcoll



    #@totalcoll=Machinedata.sum(:SRCOLL,:conditions=>["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
    @session[:ttCOLL4]=@totalcoll
#########END KEY4############


  
  
    begin
    puts "in show mc data********************"
    puts params[:date]
    
     @machinedata = Machinedata.find_first(["Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?",@session[:ttclustername],@session[:ttshopname],@session[:ttdate],@session[:ttmachineno]])
     
     @session[:ttkeyno]=@machinedata.GROUP_ID
     puts @session[:ttkeyno]
                                 
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
    #raise params.inspect
    #puts params[:today][:SRIN]
    #puts params[:today][:SROUT]
    #puts params[:today][:MTRIN]
    #puts params[:today][:MTROUT]
    #puts params[:yesterday][:PSRIN]
    #puts params[:yesterday][:PSROUT]
    #puts params[:yesterday][:PMTRIN]
    #puts params[:yesterday][:PMTROUT]
    #puts params[:srcoll]
    #raise params.inspect
    puts params[:today]
    puts "------------------------"
    puts params[:multiplyby]
    
     @prevmachinedata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])-1),@session[:ttmachineno]])
     
     @prevmachinedata.PSRINVALUE=params[:yesterday][:PSRIN]
     @prevmachinedata.PSROUTVALUE=params[:yesterday][:PSROUT]
     @prevmachinedata.PMTRINVALUE=params[:yesterday][:PMTRIN]
     @prevmachinedata.PMTROUTVALUE=params[:yesterday][:PMTROUT]
    
     puts "?????????"
    puts params[:yesterday][:SETTING]
    puts params[:yesterday][:date]
    puts params[:yesterday][:srin] 
     @mdata = Machinedata.find(:first,:conditions=>['Cluster_Name=? and Shop_Name=? and TRANS_Date=? and Machine_No=?',@session[:ttclustername],@session[:ttshopname],(Date.parse(@session[:ttdate])),@session[:ttmachineno]])
     
     
     mulby=params[:multiplyby]
    
     puts mulby
     #SCREEN
     
     
     @mdata.SRIN=params[:today][:SRIN]
     @mdata.SROUT=params[:today][:SROUT]
     @mdata.PSRINVALUE=params[:today][:PSRINVALUE]
     @mdata.PSROUTVALUE=params[:today][:PSROUTVALUE]
     @mdata.TSRIN=roundval((params[:today][:TSRIN].to_i)/params[:multiplyby].to_i)
     @mdata.TSROUT=roundval((params[:today][:TSROUT].to_i)/params[:multiplyby].to_i)
     @mdata.SRPER=params[:today][:SRPER]
     @mdata.MTRSHORT=params[:today][:MTRSHORT]
     #@mdata.SRCOLL=(params[:today][:SRCOLL].to_i/params[:multiplyby].to_i).round
     
     
     @mdata.SRCOLL=((((@mdata.TSRIN.to_f*params[:rate][:SRIN].to_f)-(@mdata.TSROUT.to_f*params[:rate][:SROUT].to_f))/10).round)+@mdata.MTRSHORT.to_i####
     #raise ((((@mdata.TSRIN.to_f*params[:rate][:SRIN].to_f)-(@mdata.TSROUT.to_f*params[:rate][:SROUT].to_f))/10).round).inspect
  
     
     
     #METER
     @mdata.MTRIN=params[:today][:MTRIN]
     @mdata.MTROUT=params[:today][:MTROUT]
     @mdata.PMTRINVALUE=params[:today][:PMTRINVALUE]
     @mdata.PMTROUTVALUE=params[:today][:PMTROUTVALUE]
     @mdata.TMTRIN=roundval((params[:today][:TMTRIN].to_i)/params[:multiplyby].to_i)
     puts "TMTRIN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
     puts params[:today][:TMTRIN]
     puts @mdata.TMTRIN
     @mdata.TMTROUT=roundval((params[:today][:TMTROUT].to_i)/params[:multiplyby].to_i)
     puts params[:today][:TMTROUT]
     puts @mdata.TMTROUT
     @mdata.MTRPER=params[:today][:MTRPER]
     #@mdata.MTRCOLL=(params[:today][:MTRCOLL].to_i/params[:multiplyby].to_i).round
     @mdata.MTRCOLL=(((@mdata.TMTRIN.to_i*params[:rate][:MRIN].to_i)-(@mdata.TMTROUT.to_i* params[:rate][:MROUT].to_i))/10)+@mdata.MTRSHORT.to_i
         
     @mdata.CALCULATEBY=params[:today][:CALCULATEBY]
     @mdata.MTRDIFFIN=params[:today][:MTRDIFFIN]
     @mdata.MTRDIFFOUT=params[:today][:MTRDIFFOUT]
     @mdata.MTRDIFFWHY=params[:today][:MTRDIFFWHY]
     @mdata.LOSS=params[:today][:LOSS]
     
     
     @mdata.SHORTREASON=params[:today][:Shortreason]
     @mdata.THIRTYDAYSAVG=roundval(params[:today][:THIRTYDAYSAVG].to_i/params[:multiplyby].to_i)
     @mdata.TENDAYSAVG=roundval(params[:today][:TENDAYSAVG].to_i/params[:multiplyby].to_i)
     @mdata.SRAVG=roundval(params[:today][:SRAVG].to_i/params[:multiplyby].to_i)
     @mdata.SETTING=params[:today][:SETTING]
     
     @mdata.SCREEN_RATE_IN=params[:rate][:SRIN]
     @mdata.SCREEN_RATE_OUT=params[:rate][:SROUT]
     @mdata.MTR_RATE_IN=params[:rate][:MRIN]
     @mdata.MTE_RATE_OUT=params[:rate][:MROUT]
     
puts "**************************************"

    if(@prevmachinedata.SETTING!=@mdata.SETTING)
        @mdata.LASTSETTING=params[:yesterday][:SETTING]
    end
     
     
     
     
     
      @prevmachinedata.save
     @mdata.save
     
    redirect_to :action=>"dailydata"
    #puts 
end

def showcollection
    puts "in ccccc"
    
    puts @session[:ttclustername]
    puts @session[:ttshopname]
    puts @session[:ttdate]
   render :update do |page|
    page.redirect_to url_for(:controller=>'machinedata', :action=>'collection')
    end
end
end
