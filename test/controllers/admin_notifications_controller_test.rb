require "test_helper"

class AdminNotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_notifications_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_notifications_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_notifications_create_url
    assert_response :success
  end

  test "should get show" do
    get admin_notifications_show_url
    assert_response :success
  end
end
