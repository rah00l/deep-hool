class CountercollectionsController < ApplicationController
  layout 'adminlayout'
  before_filter :login_required
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list
    @countercollection_pages, @countercollections = paginate :countercollections, :per_page => 10
  end

  def show
    @countercollection = Countercollection.find(params[:id])
  end

  def new
    @countercollection = Countercollection.new
  end

  #CREATING NEW ENTRY IN COUNTERCOLLECTION WHEN ALL ENTRIES IN PARTICULAR SHOP GETS COMPLETED

  #CREATING NEW ENTRY IN COUNTERCOLLECTION WHEN ALL ENTRIES IN PARTICULAR SHOP GETS COMPLETED
  def create
    begin
      @cluster=Shop.find_first(["ShopName=?",params[:countercollection][:ShopName]])
      params[:countercollection][:ClusterName]=@cluster.ClusterName
      @countercollection = Countercollection.new(params[:countercollection])
      outstand_entry = params[:countercollection][:Outstanding]
      outstand_prev_entry = Countercollection.find_by_ShopName(params[:countercollection][:ShopName],:order => 'Date desc')
      first_os = Shop.find_by_ShopName(params[:countercollection][:ShopName]).os
      if outstand_entry.to_i < 0
        os  = outstand_prev_entry.blank? ? first_os.to_i - (outstand_entry.to_i).abs : outstand_prev_entry.os.to_i - (outstand_entry.to_i).abs
      else
        os  = outstand_prev_entry.blank? ? first_os.to_i + (outstand_entry.to_i).abs : outstand_prev_entry.os.to_i + (outstand_entry.to_i).abs
      end
      @countercollection.os = os.to_i.abs
      if @countercollection.save
        flash[:notice] = "Countercollection was successfully created for shop #{@session['shop']}."
        @session['cash']=nil
        @session['credit']=nil
        @session['obal']=nil
        redirect_to :controller=>'clientdatas', :action => 'new'
      else
        render :action => 'new'
      end
    rescue Exception=>ex
      puts ex.message()
    end
  end

  def create1111
    begin
      @cluster=Shop.find_first(["ShopName=?",params[:countercollection][:ShopName]])
      params[:countercollection][:ClusterName]=@cluster.ClusterName
      @countercollection = Countercollection.new(params[:countercollection])
      if @countercollection.save
        flash[:notice] = "Countercollection was successfully created for shop #{@session['shop']}."
        @session['cash']=nil
        @session['credit']=nil
        @session['obal']=nil
        redirect_to :controller=>'clientdatas', :action => 'new'
      else
        render :action => 'new'
      end
    rescue Exception=>ex
      puts ex.message()
    end
  end

  def edit
    @countercollection = Countercollection.find(params[:id])
  end

  #UPDATING COUNTER COLLECTION IF WANT TO BEFORE UPLOADING THE DATA TO THE SERVER
  def update
    begin
      @countercollection = Countercollection.find(params[:id])
      if @countercollection.update_attributes(params[:countercollection])
        flash[:notice] = "Countercollection was successfully updated for shop #{@session['shop']}."
        @session['date']=nil
        @session['shop']=nil
        @session['cash']=nil
        @session['credit']=nil
        @session['obal']=nil
        redirect_to :controller=>'clientdatas',:action => 'new'
      else
        render :action => 'edit'
      end
    rescue Exception=>ex
  
    end
  end

  def destroy
    Countercollection.find_first(["id=?",@session['id']]).destroy
    flash[:notice] = "Countercollection was successfully deleted for shop #{@session['shop']}."
    render :update do |page|
      page.redirect_to url_for(:controller=>'clientdatas', :action=>'new')
    end 
  end
end
