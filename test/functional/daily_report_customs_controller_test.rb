require File.dirname(__FILE__) + '/../test_helper'
require 'daily_report_customs_controller'

# Re-raise errors caught by the controller.
class DailyReportCustomsController; def rescue_action(e) raise e end; end

class DailyReportCustomsControllerTest < Test::Unit::TestCase
  fixtures :daily_report_customs

  def setup
    @controller = DailyReportCustomsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = daily_report_customs(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:daily_report_customs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:daily_report_custom)
    assert assigns(:daily_report_custom).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:daily_report_custom)
  end

  def test_create
    num_daily_report_customs = DailyReportCustom.count

    post :create, :daily_report_custom => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_daily_report_customs + 1, DailyReportCustom.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:daily_report_custom)
    assert assigns(:daily_report_custom).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      DailyReportCustom.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      DailyReportCustom.find(@first_id)
    }
  end
end
