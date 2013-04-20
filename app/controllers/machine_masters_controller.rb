class MachineMastersController < ApplicationController
    layout 'adminlayout'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @machine_master_pages, @machine_masters = paginate :machine_masters, :per_page => 10
  end

  def show
    @machine_master = MachineMaster.find(params[:id])
  end

  def new
    @machine_master = MachineMaster.new
  end

  def create
    @machine_master = MachineMaster.new(params[:machine_master])
    if @machine_master.save
      flash[:notice] = 'MachineMaster was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @machine_master = MachineMaster.find(params[:id])
  end

  def update
    @machine_master = MachineMaster.find(params[:id])
    if @machine_master.update_attributes(params[:machine_master])
      flash[:notice] = 'MachineType was successfully updated.'
      redirect_to :action => 'show', :id => @machine_master
    else
      render :action => 'edit'
    end
  end

  def destroy
    MachineMaster.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
