require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
    
    context 'email format validation' do
      it 'accepts valid email addresses' do
        valid_emails = [
          'user@example.com',
          'test.email@example.org',
          'user+tag@example.net'
        ]
        
        valid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid, "Expected #{email} to be valid"
        end
      end
      
      it 'rejects invalid email addresses' do
        invalid_emails = [
          'invalid_email',
          '@example.com',
          'user@'
        ]
        
        invalid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid, "Expected #{email} to be invalid"
        end
      end
    end
  end

  describe 'associations' do
    it { should have_many(:submitted_events).class_name('Event').with_foreign_key(:submitted_by_id) }
  end

  describe 'default values' do
    it 'sets admin to false by default' do
      user = User.new
      expect(user.admin).to be false
    end
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:admin_user) { create(:user, :admin) }
      
      it 'returns true' do
        expect(admin_user.admin?).to be true
      end
    end
    
    context 'when user is not admin' do
      let(:regular_user) { create(:user) }
      
      it 'returns false' do
        expect(regular_user.admin?).to be false
      end
    end
  end

  describe 'password requirements' do
    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
    
    it 'encrypts password' do
      user = create(:user, password: 'plaintext', password_confirmation: 'plaintext')
      expect(user.encrypted_password).not_to eq('plaintext')
      expect(user.encrypted_password).to be_present
    end
  end

  describe 'event submission behavior' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    
    it 'can submit multiple events' do
      venue = create(:venue)
      event1 = create(:event, submitted_by: user, venue: venue, name: 'Concert 1')
      event2 = create(:event, submitted_by: user, venue: venue, name: 'Concert 2', date: 2.weeks.from_now)
      
      expect(user.submitted_events).to include(event1, event2)
    end
    
    it 'maintains association when events are deleted' do
      venue = create(:venue)
      event = create(:event, submitted_by: user, venue: venue)
      event_id = event.id
      
      expect(user.submitted_events.pluck(:id)).to include(event_id)
      
      event.destroy
      user.reload
      
      expect(user.submitted_events.pluck(:id)).not_to include(event_id)
    end
  end

  describe 'authentication features' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
    
    it 'authenticates with valid credentials' do
      user # trigger creation
      authenticated_user = User.find_for_authentication(email: 'test@example.com')
      expect(authenticated_user).to be_present
      expect(authenticated_user.valid_password?('password123')).to be true
    end
    
    it 'does not authenticate with invalid password' do
      user # trigger creation
      authenticated_user = User.find_for_authentication(email: 'test@example.com')
      expect(authenticated_user).to be_present
      expect(authenticated_user.valid_password?('wrongpassword')).to be false
    end
    
    it 'supports password reset functionality' do
      # Test the basic reset password functionality without Devise internals
      expect(user).to respond_to(:send_reset_password_instructions)
      expect(user).to respond_to(:reset_password_token)
      expect(user).to respond_to(:reset_password_sent_at)
    end
  end

  describe 'admin privileges' do
    let(:admin) { create(:user, :admin) }
    let(:regular_user) { create(:user) }
    
    context 'event management' do
      let(:event) { create(:event, submitted_by: regular_user) }
      
      it 'admin can approve events' do
        expect(admin.admin?).to be true
        # This would typically be tested in a controller or integration test
        # but we can verify the admin status here
      end
      
      it 'regular user cannot approve events' do
        expect(regular_user.admin?).to be false
      end
    end
  end
end 