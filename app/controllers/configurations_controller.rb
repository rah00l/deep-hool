class ConfigurationsController < ApplicationController
  layout 'adminlayout'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @configuration_pages, @configurations = paginate :configurations, :per_page => 10
  end

  def show
    @configuration = Configuration.find(params[:id])
  end

  def new
    @configuration = Configuration.new
  end

  def create
    @configuration = Configuration.new(params[:configuration])
    if @configuration.save
      flash[:notice] = 'Configuration was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @configuration = Configuration.find(params[:id])
  end

  def update
    @configuration = Configuration.find(params[:id])
    if @configuration.update_attributes(params[:configuration])
      flash[:notice] = 'Configuration was successfully updated.'
      redirect_to :action => 'show', :id => @configuration
    else
      render :action => 'edit'
    end
  end

  def destroy
    Configuration.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
