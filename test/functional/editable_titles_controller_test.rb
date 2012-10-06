require File.dirname(__FILE__) + '/../test_helper'
require 'editable_titles_controller'

# Re-raise errors caught by the controller.
class EditableTitlesController; def rescue_action(e) raise e end; end

class EditableTitlesControllerTest < Test::Unit::TestCase
  fixtures :editable_titles

  def setup
    @controller = EditableTitlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = editable_titles(:first).id
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

    assert_not_nil assigns(:editable_titles)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:editable_title)
    assert assigns(:editable_title).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:editable_title)
  end

  def test_create
    num_editable_titles = EditableTitle.count

    post :create, :editable_title => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_editable_titles + 1, EditableTitle.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:editable_title)
    assert assigns(:editable_title).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      EditableTitle.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      EditableTitle.find(@first_id)
    }
  end
end
