class DailyReportCustomsController < ApplicationController
    layout 'adminlayout'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @daily_report_custom_pages, @daily_report_customs = paginate :daily_report_customs, :per_page => 10
  end

  def show
    @daily_report_custom = DailyReportCustom.find(params[:id])
  end

  def new
    @daily_report_custom = DailyReportCustom.new
  end

  def create
    @daily_report_custom = DailyReportCustom.new(params[:daily_report_custom])
    if @daily_report_custom.save
      flash[:notice] = 'DailyReportCustom was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @daily_report_custom = DailyReportCustom.find(params[:id])
  end

  def update
    @daily_report_custom = DailyReportCustom.find(params[:id])
    if @daily_report_custom.update_attributes(params[:daily_report_custom])
      flash[:notice] = 'DailyReportCustom was successfully updated.'
            redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    DailyReportCustom.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
