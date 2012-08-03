class MachineTypesController < ApplicationController
    layout 'adminlayout'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @machine_type_pages, @machine_types = paginate :machine_types, :per_page => 10
  end

  def show
    @machine_type = MachineType.find(params[:id])
  end

  def new
    @machine_type = MachineType.new
  end

  def create
    @machine_type = MachineType.new(params[:machine_type])
    if @machine_type.save
      flash[:notice] = 'MachineType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @machine_type = MachineType.find(params[:id])
  end

  def update
    @machine_type = MachineType.find(params[:id])
    if @machine_type.update_attributes(params[:machine_type])
      flash[:notice] = 'MachineType was successfully updated.'
      redirect_to :action => 'show', :id => @machine_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    MachineType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
