class ClustersController < ApplicationController
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
    @cluster_pages, @clusters = paginate :clusters, :per_page => 10
  end

  def show
    @cluster = Cluster.find(params[:id])
  end

  def new
    @cluster = Cluster.new
  end

  def create
      begin
    @cluster = Cluster.new(params[:cluster])
    
  if @cluster.save
       flash[:notice] = '<font color=green size=4><b>GROUP WAS SUCCESSFULLY CREATED.</b></font>'
      redirect_to :action => 'list'
    else
      render :action => 'new'
  end

    rescue Exception=>ex
    puts ex.message()
    end
  end

  def edit
    @cluster = Cluster.find(params[:id])
  end

  def update
    @cluster = Cluster.find(params[:id])
    if @cluster.update_attributes(params[:cluster])
      flash[:notice] = '<font color=green size=4><b>GROUP WAS SUCCESSFULLY UPDATED.</b></font>'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Cluster.find(params[:id]).destroy
    redirect_to :action => 'list'
end
def canceladd
    render :update do |page|
    page.redirect_to url_for(:controller=>'clusters', :action=>'list')
    end
    end
end
