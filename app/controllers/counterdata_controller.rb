class CounterdataController < ApplicationController
  layout 'adminlayout'
  before_filter :login_required
  #UPDATING COUNTER COLLECTION IF WANT TO BEFORE UPLOADING THE DATA TO THE SERVER
  def update
    begin
      @counterdata = Counterdata.find(params[:id])
      if @counterdata.update_attributes(params[:counterdata])
        flash[:notice] = "Counterdata was successfully updated for shop #{@session['shop']}."
        @session['date']=nil
        @session['shop']=nil
        @session['cash']=nil
        @session['credit']=nil
        @session['obal']=nil
        redirect_to :controller=>'counterdata',:action => 'counterdata'
      else
        render :action => 'showcounterdata'
      end
    rescue Exception=>ex
    end
  end

  def getShop
    begin
      if(params[:ClusterName]!="" or params[:ClusterName]!=nil)
        @session[:tclustername]=params[:ClusterName]
      end
      render :update do |page|
        page.replace_html 'Shopdiv', :partial => 'shop'
        page << "document.getElementById('counterdata_ShopName').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end

  def setShop
    begin
      if(params[:ShopName]!="" or params[:ShopName]!=nil)
        @session[:tshopname]=params[:ShopName]
      end
      render :update do |page|
        page << "document.getElementById('save').focus();"
      end
    rescue Exception=>exc
      puts exc.message
    end
  end


  def showdailydata
    @session[:tdate]=params[:date]
    @counterdata = Counterdata.find_first(["ClusterName=? and ShopName=? and Date=?",@session[:tclustername],@session[:tshopname],@session[:tdate]])
    if(@counterdata==nil)
      flash[:notice] ='<font color=red size=3><b>No Record found.</b></font>'
      render :action=>'counterdata'
    else
      redirect_to  :action=>'showcounterdata'
    end
  end
  def showcounterdata
    begin
      @counterdata = Counterdata.find_first(["ClusterName=? and ShopName=? and Date=?",@session[:tclustername],@session[:tshopname],@session[:tdate]])
      @session['total1']=@counterdata.Cash.to_i+@counterdata.Exp.to_i+@counterdata.HC.to_i+@counterdata.Credit.to_i+@counterdata.Short_Ext.to_i
      @session['total2']=@counterdata.Openingbal.to_i+@counterdata.KEY1.to_i+@counterdata.KEY2.to_i+@counterdata.KEY3.to_i+@counterdata.KEY4+@counterdata.Outstanding.to_i
    rescue Exception=>ex
      puts ex.message
    end
  end

  def cancelcounterdata
    render :update do |page|
      page.redirect_to url_for(:controller=>'counterdata', :action=>'counterdata')
    end
  end
end
