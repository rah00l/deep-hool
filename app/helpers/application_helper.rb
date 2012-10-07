# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def previous_month_avg_hc(cluster_name,shop_name,date)
    date = date.to_s
    first_date,last_date = get_last_months_last_date(date)
    avg = Counterdata.average(:HC,:conditions=>["clustername=? and shopname=? and date>=? and date<=?",cluster_name,shop_name,first_date,last_date]).round
  end

  def target_percentage(pre_month_avg_hc,target)
    percent_target = ((pre_month_avg_hc.to_f/target.to_f)*100).round
    tar = 100 - percent_target
    target_achive = tar.abs
    pre = '- '
    post = '%'
    percent_font_color(pre,pre_month_avg_hc,target,target_achive,post)
  end

  def percent_font_color(pre,first_value,second_value,result,post)
    if first_value.to_i < second_value.to_i
      return ("<span style='color:#f00;font-weight:bold;'>"+ pre.to_s + result.to_s + post.to_s + "</span>")
    else
      return ("<span style='color:blue;font-weight:bold;'>" + ''.to_s +  result.to_s + post.to_s  + "</span>")
    end
  end

  def get_last_months_last_date(date)
    last_date = (Date.parse(Date.parse(date.to_s).strftime('%Y-%m-01'))-1).to_s
    first_date = Date.parse(last_date).strftime('%Y-%m-01')
    return first_date,last_date
  end

  def get_prevdate_os(shop_name,date)
    outstand_prev_entry = Countercollection.find_by_ShopName(shop_name,:order => 'Date desc')
    os  = outstand_prev_entry.blank? ? Shop.find_by_ShopName(shop_name).os : Countercollection.find_by_ShopName(shop_name,:order => 'Date desc').os
  end

  def short_extra_values(date1,date2,cluster_name,shop_name,group_id)
    se = ShortExtra.sum(:short_extra,:conditions => ["cluster_name=? and shop_name=? and group_id=? and Date>=? and Date<=? ",cluster_name,shop_name,group_id,date1,date2])
  end

  def font_color(number)
    number < 0 ?  ("<span style='color:#f00;font-weight:bold;'>"+ (number).to_s + "</span>") : ("<span style='color:blue;font-weight:bold;'>" + (number).to_s  + "</span>")
  end

  def sum_of_values_for_all_group(money_type,cluster_name,date1,date2)
    Counterdata.sum("#{money_type}",:conditions => ["ClusterName=? and Date>=? and Date<=? ",cluster_name,date1,date2]).to_i
  end

  def sum_of_os_for_cluster(cluster_name,date)
    Countercollection.sum(:os,:conditions => ["ClusterName=? and Date=? ",cluster_name,date])
  end

  def custom_hc_value(cluster_name)
    DailyReportCustom.find_by_cluster_name(cluster_name).hc.to_s if DailyReportCustom.find_by_cluster_name(cluster_name)
  end

  def custom_exp_value(cluster_name)
    DailyReportCustom.find_by_cluster_name(cluster_name).exp.to_s if DailyReportCustom.find_by_cluster_name(cluster_name)
  end

  def tot_percentage_color(number)
    if number.to_i <=59
      return ("<span style='color:red;font-weight:bold;'>" +number.to_s + '%' +"</span>")
    elsif number.to_i >59 and number.to_i <=69
      return ("<span style='color:blue;font-weight:bold;'>" + number.to_s + '%'+ "</span>")
    elsif number.to_i >69 and number.to_i <=80
      ("<span style='color:green;font-weight:bold;'>"+ number.to_s + '%' +"</span>")
    elsif number.to_i >=81
      return ("<span style='color:red;font-weight:bold;'>"+ number.to_s + '%' + "</font>")
    end
  end

  def sign_convey(number)
    if number.to_i>0
      return '-'+number.to_s
    else
      return number.to_s.sub('-','')
    end
  end


  def machine_no_and_machine_name_color(shop_name,machine_no,machine_name)
    machine = Machine.find_by_ShopName_and_MachineNo_and_MachineName(shop_name,machine_no,machine_name)
    if machine
      if machine.Multiplyby == 2
        return "#FF8000"
      else
        ""
      end
    end
  end

  def machine_count(shop_name,machine_name,date)
    Machinedata.count(:conditions=>["Shop_Name=? and Machine_Name=? and Trans_Date=?",shop_name,machine_name,date])
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


  def percentage_calcutation(cluster_name,shop_name,group_name,start_date,end_date)
    machine_datas = Machinedata.find(:all,
      :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and GROUP_ID=? and TRANS_DATE>=? and TRANS_DATE<=?",cluster_name,shop_name,group_name,start_date,end_date])
    tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
    machine_datas.each do |machine_date|
      if machine_date.CALCULATEBY!='M'
        tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      else
        tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      end
      if machine_date.MTRSHORT.to_i < 0
        mtrneg=mtrneg+machine_date.MTRSHORT.to_i
      else
        mtrpos=mtrpos+machine_date.MTRSHORT.to_i
      end
    end
    per = tsrin.to_i!=0?  (((tsrout.to_f-mtrneg.to_f).to_f*100)/(tsrin.to_f+mtrpos.to_f)).round : 0
    return per
  end

  def percentage_calcutation_without_key(cluster_name,shop_name,start_date,end_date)
    machine_datas = Machinedata.find(:all,
      :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and TRANS_DATE>=? and TRANS_DATE<=?",cluster_name,shop_name,start_date,end_date])
    tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
    machine_datas.each do |machine_date|
      if machine_date.CALCULATEBY!='M'
        tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      else
        tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      end
      if machine_date.MTRSHORT.to_i < 0
        mtrneg=mtrneg+machine_date.MTRSHORT.to_i
      else
        mtrpos=mtrpos+machine_date.MTRSHORT.to_i
      end
    end
    per = tsrin.to_i!=0?  (((tsrout.to_f-mtrneg.to_f).to_f*100)/(tsrin.to_f+mtrpos.to_f)).round : 0
    return per
  end

  def percentage_calcutation_with_mc_name(cluster_name,shop_name,group_name,mc_name,start_date,end_date,date_diff)
    machine_datas = Machinedata.find(:all,
      :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and GROUP_ID=? and TRANS_DATE>=? and TRANS_DATE<=? and MACHINE_NAME=?",
        cluster_name,shop_name,group_name,start_date,end_date,mc_name])
    tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
    machine_datas.each do |machine_date|
      if machine_date.CALCULATEBY!='M'
        tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      else
        tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      end
      if machine_date.MTRSHORT.to_i < 0
        mtrneg=mtrneg+machine_date.MTRSHORT.to_i
      else
        mtrpos=mtrpos+machine_date.MTRSHORT.to_i
      end
    end

    machinecount = Machinedata.count(:conditions=>["CLUSTER_NAME in (?) and SHOP_NAME=? and GROUP_ID=? and TRANS_DATE=?  and MACHINE_NAME=?",
        cluster_name,shop_name,group_name,end_date,mc_name])

   avg = machinecount!=0 ? (((((tsrin.to_f+mtrpos.to_f)-(tsrout.to_f-(mtrneg.to_f)))/machinecount)/date_diff.to_i)).round : 0

    per = tsrin.to_i!=0?  (((tsrout.to_f-mtrneg.to_f).to_f*100)/(tsrin.to_f+mtrpos.to_f)).round : 0
    return per,avg
  end

  def percentage_calcutation_with_mc_name_without_key(cluster_name,shop_name,mc_name,start_date,end_date,date_diff)
    machine_datas = Machinedata.find(:all,
      :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and TRANS_DATE>=? and TRANS_DATE<=? and MACHINE_NAME=?",cluster_name,shop_name,start_date,end_date,mc_name])
    tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
    machine_datas.each do |machine_date|
      if machine_date.CALCULATEBY!='M'
        tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      else
        tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
        tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
      end
      if machine_date.MTRSHORT.to_i < 0
        mtrneg=mtrneg+machine_date.MTRSHORT.to_i
      else
        mtrpos=mtrpos+machine_date.MTRSHORT.to_i
      end
    end

    machinecount = Machinedata.count(:conditions=>["CLUSTER_NAME in (?) and SHOP_NAME=? and TRANS_DATE=?  and MACHINE_NAME=?",
        cluster_name,shop_name,end_date,mc_name])

   avg = machinecount!=0 ? (((((tsrin.to_f+mtrpos.to_f)-(tsrout.to_f-(mtrneg.to_f)))/machinecount)/date_diff.to_i)).round : 0

    per = tsrin.to_i!=0?  (((tsrout.to_f-mtrneg.to_f).to_f*100)/(tsrin.to_f+mtrpos.to_f)).round : 0
    return per,avg
  end

  def percentage_calcutation_by_type(cluster_name,shop_name,group_name,start_date,end_date,machine_type,date_diff)
    tot_tsrin,tot_tsrout,tot_mtrpos,tot_mtrneg =0,0,0,0,0
    machine_type.machines.find_all_by_ClusterName_and_ShopName_and_GroupID(cluster_name,shop_name,group_name).collect(&:MachineNo).each do |mac_no|
      machine_dates = Machinedata.find(:all,
        :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and GROUP_ID=? and TRANS_DATE>=? and TRANS_DATE<=?  and MACHINE_NO=?",
          cluster_name,shop_name,group_name,start_date,end_date,mac_no])
      tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
      machine_dates.each do |machine_date|
        if machine_date.CALCULATEBY!='M'
          tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
          tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
        else
          tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
          tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
        end
        if machine_date.MTRSHORT.to_i < 0
          mtrneg=mtrneg+machine_date.MTRSHORT.to_i
        else
          mtrpos=mtrpos+machine_date.MTRSHORT.to_i
        end
      end
    tot_tsrout +=tsrout.to_f
    tot_tsrin +=tsrin.to_f
    tot_mtrpos +=mtrpos.to_f
    tot_mtrneg +=mtrneg.to_f
    end

    machinecount = machine_type.machines.find_all_by_ClusterName_and_ShopName_and_GroupID(cluster_name,shop_name,group_name).count

    avg = machinecount!=0 ? (((((tot_tsrin.to_f+tot_mtrpos.to_f)-(tot_tsrout.to_f-(tot_mtrneg.to_f)))/machinecount)/date_diff.to_i)).round : 0

    per = tot_tsrin.to_i!=0 ?  (((tot_tsrout.to_f-tot_mtrneg.to_f).to_f*100)/(tot_tsrin.to_f+tot_mtrpos.to_f)).round : 0
    return per,avg
  end

  def percentage_calcutation_by_type_without_key(cluster_name,shop_name,start_date,end_date,machine_type,date_diff)
    tot_tsrin,tot_tsrout,tot_mtrpos,tot_mtrneg =0,0,0,0,0
    machine_type.machines.find_all_by_ClusterName_and_ShopName(cluster_name,shop_name).collect(&:MachineNo).each do |mac_no|
      machine_dates = Machinedata.find(:all,
        :conditions=>["CLUSTER_NAME=? and SHOP_NAME =? and TRANS_DATE>=? and TRANS_DATE<=?  and MACHINE_NO=?",
          cluster_name,shop_name,start_date,end_date,mac_no])
      tsrin,tsrinvalue,tsrout,mtrpos,mtrneg =0,0,0,0,0
      machine_dates.each do |machine_date|
        if machine_date.CALCULATEBY!='M'
          tsrin= tsrin + ((machine_date.TSRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
          tsrout=tsrout+ ((machine_date.TSROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
        else
          tsrin= tsrin+ ((machine_date.TMTRIN.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_IN.to_i)/10).round
          tsrout=tsrout+ ((machine_date.TMTROUT.to_i*machine_date.MULTIPLY_BY.to_i*machine_date.SCREEN_RATE_OUT.to_i)/10).round
        end
        if machine_date.MTRSHORT.to_i < 0
          mtrneg=mtrneg+machine_date.MTRSHORT.to_i
        else
          mtrpos=mtrpos+machine_date.MTRSHORT.to_i
        end
      end
    tot_tsrout +=tsrout.to_f
    tot_tsrin +=tsrin.to_f
    tot_mtrpos +=mtrpos.to_f
    tot_mtrneg +=mtrneg.to_f
    end
    machinecount = machine_type.machines.find_all_by_ClusterName_and_ShopName(cluster_name,shop_name).count

    avg = machinecount!=0 ? (((((tot_tsrin.to_f+tot_mtrpos.to_f)-(tot_tsrout.to_f-(tot_mtrneg.to_f)))/machinecount)/date_diff.to_i)).round : 0

    per = tot_tsrin.to_i!=0 ?  (((tot_tsrout.to_f-tot_mtrneg.to_f).to_f*100)/(tot_tsrin.to_f+tot_mtrpos.to_f)).round : 0
    return per,avg
  end

  def all_or_single_cluster_name(selected_cluster)
    selected_cluster.eql?('ALL')?  Cluster.find(:all).collect(&:ClusterName).sort  : selected_cluster
  end


  def reading_mistake(cluster_name,date)
      Machinedata.find(:all,:select => "distinct (SHOP_NAME)",:conditions=>"CLUSTER_NAME='#{cluster_name}' and TRANS_DATE='#{date}'",:order => "SHOP_NAME")
  end

def editable_title
edit_title =EditableTitle.find(:all) 
 edit_title.empty? ? "SIX MONTH PER DAY'S HC VALUES" : edit_title.collect(&:content).first
end 

end
