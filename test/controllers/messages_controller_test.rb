require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get send_message" do
    get :send_message
    assert_response :success
  end

end
