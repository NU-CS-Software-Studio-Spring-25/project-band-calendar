require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "user_notification" do
    mail = NotificationMailer.user_notification
    assert_equal "User notification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
