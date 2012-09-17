require File.dirname(__FILE__) + '/../test_helper'
require 'configurations_controller'

# Re-raise errors caught by the controller.
class ConfigurationsController; def rescue_action(e) raise e end; end

class ConfigurationsControllerTest < Test::Unit::TestCase
  fixtures :configurations

  def setup
    @controller = ConfigurationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = configurations(:first).id
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

    assert_not_nil assigns(:configurations)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:configuration)
    assert assigns(:configuration).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:configuration)
  end

  def test_create
    num_configurations = Configuration.count

    post :create, :configuration => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_configurations + 1, Configuration.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:configuration)
    assert assigns(:configuration).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Configuration.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Configuration.find(@first_id)
    }
  end
end
