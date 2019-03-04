require 'test_helper'

class ResultaatsControllerTest < ActionController::TestCase
  setup do
    @resultaat = resultaats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resultaats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resultaat" do
    assert_difference('Resultaat.count') do
      post :create, resultaat: @resultaat.attributes
    end

    assert_redirected_to resultaat_path(assigns(:resultaat))
  end

  test "should show resultaat" do
    get :show, id: @resultaat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resultaat
    assert_response :success
  end

  test "should update resultaat" do
    put :update, id: @resultaat, resultaat: @resultaat.attributes
    assert_redirected_to resultaat_path(assigns(:resultaat))
  end

  test "should destroy resultaat" do
    assert_difference('Resultaat.count', -1) do
      delete :destroy, id: @resultaat
    end

    assert_redirected_to resultaats_path
  end
end
