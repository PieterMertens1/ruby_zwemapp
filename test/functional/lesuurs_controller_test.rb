require 'test_helper'

class LesuursControllerTest < ActionController::TestCase
  setup do
    @lesuur = lesuurs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lesuurs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lesuur" do
    assert_difference('Lesuur.count') do
      post :create, lesuur: @lesuur.attributes
    end

    assert_redirected_to lesuur_path(assigns(:lesuur))
  end

  test "should show lesuur" do
    get :show, id: @lesuur
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lesuur
    assert_response :success
  end

  test "should update lesuur" do
    put :update, id: @lesuur, lesuur: @lesuur.attributes
    assert_redirected_to lesuur_path(assigns(:lesuur))
  end

  test "should destroy lesuur" do
    assert_difference('Lesuur.count', -1) do
      delete :destroy, id: @lesuur
    end

    assert_redirected_to lesuurs_path
  end
end
