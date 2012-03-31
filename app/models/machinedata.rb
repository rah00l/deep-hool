class Machinedata < ActiveRecord::Base

  #after_update :calculate_short_extra
  
  def self.update_machinedata(data)
    Machinedata.transaction do
    mdata = Machinedata.find_by_CLUSTER_NAME_and_SHOP_NAME_and_TRANS_DATE_and_GROUP_ID_and_MACHINE_NO(data[0],data[1],data[2],data[3],data[4])
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
      mtrdiffin=((mdata.MTR_RATE_IN.to_i*tmtrin.to_i)-(mdata.SCREEN_RATE_IN.to_i*tsrin.to_i))/10
      mtrdiffout=((mdata.MTE_RATE_OUT.to_i*tmtrout.to_i)-(mdata.SCREEN_RATE_OUT.to_i*tsrout.to_i))/10
      mtrshort = (mdata.MTRSHORT.to_i/mdata.MULTIPLY_BY.to_i)
      srcoll=(((tsrin.to_i*mdata.SCREEN_RATE_IN.to_i)-(tsrout.to_i*mdata.SCREEN_RATE_OUT.to_i))/10)+mtrshort.to_i
      mtrcoll=(((tmtrin.to_i*mdata.MTR_RATE_IN.to_i)-(tmtrout.to_i*mdata.MTE_RATE_OUT.to_i))/10)+mtrshort.to_i
      cal_by = mdata.CALCULATEBY.eql? "S"
      curcoll = cal_by == true ? srcoll : mtrcoll
      thirtydaysavg = cal_daysavg(data,mdata,curcoll,30)
      tendaysavg = cal_daysavg(data,mdata,curcoll,10)
      sravg = sr_avg(data,mdata,curcoll,pmcndata)
      mdata.update_attributes(:SRIN=>data[5],:SROUT=>data[6],:MTRIN=>data[7],:MTROUT=>data[8],
        :PSRINVALUE=>data[5],:PSROUTVALUE=>data[6],:PMTRINVALUE=>data[7],:PMTROUTVALUE=>data[8],
        :TSRIN=>tsrin,:TSROUT=>tsrout,:TMTRIN=>tmtrin,:TMTROUT=>tmtrout,
        :SRPER=>srper,:MTRPER=>mtrper,:MTRDIFFIN=>mtrdiffin,:MTRDIFFOUT=>mtrdiffout,
        :SRCOLL=>srcoll,:MTRCOLL=>mtrcoll,
        :THIRTYDAYSAVG=>thirtydaysavg,:TENDAYSAVG=>tendaysavg,
        :SRAVG=>sravg)
    end
    end
  end


  def self.sr_avg(data,mdata,curcoll,pmcndata)
    condition = false
    if mdata.SETTING!=pmcndata.SETTING
      if mdata.SRIN!=pmcndata.SRIN  || pmcndata.PSRINVALUE.value==0 && pmcndata.SRIN==0
        curcoll*data.MULTIPLY_BY
        condition=true
      else
        curcoll
      end
    else
      curcoll
    end
    if condition!=false
      condition=false
    else
      machinevalues=Machinedata.find(:all,
        :conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and TRANS_DATE<?',data[0],data[1],data[3],data[4],data[2]],
        :order => "TRANS_DATE desc")
      srvalues=0
      valcount=2
      machinevalues.each do |item|
        if mdata.SETTING==item.SETTING and item.T_DATE!=nil
          valcount=valcount+1
          if item.CALCULATEBY=='S'
            srvalues=srvalues+item.SRCOLL.to_i
          else
            srvalues=srvalues+item.MTRCOLL.to_i
          end
        else
          if item.SRIN!=0 && item.PSRINVALUE!=0 || item.SROUT!=0 and item.PSROUTVALUE!=0
            if item.SRIN==item.PSRINVALUE   || item.SROUT==item.PSROUTVALUE
              valcount=valcount+1
              if item.CALCULATEBY=='S'
                srvalues=srvalues+item.SRCOLL.to_i
              else
                srvalues=srvalues+item.MTRCOLL.to_i
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
        totalsum=srvalues.to_i
        totalcount=valcount.to_i
        if totalcount<=2
          totalcount=1
        else
          totalcount=totalcount-1
          totalavg = (curcoll.to_i + totalsum.to_i)/totalcount.to_i
          return roundval(totalavg.to_f)*mdata.MULTIPLY_BY
          #            rescue
        end
      end

    end
  end

  def self.cal_daysavg(data,mdata,coll,days)
    count = Machinedata.count(:conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and T_DATE!="" and GROUP_ID=? and MACHINE_NO=? and TRANS_DATE<=? ',data[0],data[1],data[3],data[4],data[2]])
    countval30 = 1
    if count.to_i>(days.to_i-1)
      values30 = Machinedata.find(:all,:conditions=>['CLUSTER_NAME=? and SHOP_NAME=? and GROUP_ID=? and MACHINE_NO=? and TRANS_DATE<?',data[0],data[1],data[3],data[4],data[2]],:order => "TRANS_DATE desc")
      sumvalue30=0
      countval=0
      flag=false
      values30.each do |item|
        if countval.to_i<(days.to_i-1)
          if item.CALCULATEBY=='S'
            sumvalue30=sumvalue30.to_i+item.SRCOLL.to_i
          else
            sumvalue30=sumvalue30.to_i+item.MTRCOLL.to_i
          end
          flag=true
          countval=countval.to_i+1
        end
      end

      tot30davg=0
      if flag==true
        if mdata.CALCULATEBY=='S'
          tot30davg=sumvalue30.to_i+coll.to_i
        else
          tot30davg=sumvalue30.to_i+coll.to_i
        end
        flag=false
        return roundval(tot30davg.to_f/days.to_f)*mdata.MULTIPLY_BY
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


  private
  def calculate_short_extra

          Group.find_all_by_ClusterName_and_ShopName(self.CLUSTER_NAME,self.SHOP_NAME).each do |key|

        machine_data = Machinedata.find_all_by_CLUSTER_NAME_and_SHOP_NAME_and_TRANS_DATE_and_GROUP_ID(self.CLUSTER_NAME,self.SHOP_NAME,(self.TRANS_DATE).strftime("%Y-%m-%d"),key.GroupID)

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
              self.CLUSTER_NAME,self.SHOP_NAME,self.TRANS_DATE])
          if keys!= nil
            if key.GroupID.eql?('KEY 1')
              keyval=keys.KEY1.to_i
            end
            if key.GroupID=='KEY 2'
              keyval=keys.KEY2.to_i
            end
            if key.GroupID=='KEY 3'
              keyval=keys.KEY3.to_i
            end
            if key.GroupID=='KEY 4'
              keyval=keys.KEY4.to_i
            end
          end
          short_extra = (keyval.to_i - @tot_short_extra.to_i)
          ShortExtra.find_or_create_by_date_and_cluster_name_and_shop_name_and_group_id_and_short_extra((self.TRANS_DATE).strftime("%Y-%m-%d"),self.CLUSTER_NAME,self.SHOP_NAME,"#{key.GroupID}",short_extra)
        end
  end

end
