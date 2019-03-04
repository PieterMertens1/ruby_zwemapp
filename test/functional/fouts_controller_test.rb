require 'test_helper'

class FoutsControllerTest < ActionController::TestCase
  setup do
    @fout = fouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fout" do
    assert_difference('Fout.count') do
      post :create, fout: @fout.attributes
    end

    assert_redirected_to fout_path(assigns(:fout))
  end

  test "should show fout" do
    get :show, id: @fout
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fout
    assert_response :success
  end

  test "should update fout" do
    put :update, id: @fout, fout: @fout.attributes
    assert_redirected_to fout_path(assigns(:fout))
  end

  test "should destroy fout" do
    assert_difference('Fout.count', -1) do
      delete :destroy, id: @fout
    end

    assert_redirected_to fouts_path
  end
end
