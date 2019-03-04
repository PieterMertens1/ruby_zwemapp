require 'test_helper'

class KlasControllerTest < ActionController::TestCase
  setup do
    @kla = klas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:klas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kla" do
    assert_difference('Kla.count') do
      post :create, kla: @kla.attributes
    end

    assert_redirected_to kla_path(assigns(:kla))
  end

  test "should show kla" do
    get :show, id: @kla
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kla
    assert_response :success
  end

  test "should update kla" do
    put :update, id: @kla, kla: @kla.attributes
    assert_redirected_to kla_path(assigns(:kla))
  end

  test "should destroy kla" do
    assert_difference('Kla.count', -1) do
      delete :destroy, id: @kla
    end

    assert_redirected_to klas_path
  end
end
