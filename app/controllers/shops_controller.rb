class ShopsController < ApplicationController
layout 'adminlayout'
require 'ftools'
  require 'chronic'
   before_filter :login_required
  
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
 
def getfilename
    begin
   #puts params[:shop][:FileName]
    files=params[:shop]
    #puts files
    
    
 @con=Configuration.find(1)
    
    @folderpath=@con.FilesFolderPath
    @backupfolder=@con.BackupFolderPath
   
    basedir = "#{@folderpath}/"
    targetdir="#{@backupfolder}/"
 pw=Dir.pwd() 
Dir.chdir(basedir)
@files=params[:shop][:FileName]
i=0
#puts "in loop"
@files.each { |file| 
#puts file
    @session['filename']=basedir+file
    @session['file']=file
}
Dir.chdir(pw) 
render :update do |page|
   
    page.redirect_to url_for(:controller=>'shops', :action=>'viewdata')
            end 
    rescue Exception=>ex
        #puts ex.message
    end
end

############################# UPLOAD ######################################
def uploaddata
    #DIR TO COPY FILES FROM ##############
    @con=Configuration.find(1)
    
    @folderpath=@con.FilesFolderPath
    @backupfolder=@con.BackupFolderPath
     if File.directory?("#{@backupfolder}")
         
    #FileUtils.copy(filename, "#{@backupfolder}")
    else
        FileUtils.mkdir_p "#{@backupfolder}"
        # FileUtils.copy(filename, "#{@backupfolder}")
    end
    basedir = "#{@folderpath}"
    targetdir="#{@backupfolder}"
    pw=Dir.pwd() 
    Dir.chdir(basedir)
    #########READ FILE FROM BASEDIR AND SPLIT WITH THE WORD COUNTER INTO 2  STRING ###############
