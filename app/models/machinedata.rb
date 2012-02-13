class Machinedata < ActiveRecord::Base
  def self.update_machinedata(data)
    mdata = Machinedata.find_by_CLUSTER_NAME_and_SHOP_NAME_and_TRANS_DATE_and_GROUP_ID_and_MACHINE_NO(data[0],data[1],data[2],data[3],data[4])
#    debugger
    unless mdata.blank?
       pmcndata = Machinedata.find_by_CLUSTER_NAME_and_SHOP_NAME_and_TRANS_DATE_and_GROUP_ID_and_MACHINE_NO(data[0],data[1],(Date.parse(data[2])-1).to_s,data[3],data[4])
              oldsrin=pmcndata.PSRINVALUE
              oldsrout=pmcndata.PSROUTVALUE
              oldmtrin=pmcndata.PMTRINVALUE
              oldmtrout=pmcndata.PMTROUTVALUE
              tsrin = (data[5].to_i-oldsrin.to_i)
              tsrout = (data[6].to_i-oldsrout.to_i)
              tmtrin = (data[7].to_i-oldmtrin.to_i)
              tmtrout = (data[8].to_i-oldmtrout.to_i)
              srper = cal_sr_percentage(data,mdata)
              mtrper = cal_mtr_percentage(data,mdata)
              p tsrin,tsrout,tmtrin,tmtrout,srper,mtrper
              mtrdiffin=((mdata.MTR_RATE_IN.to_i*tmtrin.to_i)-(mdata.SCREEN_RATE_IN.to_i*tsrin.to_i))/10
              mtrdiffout=((mdata.MTE_RATE_OUT.to_i*tmtrout.to_i)-(mdata.SCREEN_RATE_OUT.to_i*tsrout.to_i))/10
              p tsrin,tsrout,tmtrin,tmtrout,srper,mtrper,mtrdiffin,mtrdiffout
              mtrshort = (mdata.MTRSHORT.to_i/mdata.MULTIPLY_BY.to_i)
              srcoll=(((tsrin.to_i*mdata.SCREEN_RATE_IN.to_i)-(tsrout.to_i*mdata.SCREEN_RATE_OUT.to_i))/10)+mtrshort.to_i
              p tsrin,tsrout,tmtrin,tmtrout,srper,mtrper,mtrdiffin,mtrdiffout,mtrshort,srcoll
              mtrcoll=(((tmtrin.to_i*mdata.MTR_RATE_IN.to_i)-(tmtrout.to_i*mdata.MTE_RATE_OUT.to_i))/10)+mtrshort.to_i
              p tsrin,tsrout,tmtrin,tmtrout,srper,mtrper,mtrdiffin,mtrdiffout,mtrshort,srcoll,mtrcoll
              thirtydaysavg = cal_thirtydaysavg(data,mdata)
              p tsrin,tsrout,tmtrin,tmtrout,srper,mtrper,mtrdiffin,mtrdiffout,mtrshort,srcoll,mtrcoll,thirtydaysavg


