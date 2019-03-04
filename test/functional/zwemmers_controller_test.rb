require 'test_helper'

class ZwemmersControllerTest < ActionController::TestCase
  setup do
    @zwemmer = zwemmers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:zwemmers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create zwemmer" do
    assert_difference('Zwemmer.count') do
      post :create, zwemmer: @zwemmer.attributes
    end

    assert_redirected_to zwemmer_path(assigns(:zwemmer))
  end

  test "should show zwemmer" do
    get :show, id: @zwemmer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @zwemmer
    assert_response :success
  end

  test "should update zwemmer" do
    put :update, id: @zwemmer, zwemmer: @zwemmer.attributes
    assert_redirected_to zwemmer_path(assigns(:zwemmer))
  end

  test "should destroy zwemmer" do
    assert_difference('Zwemmer.count', -1) do
      delete :destroy, id: @zwemmer
    end

    assert_redirected_to zwemmers_path
  end
end
