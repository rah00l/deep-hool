# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def previous_month_avg_hc(cluster_name,shop_name,date)
    date = date.to_s
    first_date,last_date = get_last_months_last_date(date)
    avg = Counterdata.average(:HC,:conditions=>["clustername=? and shopname=? and date>=? and date<=?",cluster_name,shop_name,first_date,last_date]).round
  end

  def target_percentage(pre_month_avg_hc,target)
    #raise target.to_i.inspect
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
      return ("<span style='color:blue;font-weight:bold;'>" + pre.to_s +  result.to_s + post.to_s  + "</span>")
    end
  end

  def get_last_months_last_date(date)
    last_date = (Date.parse(Date.parse(date.to_s).strftime('%Y-%m-01'))-1).to_s
    first_date = Date.parse(last_date).strftime('%Y-%m-01')
    return first_date,last_date
  end
  
  def get_prevdate_os(shop_name,date)
    #prev_date = (Date.parse(date) - 1).strftime('%Y-%m-%d')
    #abc = Counterdata.find(:first,:conditions=>["shopname=? and date=?",shop_name,prev_date])
    outstand_prev_entry = Countercollection.find_by_ShopName(shop_name,:order => 'Date desc')
    os  = outstand_prev_entry.blank? ? Shop.find_by_ShopName(shop_name).os : Countercollection.find_by_ShopName(shop_name,:order => 'Date desc').os
    #abc.blank? ? Shop.find_by_ShopName(shop_name).os : Counterdata.find(:first,:conditions=>["shopname=? and date=?",shop_name,prev_date]).os
  end

end


