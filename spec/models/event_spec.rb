require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:venue) }
    it { should belong_to(:submitted_by).class_name('User').optional }
    it { should have_many(:band_events).dependent(:destroy) }
    it { should have_many(:bands).through(:band_events) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date) }
    
    context 'uniqueness validation' do
      let(:venue) { create(:venue) }
      let(:date) { 1.week.from_now }
      
      before do
        create(:event, name: 'Test Concert', date: date, venue: venue)
      end
      
      it 'should not allow duplicate event names on the same date' do
        duplicate_event = build(:event, name: 'Test Concert', date: date, venue: venue)
        expect(duplicate_event).not_to be_valid
        expect(duplicate_event.errors[:name]).to include('already exists for this date')
      end
      
      it 'should allow same event name on different dates' do
        different_date_event = build(:event, name: 'Test Concert', date: date + 1.day, venue: venue)
        expect(different_date_event).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:approved_event) { create(:event, :approved) }
    let!(:pending_event) { create(:event, approved: false) }
    
    describe '.approved' do
      it 'returns only approved events' do
        expect(Event.approved).to include(approved_event)
        expect(Event.approved).not_to include(pending_event)
      end
    end
    
    describe '.pending' do
      it 'returns only pending events' do
        expect(Event.pending).to include(pending_event)
        expect(Event.pending).not_to include(approved_event)
      end
    end
  end

  describe 'instance methods' do
    describe '#pending?' do
      it 'returns true for unapproved events' do
        event = build(:event, approved: false)
        expect(event.pending?).to be true
      end
      
      it 'returns false for approved events' do
        event = build(:event, :approved)
        expect(event.pending?).to be false
      end
    end
  end

  describe 'class methods' do
    describe '.near_location' do
      let(:venue_in_range) { create(:venue, city: 'New York') }
      let(:venue_out_of_range) { create(:venue, city: 'Los Angeles') }
      let!(:event_in_range) { create(:event, venue: venue_in_range) }
      let!(:event_out_of_range) { create(:event, venue: venue_out_of_range) }
      
      it 'has a near_location class method' do
        # Skip this test if geocoding columns don't exist yet
        skip 'Geocoding columns not yet added to venues table' unless Venue.column_names.include?('latitude')
        
        # Test would work when geocoding is properly set up
        expect(Event).to respond_to(:near_location)
      end
    end
  end

  describe 'delegation' do
    let(:venue) { create(:venue) }
    let(:event) { create(:event, venue: venue) }
    
    it 'attempts to delegate latitude to venue when columns exist' do
      # Skip this test if geocoding columns don't exist yet
      skip 'Geocoding columns not yet added to venues table' unless Venue.column_names.include?('latitude')
      
      expect(event.latitude).to eq(venue.latitude)
    end
    
    it 'attempts to delegate longitude to venue when columns exist' do
      # Skip this test if geocoding columns don't exist yet  
      skip 'Geocoding columns not yet added to venues table' unless Venue.column_names.include?('longitude')
      
      expect(event.longitude).to eq(venue.longitude)
    end
  end
end 