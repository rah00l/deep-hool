class EditableTitlesController < ApplicationController
layout 'adminlayout'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @editable_title_pages, @editable_titles = paginate :editable_titles, :per_page => 10
  end

  def show
    @editable_title = EditableTitle.find(params[:id])
  end

  def new
    @editable_title = EditableTitle.new
  end

  def create
    @editable_title = EditableTitle.new(params[:editable_title])
    if @editable_title.save
      flash[:notice] = 'EditableTitle was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @editable_title = EditableTitle.find(params[:id])
  end

  def update
    @editable_title = EditableTitle.find(params[:id])
    if @editable_title.update_attributes(params[:editable_title])
      flash[:notice] = 'EditableTitle was successfully updated.'
      redirect_to :action => 'show', :id => @editable_title
    else
      render :action => 'edit'
    end
  end

  def destroy
    EditableTitle.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