#      @mdata.MTRDIFFIN=((@mdata.MTR_RATE_IN.to_i*@mdata.TMTRIN.to_i)-(@mdata.SCREEN_RATE_IN.to_i*@mdata.TSRIN.to_i))/10
#              @mdata.MTRDIFFOUT=((@mdata.MTE_RATE_OUT.to_i*@mdata.TMTROUT.to_i)-(@mdata.SCREEN_RATE_OUT.to_i*@mdata.TSROUT.to_i))/10
#      @oldmdatanew=Machinedata.find(:first,:conditions=>['TRANS_DATE=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and CLUSTER_NAME=?',@mdata.TRANS_DATE-1,@sname,@gid,@mno,@clustername])
      mdata.update_attributes(:SRIN=>data[5],:SROUT=>data[6],:MTRIN=>data[7],:MTROUT=>data[8],
                                :PSRINVALUE=>data[5],:PSROUTVALUE=>data[6],:PMTRINVALUE=>data[7],:PMTROUTVALUE=>data[8],
                              :TSRIN=>tsrin,:TSROUT=>tsrout,:TMTRIN=>tmtrin,:TMTROUT=>tmtrout,
                            :SRPER=>srper,:MTRPER=>mtrper,:MTRDIFFIN=>mtrdiffin,:MTRDIFFIN=>mtrdiffout)
    end
  end

  def self.cal_thirtydaysavg(data,mdata)
      count = Machinedata.count(:conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and T_DATE!="" and GROUP_ID=? and MACHINE_NO=? ',data[0],data[1],data[3],data[4]])
      if count.to_i>=29
        values30=Machinedata.find(:all,:conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? ',data[0],data[1],data[3],data[4]],:order => "TRANS_DATE desc")
        sumvalue30=0
        countval=0
        flag=false
        values30.each do |item|
          if countval.to_i<29
            if item.CALCULATEBY=='S'
              sumvalue30=sumvalue30.to_i+item.SRCOLL
            else
              sumvalue30=sumvalue30.to_i+item.MTRCOLL
            end
            flag=true
            countval=countval.to_i+1
          end
        end
        if flag==true
          if mdata.CALCULATEBY=='S'
            sumvalue30=sumvalue30.to_i+mdata.SRCOLL.to_i
          else
            sumvalue30=sumvalue30.to_i+mdata.MTRCOLL.to_i
          end
          return roundval(sumvalue30.to_f/30)
          flag=false
        else
        end
      else
      end
  end
  
  def self.cal_totmtrshortneg_and_totmtrshortpos(data,mdata)
              totalmtrshortneg=0
              totalmtrshortpos=0
              if mdata.CALCULATEBY=='M'
                machinevalues=Machinedata.find(:all,
                                               :conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=?',
                                                 data[0],data[1],data[3],data[4]],
                                               :order => "TRANS_DATE desc")
                machinevalues.each do |item|
                  if(mdata.SETTING==item.SETTING and item.T_DATE!=nil)
                    if (item.CALCULATEBY=='M')
                      totalmtrshort=totalmtrshort.to_i+item.MTRSHORT.to_i
                      if item.MTRSHORT.to_i<0
                        totalmtrshortneg=totalmtrshortneg+item.MTRSHORT.to_i
                      else
                        totalmtrshortpos=totalmtrshortpos+item.MTRSHORT.to_i
                      end
                    else
                      break
                    end
                  else
                    if ((item.MTRIN!=0 and item.PMTRINVALUE!=0) or (item.SROUT!=0 and item.PMTROUTVALUE!=0))
                      if ((item.MTRIN==item.PMTRINVALUE )   or (item.MTROUT==item.PSROUTVALUE ))
                        if (item.CALCULATEBY!='M')
                          totalmtrshort=totalmtrshort.to_i+item.MTRSHORT.to_i
                          if item.MTRSHORT.to_i<0
                            totalmtrshortneg=totalmtrshortneg+item.MTRSHORT.to_i
                          else
                            totalmtrshortpos=totalmtrshortpos+item.MTRSHORT.to_i
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
  end

  def self.cal_sr_percentage(data,mdata)
    if data[5]!=0
                outval=((data[6].to_f*mdata.SCREEN_RATE_OUT.to_f)/10).to_i
                if outval!=0
                  outcal=roundval((data[6].to_f*mdata.SCREEN_RATE_OUT.to_f)/10)
                else
                  outcal=roundval((data[6].to_f*mdata.SCREEN_RATE_OUT.to_f))
                end
                inval=((data[5].to_f*mdata.SCREEN_RATE_IN.to_f)/10).to_i
                if inval!=0
                  incal=roundval((data[5].to_f*mdata.SCREEN_RATE_IN.to_f)/10)
                else
                  incal=roundval((data[5].to_f*mdata.SCREEN_RATE_IN.to_f))
                end
                totalmtrshortneg,totalmtrshortpos = cal_totmtrshortneg_and_totmtrshortpos(data,mdata)
                begin
                  cal=roundval(((outcal.to_i-totalmtrshortneg.to_f)*100)/(incal.to_i+totalmtrshortpos.to_f))
                rescue Exception=>ex
                  cal=0
                end
              else
                cal=0
              end
end

  def self.cal_mtr_percentage(data,mdata)
    if data[5]!=0
                outval=((data[8].to_f*mdata.MTE_RATE_OUT.to_f)/10).to_i
                if outval!=0
                  outcal=roundval((data[6].to_f*mdata.MTE_RATE_OUT.to_f)/10)
                else
                  outcal=roundval((data[6].to_f*mdata.MTE_RATE_OUT.to_f))
                end
                inval=((data[5].to_f*mdata.MTR_RATE_IN.to_f)/10).to_i
                if inval!=0
                  incal=roundval((data[5].to_f*mdata.MTR_RATE_IN.to_f)/10)
                else
                  incal=roundval((data[5].to_f*mdata.MTR_RATE_IN.to_f))
                end
                totalmtrshortneg,totalmtrshortpos = cal_totmtrshortneg_and_totmtrshortpos(data,mdata)
                begin
                  cal=roundval(((outcal.to_i-totalmtrshortneg.to_f)*100)/(incal.to_i+totalmtrshortpos.to_f))
                rescue Exception=>ex
                  cal=0
                end
              else
                cal=0
              end
  end
#  def self.cal_mtr_percentage(data,mdata)
#              totalmtrshortmperpos=0
#              totalmtrshortmperneg=0
#              sinval=0
#              sroutval=0
#              countvalues=0
#              machinevalues=Machinedata.find(:all,
#                                             :conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? ',data[0],data[1],data[3],data[4]],
#                                             :order => "TRANS_DATE desc")
#              machinevalues.each do |item|
#                if(mdata.SETTING==item.SETTING)
#                  countvalues=countvalues+1
#                  if item.CALCULATEBY=='S'
#                    sinval=sinval.to_f + item.TSRIN.to_f
#                    sroutval=sroutval.to_f + item.TSROUT.to_f
#                  else
#                    sinval=sinval.to_f + item.TMTRIN.to_f
#                    sroutval=sroutval.to_f + item.TMTROUT.to_f
#                  end
#                  if item.MTRSHORT.to_i<0
#                    totalmtrshortmperneg=totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
#                  else
#                    totalmtrshortmperpos=totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
#                  end
#                else
#                  if ((item.SRIN!=0 and item.PSRINVALUE!=0) or (item.SROUT!=0 and item.PSROUTVALUE!=0))
#                    if ((item.SRIN==item.PSRINVALUE )   or (item.SROUT==item.PSROUTVALUE ))
#                      if item.CALCULATEBY=='S'
#                        sinval=sinval.to_f + item.TSRIN.to_f
#                        sroutval=sroutval.to_f + item.TSROUT.to_f
#                      else
#                        sinval=sinval.to_f + item.TMTRIN.to_f
#                        sroutval=sroutval.to_f + item.TMTROUT.to_f
#                      end
#                      if item.MTRSHORT.to_i<0
#                        totalmtrshortmperneg=totalmtrshortmperneg.to_i+item.MTRSHORT.to_i
#                      else
#                        totalmtrshortmperpos=totalmtrshortmperpos.to_i+item.MTRSHORT.to_i
#                      end
#                    else
#                      break
#                    end
#                  else
#                    break
#                  end
#                end
#              end
#    if sinval.to_i!=0
#      cal1=roundval((roundval((sroutval.to_f*mdata.MTE_RATE_OUT.to_f)/10)-totalmtrshortmperneg.to_f)*100/(roundval((sinval.to_f*mdata.MTR_RATE_IN.to_f)/10)+totalmtrshortmperpos.to_f))
#    else
#      cal1=0
#    end
#  end

  def self.roundval(val)
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

end
