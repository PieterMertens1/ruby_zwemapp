require 'test_helper'

class DagsControllerTest < ActionController::TestCase
  setup do
    @dag = dags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dag" do
    assert_difference('Dag.count') do
      post :create, dag: @dag.attributes
    end

    assert_redirected_to dag_path(assigns(:dag))
  end

  test "should show dag" do
    get :show, id: @dag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dag
    assert_response :success
  end

  test "should update dag" do
    put :update, id: @dag, dag: @dag.attributes
    assert_redirected_to dag_path(assigns(:dag))
  end

  test "should destroy dag" do
    assert_difference('Dag.count', -1) do
      delete :destroy, id: @dag
    end

    assert_redirected_to dags_path
  end
end