begin
    values=[]
    IO.foreach("#{@session['file']}"){|block| values<<block}
    d=values.to_s.split('COUNTER')
    data=d[0].to_a
    flag="false"
    Dir.chdir(pw)
    for i in 0..(data.length-1)
        @aelement= data[i].to_s.split(',')
        @sname=@aelement[1]
        @gid=@aelement[3]
        @gid=@aelement[3]
        @gid=@aelement[3]
        @mno=@aelement[4]
        @prevdatacount=Machinedata.count(:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=?',@sname,@gid,@mno],:order => "TRANS_DATE desc" )
        if(@prevdatacount<=0)
            flag="true"
            break 
        end
    end
####################END READING###################################        
        if(flag=="true")
            render :update do |page|
            page.alert("Enter Previous Days Data for Machine No.#{@mno}")
            page.redirect_to url_for(:action=>'viewdata')
            end 
        else
            updatedb
        end
    
    
    
rescue Exception=>ex
#puts ex.message()
end

end

########################## END ############################################




################################UPLOAD DATA TO DATABASE FROM GIVEN FILE ##########################################
def updatedb
    begin
  #puts "in UPDATEDB"
   @con=Configuration.find(1)
    
    @folderpath=@con.FilesFolderPath
    @backupfolder=@con.BackupFolderPath
   
    basedir = "#{@folderpath}"
    targetdir="#{@backupfolder}"
    pw=Dir.pwd() 
    Dir.chdir(basedir)
    ###########################READ FILE AND SPLIT TO 2 ARRAY FILES
    values=[]
    IO.foreach("#{@session['file']}"){|block| values<<block}
    d=values.to_s.split('COUNTER')
    
    data=d[0].to_a
    #puts "LENGTH = #{data.length}"
    begin
     Dir.chdir(pw)
        for i in 0..(data.length-1)
            
            @aelement= data[i].to_s.split(',')
            @clustername=@aelement[0]
            @sname=@aelement[1]
            @gid=@aelement[3]
            @mno=@aelement[4]
            
            @mc=@aelement[4]
            #puts "DATE************************************"
            #puts i
            #puts @aelement[2]
            @trdate=Chronic.parse(@aelement[2]).strftime("%Y-%m-%d")
            @srin=@aelement[5]
            @srout=@aelement[6]
            @mtrin=@aelement[7]
            @mtrout=@aelement[8]
            @mtrshort=@aelement[9]
            @sreason=@aelement[10]
            @currdate=Date.parse("#{@trdate}")
            
            @oldmdata1=Machinedata.find(:first,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc" )

            @olddate=Date.parse("#{@oldmdata1.TRANS_DATE}")
            @datediff=@currdate-@olddate
            @actualdatediff=@datediff-1
          
            if @actualdatediff!=0
                
                for i in 1..@actualdatediff
                    
                    #savemdata(@sname,@gid,@mno,@trdate,@srin,@srout,@mtrin,@mtrout,@mtrshort,@sreason)
                    #savemdata(@oldmdata1.SHOP_NAME
                    #,@gid,@mno,@trdate,@srin,@srout,@mtrin,@mtrout,@mtrshort,@sreason)
                    #puts "I value"+i.to_s
                    @mdata=Machinedata.new()
                    
                    @mdata.TRANS_DATE=@olddate+i
                    @datenew=@mdata.TRANS_DATE
                    #puts "in ahghsadg"
                    #Chronic.parse(trdate).strftime("%Y-%m-%d")
                    @mdata.T_DATE=@mdata.TRANS_DATE.strftime("%d-%b-%Y")
                    @mdata.SHOP_NAME=@oldmdata1.SHOP_NAME
                    @mdata.GROUP_ID=@oldmdata1.GROUP_ID
                    @mdata.MACHINE_NO=@oldmdata1.MACHINE_NO
                    @mdata.CLUSTER_NAME=@oldmdata1.CLUSTER_NAME
                    @mdata.SRIN=@oldmdata1.PSRINVALUE
                    @mdata.SROUT=@oldmdata1.PSROUTVALUE
=begin                    
                    puts "***************************"
                    puts @oldmdata1.PSRINVALUE
                    puts @oldmdata1.PSROUTVALUE
                    puts @mdata.SRIN
                    puts @mdata.SROUT
                    puts "***************************"

                    ##OLD SR% calculation for duplication------------------------------
                    
                    if @mdata.SRIN.to_i!=0
                        
                        @cal=((@mdata.SROUT.to_f*100)/@mdata.SRIN.to_f).round
                    else
                        @cal=0
                    end
                    ##OLD SR% calculation for duplication ends here--------------  
=end
                    
                    @mdata.PSRINVALUE=@mdata.SRIN
                    @mdata.PSROUTVALUE=@mdata.SROUT
                    @mdata.MTRIN=@oldmdata1.PMTRINVALUE
                    @mdata.MTROUT=@oldmdata1.PMTROUTVALUE
                    ##This has to be calculated
                    #@mdata.MTRPER=@oldmdata1.MTRPER
                    ##This has to be calcu,lated
                    @mdata.PMTRINVALUE=@mdata.MTRIN
                    @mdata.PMTROUTVALUE=@mdata.MTROUT
                    #@mdata.MTRSHORT=@oldmdata1.MTRSHORT
                    @mdata.MTRSHORT=0
                    #@mdata.SHORTREASON=@oldmdata1.SHORTREASON
                    @mdetails=Machine.find(:first,:conditions=>['MachineNo=? and GroupID=? and ShopName=?and ClusterName=?',@mdata.MACHINE_NO,@mdata.GROUP_ID,@mdata.SHOP_NAME,@mdata.CLUSTER_NAME])
                    @mdata.MACHINE_NAME=@mdetails.MachineName
                    @mdata.SCREEN_RATE_IN=@mdetails.SrateIn
                    @mdata.SCREEN_RATE_OUT=@mdetails.SrateOut
                    @mdata.MTR_RATE_IN=@mdetails.MrateIn
                    @mdata.MTE_RATE_OUT=@mdetails.MrateOut
                    @mdata.MULTIPLY_BY=@mdetails.Multiplyby
                    ###calculation for tsrin, tsrout,mtrin,mtrout,mtrdiffin,mtrdiffout
                    @oldmdatanew=Machinedata.find(:first,:conditions=>['TRANS_DATE=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@mdata.TRANS_DATE-1,@sname,@gid,@mno,@clustername])
                    #if @oldmdata!=nil
                    
                    #oldsrin=@oldmdatanew.SRIN
                    #oldsrout=@oldmdatanew.SROUT
                    #oldmtrin=@oldmdatanew.MTRIN
                    #oldmtrout=@oldmdatanew.MTROUT
                    
                    oldsrin=@oldmdatanew.PSRINVALUE
                    oldsrout=@oldmdatanew.PSROUTVALUE
                    oldmtrin=@oldmdatanew.PMTRINVALUE
                    oldmtrout=@oldmdatanew.PMTROUTVALUE
                    @mdata.TSRIN=(@mdata.SRIN.to_i-oldsrin.to_i)
                    @mdata.TSROUT=(@mdata.SROUT.to_i-oldsrout.to_i)
                    
                    @mdata.TMTRIN=(@mdata.MTRIN.to_i-oldmtrin.to_i)
                    @mdata.TMTROUT=(@mdata.MTROUT.to_i-oldmtrout.to_i)
=begin                    
                    puts "UPDATE DB"
                    puts @mdata.MTRIN.to_i
                    puts oldmtrin.to_i
                    puts @mdata.TMTRIN
=end                    
                    
                    #@mdata.MTRDIFFIN=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTRIN.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSRIN.to_i))/10
                    #@mdata.MTRDIFFOUT=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTROUT.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSROUT.to_i))/10
                    @mdata.MTRDIFFIN=((@mdata.MTR_RATE_IN.to_i*@mdata.TMTRIN.to_i)-(@mdata.SCREEN_RATE_IN.to_i*@mdata.TSRIN.to_i))/10
                    @mdata.MTRDIFFOUT=((@mdata.MTE_RATE_OUT.to_i*@mdata.TMTROUT.to_i)-(@mdata.SCREEN_RATE_OUT.to_i*@mdata.TSROUT.to_i))/10
                    #@mdata.SETTING=@oldmdata.LASTSETTING
                    #@mdata.LASTSETTING=@oldmdata.LASTSETTING
                    ####Calculation part end here
                    
                    @mdata.SRCOLL=(((@mdata.TSRIN.to_i*@mdata.SCREEN_RATE_IN.to_i)-(@mdata.TSROUT.to_i*@mdata.SCREEN_RATE_OUT.to_i))/10)+@mdata.MTRSHORT.to_i####
                    @mdata.MTRCOLL=(((@mdata.TMTRIN.to_i*@mdata.MTR_RATE_IN.to_i)-(@mdata.TMTROUT.to_i*@mdata.MTE_RATE_OUT.to_i))/10)+@mdata.MTRSHORT.to_i
                    
                    if @mdata.MTRDIFFIN.to_i==0 and @mdata.MTRDIFFOUT.to_i==0
                        @mdata.MTRDIFFWHY='NO'
                    elsif @mdata.MTRDIFFIN.to_i==0 and @mdata.MTRDIFFOUT.to_i!=0
                        @mdata.MTRDIFFWHY='OUT'
                    elsif @mdata.MTRDIFFIN.to_i!=0 and @mdata.MTRDIFFOUT.to_i==0
                        @mdata.MTRDIFFWHY='IN'
                    else
                        @mdata.MTRDIFFWHY='IN/OUT'
                    end
                    
                    @mdata.SETTING=@oldmdata1.SETTING
                    @mdata.LASTSETTING=@oldmdata1.SETTING
                    if @mdata.TSRIN<0 or @mdata.TSROUT<0
                        @mdata.CALCULATEBY='M'
                    else
                        @mdata.CALCULATEBY='S'
                    end
                    ####New SR% Value calculation for duplication---------------------------------
                    #if @mdata.MTRSHORT.to_i<0
                      #@totalmtrshortneg=@mdata.MTRSHORT.to_i
                      #@totalmtrshortpos=0
                    #else
                      @totalmtrshortneg=0
                      @totalmtrshortpos=0                  
                    #end
                    #@totalmtrshort=@totalmtrshort.to_i+mtrshort.to_i
                    
                    #puts "First Total Meter Short-----------------------------"
                    #puts @totalmtrshort
                    #puts @mdata.SETTING
                    #puts "First Total Meter Short-----------------------------"
                    if @mdata.CALCULATEBY!='M'
                      @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
                      
                      
                      @machinevalues.each do |item|
                        #if(@mdata.SETTING==item.LASTSETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))  
                        #if(@mdata.SETTING==item1.SETTING) and ((item1.SRIN==item1.PSRINVALUE or (item1.SRIN!=0 and item1.PSRINVALUE!=0))   or (item1.SROUT==item1.PSROUTVALUE or (item1.SROUT!=0 and item1.PSROUTVALUE!=0)))  
                        #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
                        #LATEST##if((@mdata.SETTING==item1.SETTING) and ((item1.SRIN==item1.PSRINVALUE and ((item1.SRIN!=0 and item1.PSRINVALUE!=0) or(item1.SRIN==0 and item1.PSRINVALUE==0 and item1.T_DATE!=nil)))   or (item1.SROUT==item1.PSROUTVALUE and ((item1.SROUT!=0 and item1.PSROUTVALUE!=0)or(item1.SROUT==0 and item1.PSROUTVALUE==0 and item1.T_DATE!=nil)))))
                        if(@mdata.SETTING==item.SETTING and item.T_DATE!=nil) 
                          if (item.CALCULATEBY!='M')
                            @totalmtrshort=@totalmtrshort.to_i+item.MTRSHORT.to_i
                            if item.MTRSHORT.to_i<0
                              @totalmtrshortneg=@totalmtrshortneg+item.MTRSHORT.to_i
                            else
                              @totalmtrshortpos=@totalmtrshortpos+item.MTRSHORT.to_i
                            end
                          else
                            break
                          end
                        else
                          #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                            if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                              if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                                if (item.CALCULATEBY!='M')
                                  @totalmtrshort=@totalmtrshort.to_i+item.MTRSHORT.to_i
                                  if item.MTRSHORT.to_i<0
                                    @totalmtrshortneg=@totalmtrshortneg+item.MTRSHORT.to_i
                                  else
                                    @totalmtrshortpos=@totalmtrshortpos+item.MTRSHORT.to_i
                                  end
                                else
                                  break
                                end
                              else
                                break
                              end  
                            else
                              break
                            end
                        end
                      end
                    end
                    #puts "TOTAL METER SHORT IS--------------------"
                    #puts @totalmtrshort
                    #puts "TOTAL METER SHORT IS--------------------"
                    #puts "After addition Total Meter Short-----------------------------"
                    #puts @totalmtrshort
                    #puts "After addition Total Meter Short-----------------------------"

                    if @srin.to_i!=0
                        #puts "SRIN,SROUT and Total Meter Short value "
                        #puts @srin
                        #puts @srout
                        #puts @totalmtrshort
                        #puts @mdata.SROUT
                        #puts @mdata.SCREEN_RATE_OUT
                        #puts @mdata.SRIN
                        #puts @mdata.SCREEN_RATE_IN
                        #puts @totalmtrshortpos
                        #puts "SRIN,SROUT and Total Meter Short value "
                        outval=((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10).to_i
                        if outval!=0
                          outcal=roundval((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10)
                          else
                            outcal=roundval((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f))
                          end
                         inval=((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10).to_i
                        if inval!=0
                          incal=roundval((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10)
                          else
                            incal=roundval((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f))
                          end
                          
                        begin
                        #@cal=((((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10).round-@totalmtrshortneg.to_f)*100/(((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10).round+@totalmtrshortpos.to_f)).round
                        @cal=roundval(((outcal.to_i-@totalmtrshortneg.to_f)*100)/(incal.to_i+@totalmtrshortpos.to_f))
                        rescue Exception=>ex
                        #puts ex.message
                        @cal=0
                        end
                    else
                      @cal=0
                    end  
                    #puts "SRPER VALUE---------------"
                    #puts @cal
                    #puts "SRPER VALUE---------------"
                    ####New SR % value calculation for duplication ends here---------------------
                    @mdata.SRPER=@cal  
                    if @mdata.SRCOLL<0 or @mdata.MTRCOLL<0
                        @mdata.LOSS='Loss'
                    else
                        @mdata.LOSS='Profit'
                    end
                    ###Average calculations to be put here-------------------------------------
                    
                    @count=Machinedata.count(:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=? and T_DATE!=""',@sname,@gid,@mno,@clustername])

                    #puts @count
                    ###Code for Thirty day average
                    if @count.to_i>=29
                        #puts "in 30 loop ************************************************"
                        @values30=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
                        @sumvalue30=0
                        @countval=0
                        @flag=false
                        @values30.each do |item|
                            if @countval.to_i<29
                                if item.CALCULATEBY=='S'
                                    @sumvalue30=@sumvalue30.to_i+item.SRCOLL
                                else
                                    @sumvalue30=@sumvalue30.to_i+item.MTRCOLL
                                end
                                @flag=true  
                                @countval=@countval.to_i+1
                            end
                            
                        end
                        if @flag==true
            
                          if @mdata.CALCULATEBY=='S'
                            @sumvalue30=@sumvalue30.to_i+@mdata.SRCOLL.to_i
                          else
                            @sumvalue30=@sumvalue30.to_i+@mdata.MTRCOLL.to_i
                          end
                          @thirtyavg=roundval(@sumvalue30.to_i/30)
                          @mdata.THIRTYDAYSAVG=@thirtyavg
                          @flag=false
                        else
                        end  
                    else
                        #puts "Less then thirty"
                        #@mdata.THIRTYDAYSAVG=-1
                    end
                    ###Code for Thirty day average ends
                    ###Code for 10 days average
          #puts @count.to_i
          @countval10=1
          #puts "Count"
          if @count.to_i>=9
            #puts "Greater then 10"
            @values10=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
            @sumvalue10=0
            
            @flag=false
            @values10.each do |item|
              #puts "&&&&&&&&&&&&&&&&&&&&&&&&7"
              #puts @countval101
              if @countval10.to_i<=9
                             
                
                if item.CALCULATEBY=='S'
                  @sumvalue10=@sumvalue10.to_i+item.SRCOLL.to_i
                else
                  @sumvalue10=@sumvalue10.to_i+item.MTRCOLL.to_i
                end
                @flag=true
               
             
              end
               @countval10=@countval10.to_i+1
             end
             #puts "aasaas"
             #puts @countval101 
            if @flag==true
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              if @mdata.CALCULATEBY=='S'
                @sumvalue10=@sumvalue10.to_i+@mdata.SRCOLL.to_i
              else
                @sumvalue10=@sumvalue10.to_i+@mdata.MTRCOLL.to_i
              end
              @tenavg=roundval(@sumvalue10.to_f/10)
              @mdata.TENDAYSAVG=@tenavg
              @flag=false
            else
            end
          else
            #puts "Less then 10"
            
          end
          ###Code for 10 days average ends here
                    ###Screen average calculations
                    @srvalues=0
                    @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
                    if @mdata.CALCULATEBY=='S'
                        @srvalues=@mdata.SRCOLL
                    else
                        @srvalues=@mdata.MTRCOLL
                    end
                    @valcount=2
                    @machinevalues.each do |item|
                        #puts item.TRANS_DATE
                        #if(item.SETTING!=item.LASTSETTING and (item.SRIN!=item.PSRIN  or (item.SRIN==0 and item.PSRIN==0)) and (item.SROUT!=item.PSROUT or (item.SROUT==0 and item.PSROUT==0)) 
                       # if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))) 
                       # if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
                       #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
                      #Latest###if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and ((item.SRIN!=0 and item.PSRINVALUE!=0) or(item.SRIN==0 and item.PSRINVALUE==0 and item.T_DATE!=nil)))   or (item.SROUT==item.PSROUTVALUE and ((item.SROUT!=0 and item.PSROUTVALUE!=0)or(item.SROUT==0 and item.PSROUTVALUE==0 and item.T_DATE!=nil)))))
                      if(@mdata.SETTING==item.SETTING and item.T_DATE!=nil) 
                        #puts "in else"
                        @valcount=@valcount+1
                        if item.CALCULATEBY=='S'
                          @srvalues=@srvalues+item.SRCOLL.to_i
                        else
                          @srvalues=@srvalues+item.MTRCOLL.to_i
                        end
                      else
                        #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                        if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                          if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                            @valcount=@valcount+1
                            if item.CALCULATEBY=='S'
                              @srvalues=@srvalues+item.SRCOLL.to_i
                            else
                              @srvalues=@srvalues+item.MTRCOLL.to_i
                            end
                          else
                            break
                          end    
                        else
                          break
                        end
                      end
                          
                    end
                   if @valcount<=2
                        @valcount=1
                    else
                        @valcount=@valcount-1
                    end
                
                    begin
                        @mdata.SRAVG=roundval(@srvalues.to_f/(@valcount.to_i))
                    rescue Exception=>ex
                        #puts ex.message()
                        @mdata.SRAVG=@srvalues
                    end
                    ###Average calculations to be put here------------------------------------


                    ####Meter % calculation
                    ### New Meter % calculation
                    #if @mtrshort.to_i<0
                      @totalmtrshortmperpos=0
                      @totalmtrshortmperneg=0
                      @sinval=0
                      @sroutval=0
                    #else
                      #@totalmtrshortmperneg=0
                      #@totalmtrshortmperpos=0
                    #end
                    #@totalmtrshort=@totalmtrshort.to_i+mtrshort.to_i
                    @countvalues=0
                    @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
                    @machinevalues.each do |item|
                      #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))) 
                      #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
                      #LATEST##if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and ((item.SRIN!=0 and item.PSRINVALUE!=0) or(item.SRIN==0 and item.PSRINVALUE==0 and item.T_DATE!=nil)))   or (item.SROUT==item.PSROUTVALUE and ((item.SROUT!=0 and item.PSROUTVALUE!=0)or(item.SROUT==0 and item.PSROUTVALUE==0 and item.T_DATE!=nil)))))
                        

                      if(@mdata.SETTING==item.SETTING)  
                        @countvalues=@countvalues+1
                        if item.CALCULATEBY=='S'
                          @sinval=@sinval.to_f + item.TSRIN.to_f
                          @sroutval=@sroutval.to_f + item.TSROUT.to_f
                       
                        else
                          @sinval=@sinval.to_f + item.TMTRIN.to_f
                          @sroutval=@sroutval.to_f + item.TMTROUT.to_f
                       
                        end
                        if item.MTRSHORT.to_i<0
                          @totalmtrshortmperneg=@totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
                        else
                          @totalmtrshortmperpos=@totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
                        end
                      else
                        #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                        if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                          if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                            if item.CALCULATEBY=='S'
                              @sinval=@sinval.to_f + item.TSRIN.to_f
                              @sroutval=@sroutval.to_f + item.TSROUT.to_f
                            else
                              @sinval=@sinval.to_f + item.TMTRIN.to_f
                              @sroutval=@sroutval.to_f + item.TMTROUT.to_f
                            end
                            if item.MTRSHORT.to_i<0
                              @totalmtrshortmperneg=@totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
                            else
                              @totalmtrshortmperpos=@totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
                            end
                          else
                            break
                          end
                        else
                          break
                        end
                      end   
                    end
=begin                    fp=File.new("Average.txt",'a')
            fp.write (@mdata.MACHINE_NO)
           fp.write(",")
           fp.write (@sinval)
           fp.write(",")
           fp.write(@sroutval)
           fp.write(",")
           fp.write(@totalmtrshortmperneg)
           fp.write(",")
           fp.write(@totalmtrshortmperpos)
           fp.write(",")
           fp.write(@countvalues)
           
           fp.write("\n")
           fp.close()
=end           
                    if @sinval.to_i!=0
                      
                        @cal1=roundval((roundval((@sroutval.to_f*@mdata.MTE_RATE_OUT.to_f)/10)-@totalmtrshortmperneg.to_f)*100/(roundval((@sinval.to_f*@mdata.MTR_RATE_IN.to_f)/10)+@totalmtrshortmperpos.to_f))
                      
                    else
                        @cal1=0
                      end
                      @totalmtrshortmperpos=0
                      @totalmtrshortmperneg=0
                      @sinval=0
                      @sroutval=0
                    ###New Meter % calculation ends here
                    begin
                      @mdata.MTRPER=@cal1
                    rescue
                    end
                    begin
          
                    digitn=@mno.to_s.gsub(/\D/,'')
                    charn=@mno.to_s.gsub(/\d/,'')
                    rescue Exception=>ex
                        #puts ex.message() 
                    end
         
                    @mdata.digitno=digitn
                    @mdata.charno=charn
                    
                    ####New Meter % calculation ends
                    @mdata.save
                    #savemdata(@sname,@gid,@mno,@trdate,@srin,@srout,@mtrin,@mtrout,@mtrshort,@sreason)
                    #puts "-----------------------------
                    ####Replication of Counter Data
                    #counterdata=d[1].to_a
                    #for i in 0..(counterdata.length-1)
                    #a= counterdata[i].to_s.split(',')
                    
                    ####Replication of Counter Data ends here
                end
            end
                @dataexist=Machinedata.find(:first,:conditions=>['TRANS_DATE=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@trdate,@sname,@gid,@mno,@clustername])
                if @dataexist!=nil
                else
                    
                    a=savemdata(@sname,@gid,@mno,@trdate,@srin,@srout,@mtrin,@mtrout,@mtrshort,@sreason,@clustername)
=begin
                    begin
                    @saveddata=Machinedata.find(:first,:conditions=>['TRANS_DATE=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@trdate,@sname,@gid,@mno,@clustername])
                    splitmachineno=@mc
                    
                    charn= splitmachineno.gsub(/\d/,'')
                    
                    splitmachineno1=@mc
                    digitn=splitmachineno1.gsub(/\D/,'')
                    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                    puts charn
                    puts digitn
                    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                    @saveddata.charno=charn
                    @saveddata.digitno=digitn.to_i
                    @saveddata.save
                    rescue Exception => ex
                    puts "EXCEPTION----------------"
                    puts ex.message
                    puts "EXCEPTION----------------"
                    end
=end
                    if(a==false)
                        break
                    end
                    
                end
        end
    rescue Exception=>ex
        #puts ex.message()
        @rescueflag=true
    end
    
    #######ENTER COUNTER DATA INTO counterdata table
=begin 
                    if @counterolddata==nil
                        @counter=Counterdata.new
                        @counter.ClusterName=@counterolddata.ClusterName
                        @counter.ShopName=@counterolddata.ShopName
                        @counter.Date=@counterolddata.Date
                        @counter.Cash=@counterolddata.Cash
                        @counter.Exp=@counterolddata.Exp
                        @counter.HC=@counterolddata.HC
                        @counter.Credit=@counterolddata.Credit
                        @counter.Short_Ext=@counterolddata.Short_Ext
                        @counter.Openingbal=@counterolddata.Openingbal
                        @counter.KEY1=@counterolddata.KEY1
                        @counter.KEY2=@counterolddata.KEY2
                        @counter.KEY3=@counterolddata.KEY3
                        @counter.KEY4=@counterolddata.KEY4
                        @counter.Outstanding=@counterolddata.Outstanding
                        @counter.status=@counterolddata.status
                        @counter.Total=@counterolddata.Total
                        @counter.save
                    end
=end
    
    
    replicatecounterdata(d[1].to_s)
    if(a==true)
    ###Enter Counter Data ends here
   @con=Configuration.find(1)
    
    @folderpath=@con.FilesFolderPath
    @backupfolder=@con.BackupFolderPath
    
    basedir = "#{@folderpath}/"
    targetdir="#{@backupfolder}/"
    pw=Dir.pwd() 
    Dir.chdir(basedir)
    @files=@session['file']
    i=0
    begin
    #puts "in loop"
        @files.each { |file| 
            #puts file
            if File.file?(basedir + file)      
            #puts "Moving..."
            File.move(basedir + file, targetdir + file)
            end
        } 

    Dir.chdir(pw) 
    rescue Exception=>ex
    #puts ex.message()
    #puts "in rescue file move"
    Dir.chdir(pw) 
end

      p "----------!!!!!!-------#{@sname},#{@gid},#{@trdate},#{@clustername}---------------------------------------------------------------------------------"
#      cluster_name = @clustername
#      shop_name = @sname
#      cal_short_extra(cluster_name,shop_name)

      Group.find(:all,:select=>'GroupID',:conditions=>["ClusterName=? and ShopName=?",@clustername,@sname]).each do |key|
      #Group.find_by_ClusterName_and_ShopName(@clustername,@sname).each do |key|
      p "========================>"
        p key.GroupID
      machine_data = Machinedata.find(:all,
                                      :conditions=> ["Cluster_Name=? and Shop_Name=? and TRANS_DATE=? and GROUP_ID=?",
                                      @clustername,@sname,@trdate,key.GroupID])

        p "--------------------------->"
      @tot_short_extra=0
      machine_data.each do |data|
        if data.CALCULATEBY.eql?('S')
          short_extra = (((((data.TSRIN.to_f*data.SCREEN_RATE_IN.to_f)-(data.TSROUT.to_f*data.SCREEN_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
          @tot_short_extra = @tot_short_extra + short_extra
          #ShortExtra.find_or_create_by_date_and_cluster_name_and_shop_name_and_group_id_and_short_extra("#{@trdate}","#{@clustername}","#{@sname}","#{@gid}",short_extra)
          p "----------by-S-#{@tot_short_extra}-----------"
        else
          short_extra =(((((data.TMTRIN.to_f*data.MTR_RATE_IN.to_f)-(data.TMTROUT.to_f*data.MTE_RATE_OUT.to_f))/10)*data.MULTIPLY_BY)+data.MTRSHORT.to_f).round
          @tot_short_extra = @tot_short_extra + short_extra
          p "----------by-M-#{@tot_short_extra}-----------"
          #ShortExtra.find_or_create_by_date_and_cluster_name_and_shop_name_and_group_id_and_short_extra("#{@trdate}","#{@clustername}","#{@sname}","#{@gid}",short_extra)
        end
      end

       keys = Counterdata.find(:first,:conditions=>["ClusterName=? and ShopName=? and DATE=?",
                                                            @clustername,@sname,@trdate])

#        keys = Counterdata.find_by_ClusterName_and_ShopName_and_Date('@clustername','@sname','@trdate')

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
    ShortExtra.find_or_create_by_date_and_cluster_name_and_shop_name_and_group_id_and_short_extra("#{@trdate}","#{@clustername}","#{@sname}","#{key.GroupID}",short_extra)
    end




   render :update do |page|
    page << "document.getElementById('aux_div').style.visibility = 'visible'"
    page.alert("DATA UPLOADED SUCCESSFULLY !")
    page.redirect_to url_for(:controller=>'shops', :action=>'receiveddata')
end 
    #ELSE OF WHEN ANY PROBLEM IN FILE UPLOAD
    else
    render :update do |page|
    page << "document.getElementById('aux_div').style.visibility = 'visible'"
    page.alert("PROBLEM IN FILE UPLOADED!")
    
    d=Dir.pwd()
                if File.directory?("C:\ErrorLogs")
                    f="C:/ErrorLogs"
                    Dir.chdir(f)
                    fp=File.new("Error.log","a")
                    fp.write(Time.now.to_s+"-"+a.to_s)
                    fp.write("\n")
                    fp.close()
                    Dir.chdir(d)
                else
                    e="C:/"
                    Dir.chdir(e)
                    FileUtils.mkdir_p 'ErrorLogs'
                    f="C:/ErrorLogs"
                    Dir.chdir(f)
                    fp=File.new("Error.log","a")
                    fp.write(Time.now.to_s+"-"+a.to_s)
                    fp.write("\n")
                    fp.close()
                    Dir.chdir(d)
                end
    page.redirect_to url_for(:controller=>'shops', :action=>'viewdata')
end 
    end
    rescue Exception=>ex
        #puts ex.message
    end
end
def replicatecounterdata(cdata)
    begin
    counterdata=cdata.to_a
    #puts counterdata
    for i in 0..(counterdata.length-1)

    a= counterdata[i].to_s.split(',')
    end
    @oldcdata=Counterdata.find(:first,:conditions=>['ClusterName=? and ShopName=?',a[0],a[1]],:order => "Date desc" )
    if @oldcdata==nil
        @counterolddata=Counterdata.find(:first,:conditions=>['ClusterName=? and ShopName=? and Date=?',a[0],a[1],a[2]])
        if @counterolddata==nil
            @counter=Counterdata.new
            @counter.ClusterName=a[0]
            @counter.ShopName=a[1]
            @counter.Date=a[2]
            @counter.Cash=a[3]
            @counter.Exp=a[4]
            @counter.HC=a[5]
            @counter.Credit=a[6]
            @counter.Short_Ext=a[7]
            @counter.Openingbal=a[8]
            @counter.KEY1=a[9]
            @counter.KEY2=a[10]
            @counter.KEY3=a[11]
            @counter.KEY4=a[12]
            @counter.Outstanding=a[13]
            @counter.status=a[14]
            @counter.Total=a[15]
            @counter.save
        end
    else
        @olddate=Date.parse("#{@oldcdata.Date}")
        @datediff=@currdate-@olddate
        @actualdatediff=@datediff-1
        if @actualdatediff!=0
            for i in 1..@actualdatediff
                @counter=Counterdata.new
                @counter.ClusterName=@oldcdata.ClusterName
                @counter.ShopName=@oldcdata.ShopName
                @counter.Date=@olddate+i
                @counter.Cash=@oldcdata.Cash
                #@counter.Exp=@counterolddata.Exp
                #@counter.HC=@counterolddata.HC
                @counter.Credit=@oldcdata.Credit
                #@counter.Short_Ext=@counterolddata.Short_Ext
                @counter.Openingbal=@counter.Cash.to_i+@counter.Credit.to_i
                
               #@counter.KEY1=@oldcdata.KEY1
                #@counter.KEY2=@oldcdata.KEY2
                #@counter.KEY3=@oldcdata.KEY3
                #@counter.KEY4=@oldcdata.KEY4
                #@counter.Outstanding=@counterolddata.Outstanding
                #@counter.status=@counterolddata.status
                #@counter.Total=@counterolddata.Total
                @counter.save   
            end
        end
        
    end

    @countval=Counterdata.count(:conditions=>['ClusterName=? and ShopName=? and Date=?',a[0],a[1],a[2]])
    #puts @countval
    
  
    
        if @countval.to_i==0
            #@counterolddata1=Counterdata.find(:first,:conditions=>['ClusterName=? and ShopName=? and Date=?',a[0],a[1],a[2]])
            #puts "in iffffff...................................................."
            @counter=Counterdata.new
            @counter.ClusterName=a[0]
            @counter.ShopName=a[1]
            @counter.Date=a[2]
            @counter.Cash=a[3]
            @counter.Exp=a[4]
            @counter.HC=a[5]
            @counter.Credit=a[6]
            @counter.Short_Ext=a[7]
            @counter.Openingbal=a[8]
            @counter.KEY1=a[9]
            @counter.KEY2=a[10]
            @counter.KEY3=a[11]
            @counter.KEY4=a[12]
            @counter.Outstanding=a[13]
            @counter.status=a[14]
            @counter.Total=a[15]
            @counter.save
        else
            #puts "IN else*****************************************"
        end



    rescue Exception=>ex
    #puts ex.message()
end
    
    
    
end
def savemdata(sname,gid,mno,trdate,srin,srout,mtrin,mtrout,mtrshort,sreason,cname)
          begin
          #puts "In SAVE METHOD----------------------------------------"
          ##Old SR%
=begin
           if srin.to_i!=0
            @cal=((srout.to_f*100)/srin.to_f).round
          else
            @cal=0
          end
=end

        ##old SR% ends here
        
          
          
          #if mtrin.to_i!=0
            #@cal1=((mtrout.to_f*100)/mtrin.to_f).round
          #else
            #@cal1=0
          #end
          @mdata=Machinedata.new()
          @mdata.TRANS_DATE=Chronic.parse(trdate).strftime("%Y-%m-%d")
          @mdata.T_DATE=@mdata.TRANS_DATE.strftime("%d-%b-%Y")
          @mdata.CLUSTER_NAME=cname
          @mdata.SHOP_NAME=sname
          @mdata.GROUP_ID=gid
          @mdata.MACHINE_NO=mno
         
#=begin
          #puts "(((((((((((((((((((((((("
          #puts mno
          #puts "(((((((((((((((((((((((("
          
          #d=@mdata.MACHINE_NO.to_s
          #b=@mdata.MACHINE_NO.to_s
          
          #puts machineno[0,1]
          #puts machinechar[1,3]
          begin
          
          #if machineno.to_i<=0
          digitn=mno.to_s.gsub(/\D/,'')
          charn=mno.to_s.gsub(/\d/,'')
          
          rescue Exception=>ex
          #puts ex.message() 
          end
         
          #puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
          #else
           # end
           #if machineno.to_s.length==1
          @mdata.digitno=digitn
          @mdata.charno=charn
          #else
          #end
          
          #rescue Exception=> ex
          
          #puts "++++++++++++++++++++++++"
          #puts ex.message
          #puts "++++++++++++++++++++++++"
#=end
          #@mdata.charno=g.to_s
          @mdata.SRIN=srin
          @mdata.SROUT=srout
          #@mdata.SRPER=@cal
          @mdata.PSRINVALUE=srin
          @mdata.PSROUTVALUE=srout
          @mdata.MTRIN=mtrin
          @mdata.MTROUT=mtrout
          #@mdata.MTRPER=@cal1
          @mdata.PMTRINVALUE=mtrin
          @mdata.PMTROUTVALUE=mtrout
          @mdata.MTRSHORT=mtrshort
          @mdata.SHORTREASON=sreason
          
          #@mdetails=Machine.find_first("MachineNo='#{@mno}' and GroupID='#{@gid}' and ShopName= '#{@sname}' ")
          @mdetails=Machine.find(:first,:conditions=>['MachineNo=? and GroupID=? and ShopName=? and ClusterName=?',mno,gid,sname,cname])
          
          @mdata.MACHINE_NAME=@mdetails.MachineName
          @mdata.SCREEN_RATE_IN=@mdetails.SrateIn
          @mdata.SCREEN_RATE_OUT=@mdetails.SrateOut
          @mdata.MTR_RATE_IN=@mdetails.MrateIn
          @mdata.MTE_RATE_OUT=@mdetails.MrateOut
          @mdata.MULTIPLY_BY=@mdetails.Multiplyby
          @olddate1=Date.parse("#{trdate}")-1
          #@sdate=@trdate.split('/')
          #01022009
          #@olddate1=Date.new(@sdate[2].to_i,@sdate[1].to_i,@sdate[0].to_i)-1
          @oldmdata=Machinedata.find(:first,:conditions=>['TRANS_DATE=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@olddate1,sname,gid,mno,cname])
          #if @oldmdata!=nil
            #oldsrin=@oldmdata.SRIN
            #oldsrout=@oldmdata.SROUT
            #oldmtrin=@oldmdata.MTRIN
            #oldmtrout=@oldmdata.MTROUT
            
            oldsrin=@oldmdata.PSRINVALUE
            oldsrout=@oldmdata.PSROUTVALUE
            oldmtrin=@oldmdata.PMTRINVALUE
            oldmtrout=@oldmdata.PMTROUTVALUE
            
            @mdata.TSRIN=(srin.to_i-oldsrin.to_i)#.abs#No absolute value required
            @mdata.TSROUT=(srout.to_i-oldsrout.to_i)#.abs#No absolute value required
            @mdata.TMTRIN=(mtrin.to_i-oldmtrin.to_i)#.abs No absolute required
            @mdata.TMTROUT=(mtrout.to_i-oldmtrout.to_i)#.abs No absolute req.
            #@mdata.MTRDIFFIN=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTRIN.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSRIN.to_i))/10#.abs Not required display divide by 10
            #@mdata.MTRDIFFOUT=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTROUT.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSROUT.to_i))/10#.abs Not requ
            @mdata.MTRDIFFIN=((@mdata.MTR_RATE_IN.to_i*@mdata.TMTRIN.to_i)-(@mdata.SCREEN_RATE_IN.to_i*@mdata.TSRIN.to_i))/10#.abs Not required display divide by 10
            @mdata.MTRDIFFOUT=((@mdata.MTE_RATE_OUT.to_i*@mdata.TMTROUT.to_i)-(@mdata.SCREEN_RATE_OUT.to_i*@mdata.TSROUT.to_i))/10#.abs Not requ
            @mdata.SETTING=@oldmdata.SETTING
            @mdata.LASTSETTING=@oldmdata.SETTING
              
            #Eles Not required
          #else
            
            #@mdata.TSRIN=@srin
            #@mdata.TSROUT=@srout
            #@mdata.TMTRIN=@mtrin
            #@mdata.TMTROUT=@mtrout
            #@mdata.MTRDIFFIN=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTRIN.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSRIN.to_i))/10#.abs Not required display divide by 10
            #@mdata.MTRDIFFOUT=((@mdata.MULTIPLY_BY.to_i*@mdata.TMTROUT.to_i)-(@mdata.MULTIPLY_BY.to_i*@mdata.TSROUT.to_i))/10#.abs Not requ
            #@mdata.MTRDIFFIN=0
            #@mdata.MTRDIFFOUT=0
            #@mdata.TSRIN=0
            #@mdata.TSROUT=0
            #@mdata.TMTRIN=0
            #@mdata.TMTROUT=0
            #@mdata.MTRDIFFIN=0
            #@mdata.MTRDIFFOUT=0
            
            
          #end
          @mdata.SRCOLL=(((@mdata.TSRIN.to_i*@mdata.SCREEN_RATE_IN.to_i)-(@mdata.TSROUT.to_i*@mdata.SCREEN_RATE_OUT.to_i))/10)+mtrshort.to_i####
          @mdata.MTRCOLL=(((@mdata.TMTRIN.to_i*@mdata.MTR_RATE_IN.to_i)-(@mdata.TMTROUT.to_i*@mdata.MTE_RATE_OUT.to_i))/10)+mtrshort.to_i
          
          if @mdata.MTRDIFFIN.to_i==0 and @mdata.MTRDIFFOUT.to_i==0 
            @mdata.MTRDIFFWHY='NO'
          elsif @mdata.MTRDIFFIN.to_i==0 and @mdata.MTRDIFFOUT.to_i!=0
            @mdata.MTRDIFFWHY='OUT'
          elsif @mdata.MTRDIFFIN.to_i!=0 and @mdata.MTRDIFFOUT.to_i==0
            @mdata.MTRDIFFWHY='IN'
          else
            @mdata.MTRDIFFWHY='IN/OUT'
          end
          #@mdata.SETTING='A'
          #@mdata.LASTSETTING='A'
          #@mdata.THIRTYDAYSAVG=
          if @mdata.TSRIN<0 or @mdata.TSROUT<0
             @mdata.CALCULATEBY='M'
          else
             @mdata.CALCULATEBY='S'
          end
          ####New SR% Value calculation for today---------------------------------
          #@totalmtrshortpos=0
          #@totalmtrshortneg=0
          #puts "Meter short--------------"
          #puts mtrshort
          if mtrshort.to_i<0
            @totalmtrshortpos=0
            @totalmtrshortneg=mtrshort.to_i
          else
            @totalmtrshortpos=mtrshort.to_i
            @totalmtrshortneg=0
          end
          
          #@totalmtrshort=@totalmtrshort.to_i+mtrshort.to_i
          
         
          #puts "First Total Meter Short-----------------------------"
          #puts @totalmtrshort
          #puts "First Total Meter Short-----------------------------"
          if @mdata.CALCULATEBY!='M'
            @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',sname,gid,mno,cname],:order => "TRANS_DATE desc")
            @machinevalues.each do |item|
              #if(@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))  
              #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
              #LATEST###if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and ((item.SRIN!=0 and item.PSRINVALUE!=0) or(item.SRIN==0 and item.PSRINVALUE==0 and item.T_DATE!=nil)))   or (item.SROUT==item.PSROUTVALUE and ((item.SROUT!=0 and item.PSROUTVALUE!=0)or(item.SROUT==0 and item.PSROUTVALUE==0 and item.T_DATE!=nil)))))
              if(@mdata.SETTING==item.SETTING and item.T_DATE!=nil) 
                if (item.CALCULATEBY!='M')
                  @totalmtrshort=@totalmtrshort.to_i+item.MTRSHORT.to_i
                  if item.MTRSHORT.to_i<0
                    @totalmtrshortneg=@totalmtrshortneg+item.MTRSHORT.to_i
                  else
                    @totalmtrshortpos=@totalmtrshortpos+item.MTRSHORT.to_i
                  end
                else
                  break
                end
              else
                #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                  if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                    if (item.CALCULATEBY!='M')
                      @totalmtrshort=@totalmtrshort.to_i+item.MTRSHORT.to_i
                      if item.MTRSHORT.to_i<0
                        @totalmtrshortneg=@totalmtrshortneg+item.MTRSHORT.to_i
                      else
                        @totalmtrshortpos=@totalmtrshortpos+item.MTRSHORT.to_i
                      end
                    else
                      break
                    end
                  else
                    break
                  end    
                else
                  break
                end
              end
            end
          end
          
          #puts "TOTAL METER SHORT IS--------------------"
          #puts @totalmtrshort
          #puts "TOTAL METER SHORT IS--------------------"
          #puts "After addition Total Meter Short-----------------------------"
          #puts @totalmtrshort
          #puts "After addition Total Meter Short-----------------------------"
          if srin.to_i!=0
              #puts "SRIN,SROUT and Total Meter Short value "
              #puts srin
              #puts srout
              #puts @totalmtrshort
              #puts "SRIN,SROUT and Total Meter Short value "
             outval=((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10).to_i
                        if outval!=0
                          outcal=roundval((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10)
                          else
                            outcal=roundval((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f))
                          end
                         inval=((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10).to_i
                        if inval!=0
                          incal=roundval((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10)
                          else
                            incal=roundval((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f))
                          end
                          
                        begin
                        #@cal=((((@mdata.SROUT.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10).round-@totalmtrshortneg.to_f)*100/(((@mdata.SRIN.to_f*@mdata.SCREEN_RATE_IN.to_f)/10).round+@totalmtrshortpos.to_f)).round
                        @cal=roundval(((outcal.to_i-@totalmtrshortneg.to_f)*100)/(incal.to_i+@totalmtrshortpos.to_f))
                        rescue Exception=>ex
                        #puts ex.message
                        @cal=0
                        end
                #@cal=((((srout.to_f*@mdata.SCREEN_RATE_OUT.to_f)/10).round-@totalmtrshortneg.to_f)*100/(((srin.to_f*@mdata.SCREEN_RATE_IN.to_f)/10).round+@totalmtrshortpos.to_f)).round
              
              
          else
            @cal=0
          end
          #puts "SRPER VALUE---------------"
          #puts @cal
          #puts "SRPER VALUE---------------"
          @mdata.SRPER=@cal
          ####New SR % value calculation for today ends here--------------------- 
          if @mdata.SRCOLL<0 or @mdata.MTRCOLL<0
            @mdata.LOSS='Loss'
          else
            @mdata.LOSS='Profit'
          end
          ###Code for Averages----------------------------------------------------------------------------------------------
          @count=Machinedata.count(:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=? and T_DATE!=""',sname,gid,mno,cname])
          #puts "------------------------------------------"
          #puts @count
          #puts "------------------------------------------"
          ###Code for Thirty day average
                    if @count.to_i>=29
                        #puts "in 30 loop ************************************************"
                        @values30=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@sname,@gid,@mno,@clustername],:order => "TRANS_DATE desc")
                        @sumvalue30=0
                        @countval=0
                        @flag=false
                        @values30.each do |item|
                            if @countval.to_i<29
                                if item.CALCULATEBY=='S'
                                    @sumvalue30=@sumvalue30.to_i+item.SRCOLL
                                else
                                    @sumvalue30=@sumvalue30.to_i+item.MTRCOLL
                                end
                                @flag=true  
                                @countval=@countval.to_i+1
                            end
                            
                        end
                        if @flag==true
            
                          if @mdata.CALCULATEBY=='S'
                            @sumvalue30=@sumvalue30.to_i+@mdata.SRCOLL.to_i
                          else
                            @sumvalue30=@sumvalue30.to_i+@mdata.MTRCOLL.to_i
                          end
                          @thirtyavg=roundval(@sumvalue30.to_f/30)
                          @mdata.THIRTYDAYSAVG=@thirtyavg
                          @flag=false
                        else
                        end  
                    else
                        #puts "Less then thirty"
                        #@mdata.THIRTYDAYSAVG=-1
                    end
                    ###Code for Thirty day average ends
          
          ###Code for 10 days average
          #puts @count.to_i
          @countval10=1
          #puts "Count"
          if @count.to_i>=9
            #puts "Greater then 10"
            @values10=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',sname,gid,mno,cname],:order => "TRANS_DATE desc")
            @sumvalue10=0
            
            @flag=false
            @values10.each do |item|
              #puts "&&&&&&&&&&&&&&&&&&&&&&&&7"
              #puts @countval101
              if @countval10.to_i<=9
                             
                
                if item.CALCULATEBY=='S'
                  @sumvalue10=@sumvalue10.to_i+item.SRCOLL.to_i
                else
                  @sumvalue10=@sumvalue10.to_i+item.MTRCOLL.to_i
                end
                @flag=true
               
             
              end
               @countval10=@countval10.to_i+1
             end
             #puts "aasaas"
             #puts @countval101 
            if @flag==true
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              #puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::"
              if @mdata.CALCULATEBY=='S'
                @sumvalue10=@sumvalue10.to_i+@mdata.SRCOLL.to_i
              else
                @sumvalue10=@sumvalue10.to_i+@mdata.MTRCOLL.to_i
              end
              @tenavg=roundval(@sumvalue10.to_f/10)
              @mdata.TENDAYSAVG=@tenavg
              @flag=false
            else
            end
          else
            #puts "Less then 10"
            
          end
          ###Code for 10 days average ends here
          ###Screen average calculations
          @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=? ',sname,gid,mno,cname],:order => "TRANS_DATE desc")
          @srvalues=0
          if @mdata.CALCULATEBY=='S'
              @srvalues=@mdata.SRCOLL
            else
                @srvalues=@mdata.MTRCOLL
            end
          
          
          @valcount=2
          @machinevalues.each do |item|
              #puts item.TRANS_DATE
            #if(item.SETTING!=item.LASTSETTING and (item.SRIN!=item.PSRIN  or (item.SRIN==0 and item.PSRIN==0)) and (item.SROUT!=item.PSROUT or (item.SROUT==0 and item.PSROUT==0)) 
            #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))) 
            #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
            #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
            #LATEST##if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and ((item.SRIN!=0 and item.PSRINVALUE!=0) or(item.SRIN==0 and item.PSRINVALUE==0 and item.T_DATE!=nil)))   or (item.SROUT==item.PSROUTVALUE and ((item.SROUT!=0 and item.PSROUTVALUE!=0)or(item.SROUT==0 and item.PSROUTVALUE==0 and item.T_DATE!=nil)))))
            if(@mdata.SETTING==item.SETTING and item.T_DATE!=nil) 
                #puts "in else"
               @valcount=@valcount+1
              if item.CALCULATEBY=='S'
                  @srvalues=@srvalues+item.SRCOLL.to_i
              else
                  @srvalues=@srvalues+item.MTRCOLL.to_i
              end
             
            else
                #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                  if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                    if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                      @valcount=@valcount+1
                      if item.CALCULATEBY=='S'
                        @srvalues=@srvalues+item.SRCOLL.to_i
                      else
                        @srvalues=@srvalues+item.MTRCOLL.to_i
                      end
                    else
                      break
                    end    
                  else
                    break
                  end
            end
          end
        begin
         if @valcount.to_i<=2
                     @valcount=1
                   else
                       @valcount=@valcount.to_i-1
                 end
       
        @mdata.SRAVG=roundval(@srvalues.to_f/(@valcount.to_i))
          #puts @mdata.SRAVG
        rescue Exception=>ex
            @mdata.SRAVG=@srvalues
        end
        
          ### Screen average calculations end here
        ####Averages code ends here-----------------------------------------------------------
        ####Meter % calculation
        @sinval=0
        @sroutval=0
        @totalmtrshortmperneg=0
        @totalmtrshortmperpos=0
            @machinevalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',sname,gid,mno,cname],:order => "TRANS_DATE desc")
            if @mdata.CALCULATEBY=='S'
              @sinval=@mdata.TSRIN.to_i
              @sroutval=@mdata.TSROUT.to_i
            else
               @sinval=@mdata.TMTRIN.to_i
               @sroutval=@mdata.TMTROUT.to_i
           end
            ### New Meter % calculation
            if mtrshort.to_i<0
                @totalmtrshortmperneg=mtrshort.to_i
                @totalmtrshortmperpos=0
            else
                @totalmtrshortmperneg=0
                @totalmtrshortmperpos=mtrshort.to_i
            end
            #@totalmtrshort=@totalmtrshort.to_i+mtrshort.to_i
           #@sinval=0
           #@sroutval=0
              @machinevalues.each do |item|
                #LATEST#if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and ((item.SRIN!=0 and item.PSRINVALUE!=0) or(item.SRIN==0 and item.PSRINVALUE==0 and item.T_DATE!=nil)))   or (item.SROUT==item.PSROUTVALUE and ((item.SROUT!=0 and item.PSROUTVALUE!=0)or(item.SROUT==0 and item.PSROUTVALUE==0 and item.T_DATE!=nil)))))
                ## previous to aabove if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE and (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE and (item.SROUT!=0 and item.PSROUTVALUE!=0))))
                #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))) 
                #if((@mdata.SETTING==item.SETTING) and ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))) 
                if(@mdata.SETTING==item.SETTING)  
                    
                    
                    if item.CALCULATEBY=='S'
                        @sinval=@sinval.to_f + item.TSRIN.to_f
                        @sroutval=@sroutval.to_f + item.TSROUT.to_f
                       
                    else
                        @sinval=@sinval.to_f + item.TMTRIN.to_f
                        @sroutval=@sroutval.to_f + item.TMTROUT.to_f
                       
                   end
                    if item.MTRSHORT.to_i<0
                      @totalmtrshortmperneg=@totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
                    else
                      @totalmtrshortmperpos=@totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
                    end
                    #puts "----------------"
                    #puts @mdata.MACHINE_NO
                    #puts @sinval
                    
                    #puts  @sroutval
                    #puts @totalmtrshortmperneg
                    #@totalmtrshortmperpos
                    #puts "----------------"
                else
                  #if ((item.SRIN==item.PSRINVALUE or (item.SRIN!=0 and item.PSRINVALUE!=0))   or (item.SROUT==item.PSROUTVALUE or (item.SROUT!=0 and item.PSROUTVALUE!=0)))
                  if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
                    if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
                      if item.CALCULATEBY=='S'
                        @sinval=@sinval.to_f + item.TSRIN.to_f
                        @sroutval=@sroutval.to_f + item.TSROUT.to_f
                      else
                        @sinval=@sinval.to_f + item.TMTRIN.to_f
                        @sroutval=@sroutval.to_f + item.TMTROUT.to_f
                      end
                      if item.MTRSHORT.to_i<0
                        @totalmtrshortmperneg=@totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
                      else
                        @totalmtrshortmperpos=@totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
                      end
                    else
                      break
                    end
                  else
                    break
                  end
                end   
              end
=begin
           puts "***********************************************"
            
           fp=File.new("text.txt",'a')
           fp.write (@mdata.MACHINE_NO)
           fp.write(",")
            fp.write (@sinval)
            fp.write(",")
           fp.write (@sroutval)
           fp.write(",")
           fp.write (@totalmtrshortmperneg)
           fp.write(",")
           fp.write (@totalmtrshortmperpos)
          
           fp.write("\n")
           
           fp.close()
         
           puts "***********************************************"
=end
            if @sinval.to_i!=0
             
                @cal1=roundval((roundval((@sroutval.to_f*@mdata.MTE_RATE_OUT.to_f)/10)-@totalmtrshortmperneg.to_f)*100/(roundval((@sinval.to_f*@mdata.MTR_RATE_IN.to_f)/10)+@totalmtrshortmperpos.to_f))
              
            else
              @cal1=0
            end
            
            
            ###New Meter % calculation ends here

            begin
                @mdata.MTRPER=@cal1
            rescue
            end
          
           
        ####Meter % calculation ends
=begin   

        ###Meter % calculation
          @mtrvalues=Machinedata.find(:all,:conditions=>['SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',sname,gid,mno,cname],:order => "TRANS_DATE desc")
          @tmtrin=@mdata.TMTRIN.to_i
          @tmtrout=@mdata.TMTROUT.to_i
          @valcount=0
          @mtrvalues.each do |item|
            if (((@mdata.SRIN!=item.SRIN) or (@mdata.SROUT!=item.SROUT) ) and (@mdata.SETTING!=item.SETTING)) or (((@mdata.SRIN==0 and item.SRIN==0) or (@mdata.SROUT==0 and item.SROUT==0)) and (@mdata.SETTING!=item.SETTING))
              
              break
            else
              #@valcount=@valcount+1
              @tmtrin=@tmtrin+item.TMTRIN.to_i
              @tmtrout=@tmtrout+item.TMTROUT.to_i
            end
        end
        begin
          @mdata.MTRPER=((@tmtrout.to_i*100)/@tmtrin.to_i).to_i
        rescue
        end
          ### Meter % calculation ends here
=end
          @mdata.save
          
          return true
          rescue Exception=>ex
          return ex.message
          end
         # puts "Save Fineshed...................."
      end



def search
    begin
    #puts "in search"
    @session['cluster']=params[:shop][:ClusterName]
    redirect_to :action=>'list'
    rescue Exception=>ex
        #puts ex.message
    end
end

def getCluster
    begin
    
    #puts "IN GROUP"
    #puts params[:ClusterName]
    #puts @session['cluster']
    if(params[:ClusterName]!="" or params[:ClusterName]!=nil)
        #@session[:shopname]=params[:ShopName]
      @session['cluster']=params[:ClusterName]
    end
      #puts @session['cluster']
      render :update do |page|
	
       page << "document.getElementById('shop_ShopName').focus();"
    end
rescue Exception=>exc
     #puts exc.message
end
end

 def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @shop_pages, @shops = paginate :shops, :per_page => 10
  end

  def show
    @shop = Shop.find(params[:id])
  end

  def new
    #@shop=nil
    @shop = Shop.new
  end

  def create
      
    @shop = Shop.new(params[:shop])
    if @shop.save
          @previousrecord = Previousrecord.new
          @previousrecord.Date=Date.today
          @previousrecord.ShopName=params[:shop][:ShopName]
          @previousrecord.Openingbal=params[:shop][:OpeningBal]
          @previousrecord.Xcash=@shop.Cash
          @previousrecord.Xcredit=@shop.Credit
          @previousrecord.save
         
      flash[:notice] =  '<font color=green size=3><b>SHOP WAS SUCCESSFULLY CREATED.</b></font>'
      redirect_to :action=>'new'
      #render :action => 'new'
    else
      render :action => 'new'
    end
  end

  def edit
    @shop = Shop.find(params[:id])
  end

  def update
    
    @shop = Shop.find(params[:id])
    if @shop.update_attributes(params[:shop])
        @p=Previousrecord.find_first(["ShopName=?",params[:shop][:ShopName]])
        if(@p!=nil)
        @p.Date=Date.today
        @p.Xcash=@shop.Cash
        @p.Xcredit=@shop.Credit
        @p.Openingbal=params[:shop][:OpeningBal]
        @p.save
        end
     flash[:notice] =  '<font color=green size=3><b>SHOP WAS SUCCESSFULLY UPDATED.</b></font>'
      redirect_to :action => 'list', :id => @shop
    else
      render :action => 'edit'
    end
  end

  def destroy
    Shop.find(params[:id]).destroy
    redirect_to :action => 'list'
end
    def canceladd
    render :update do |page|
    page.redirect_to url_for(:controller=>'shops', :action=>'search')
    end
end




#METHOD WHILE CREATING A NEW clientdata
def createpreviousdata
    
   
    
    if params[:clientdata][:ScreenIN]==""
        flash[:notice]="Screen IN can't be empty"
        render :action => 'previousdata'
    else
        if((params[:clientdata][:ShopName]==nil or params[:clientdata][:ShopName]=="") and @session[:shopname]!=nil)
            #puts "in if"
            params[:clientdata][:ShopName]=@session[:shopname]
            #puts params[:clientdata][:ShopName]
        end
        
        if((params[:clientdata][:GroupID]==nil or params[:clientdata][:GroupID]=="") and @session[:Groupid]!=nil)
            #puts @session[:Groupid]
            params[:clientdata][:GroupID]=@session[:Groupid]
             
         end
         
         
         if((params[:clientdata][:MachineNo]==nil or params[:clientdata][:MachineNo]=="") and @session[:MachineNo]!=nil)
            params[:clientdata][:MachineNo]=@session[:MachineNo]
             
         end
         if((params[:clientdata][:MachineName]==nil or params[:clientdata][:MachineName]=="") and @session[:MachineName]!=nil)
            params[:clientdata][:MachineName]=@session[:MachineName]
             
         end
         #puts "DATE"
        @date=Date.parse(params[:clientdata][:Date])
        #puts @date
        @duprecord=Machinedata.find_first(["Shop_Name=? and Group_ID=? and Machine_No=? and Machine_Name=?  and trans_date=?",params[:clientdata][:ShopName],params[:clientdata][:GroupID],params[:clientdata][:MachineNo],params[:clientdata][:MachineName],@date])
        
        
        if(@duprecord!=nil)
            flash[:notice]="<font color=red size=4><b>DUPLICATE ENTRY FOR MACHINE No. #{params[:clientdata][:MachineNo]}</b></font> "
            render :action => 'previousdata'
        else
            
            @cluster=Shop.find_first(["ShopName=?",params[:clientdata][:ShopName]])
            params[:clientdata][:ClusterName]=@cluster.ClusterName
            #puts "jjjjjjjj"
            
  
            
            @data=Machinedata.new
            @data.SHOP_NAME=params[:clientdata][:ShopName]
             @data.GROUP_ID=params[:clientdata][:GroupID]
             @data.TRANS_DATE=@date
              @data.MACHINE_NO=params[:clientdata][:MachineNo]
               @data.MACHINE_NAME=params[:clientdata][:MachineName]
                @data.SRIN=params[:clientdata][:ScreenIN]
                 @data.SROUT=params[:clientdata][:ScreenOUT]
                  @data.MTRIN=params[:clientdata][:MeterIN]
                   @data.MTROUT=params[:clientdata][:MeterOUT]
                    @data.SETTING="A"
                    @data.LASTSETTING=@date
                    
            
             if @data.save
                flash[:confirm] = '<font color=green size=4><b>ENTRY WAS SUCCESSFULLY CREATED.</b></font>'
                @session[:MachineNo]=nil
                @session[:MachineName]=nil
                render :action => 'previousdata'
            else
                render :action => 'previousdata'
            end
            
            
        end
    end
    
end

end
