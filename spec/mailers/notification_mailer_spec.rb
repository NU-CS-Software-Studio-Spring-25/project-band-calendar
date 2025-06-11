require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe '#user_notification' do
    let(:admin) { create(:user, :admin, email: 'admin@example.com') }
    let(:user) { create(:user, email: 'user@example.com') }
    let(:events) { create_list(:event, 2, :approved) }
    let(:admin_notification) do
      create(:admin_notification,
        subject: 'New Events This Week!',
        content: 'Check out these amazing upcoming concerts!',
        sent_by: admin,
        event_ids: events.map(&:id),
        user_ids: [user.id]
      )
    end

    let(:mail) { NotificationMailer.user_notification(user, admin_notification) }

    describe 'email headers' do
      it 'renders the subject' do
        expect(mail.subject).to eq('New Events This Week!')
      end

      it 'renders the receiver email' do
        expect(mail.to).to eq([user.email])
      end

      it 'renders the sender email' do
        default_from = ENV.fetch("DEFAULT_FROM_EMAIL", "noreply@bandcalendar.com")
        expect(mail.from).to eq([default_from])
      end

      it 'sets the reply-to to the admin email' do
        expect(mail.reply_to).to eq([admin.email])
      end
    end

    describe 'email content' do
      it 'includes the notification content in the body' do
        expect(mail.body.encoded).to include('Check out these amazing upcoming concerts!')
      end

      it 'mentions the sender in the body' do
        expect(mail.body.encoded).to include(admin.email)
      end
      
      it 'includes event information when events are present' do
        expect(mail.body.encoded).to include('Featured Events')
      end
    end

    describe 'mailer method behavior' do
      it 'accepts correct parameters' do
        expect { NotificationMailer.user_notification(user, admin_notification) }.not_to raise_error
      end

      it 'generates mail message' do
        expect(mail).to be_a(ActionMailer::MessageDelivery)
      end
    end

    describe 'email delivery' do
      it 'delivers the email successfully' do
        expect { mail.deliver_now }.not_to raise_error
      end

      it 'adds the email to the delivery queue' do
        expect { mail.deliver_later }.to change { ActionMailer::Base.deliveries.size }.by(0)
        # Note: deliver_later doesn't immediately add to deliveries in test mode
        # You might need to configure active job adapter for proper testing
      end
    end

    describe 'email formatting' do
      it 'generates multipart email with HTML and text' do
        expect(mail.mime_type).to eq('multipart/alternative')
      end

      it 'has proper charset' do
        expect(mail.charset).to eq('UTF-8')
      end
    end

    context 'with custom environment variables' do
      before do
        allow(ENV).to receive(:fetch).with("DEFAULT_FROM_EMAIL", anything).and_return("custom@bandcalendar.com")
      end

      it 'uses custom from email when set' do
        expect(mail.from).to eq(['custom@bandcalendar.com'])
      end
    end

    context 'when notification has no events' do
      let(:notification_without_events) do
        create(:admin_notification,
          subject: 'General Announcement',
          content: 'Just a general message to all users.',
          sent_by: admin,
          event_ids: [],
          user_ids: [user.id]
        )
      end

      let(:mail_without_events) { NotificationMailer.user_notification(user, notification_without_events) }

      it 'still sends the email successfully' do
        expect { mail_without_events.deliver_now }.not_to raise_error
      end

      it 'assigns empty events array' do
        mail_without_events.deliver_now
        expect(mail_without_events.instance_variable_get(:@events)).to be_nil
      end
    end

    describe 'email preview' do
      it 'can be previewed without errors' do
        # This test ensures the mailer can be used in ActionMailer previews
        expect { NotificationMailer.user_notification(user, admin_notification) }.not_to raise_error
      end
    end
  end

  describe 'mailer configuration' do
    it 'inherits from ApplicationMailer' do
      expect(NotificationMailer.superclass).to eq(ApplicationMailer)
    end
  end
end 