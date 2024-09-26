require "test_helper"

class BallotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ballots_index_url
    assert_response :success
  end

  test "should get show" do
    get ballots_show_url
    assert_response :success
  end

  test "should get new" do
    get ballots_new_url
    assert_response :success
  end

  test "should get create" do
    get ballots_create_url
    assert_response :success
  end

  test "should get edit" do
    get ballots_edit_url
    assert_response :success
  end

  test "should get update" do
    get ballots_update_url
    assert_response :success
  end

  test "should get destroy" do
    get ballots_destroy_url
    assert_response :success
  end
end
