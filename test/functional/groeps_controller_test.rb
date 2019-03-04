require 'test_helper'

class GroepsControllerTest < ActionController::TestCase
  setup do
    @groep = groeps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groeps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create groep" do
    assert_difference('Groep.count') do
      post :create, groep: @groep.attributes
    end

    assert_redirected_to groep_path(assigns(:groep))
  end

  test "should show groep" do
    get :show, id: @groep
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @groep
    assert_response :success
  end

  test "should update groep" do
    put :update, id: @groep, groep: @groep.attributes
    assert_redirected_to groep_path(assigns(:groep))
  end

  test "should destroy groep" do
    assert_difference('Groep.count', -1) do
      delete :destroy, id: @groep
    end

    assert_redirected_to groeps_path
  end
end
