require 'rails_helper'

RSpec.describe 'Event Workflow Integration', type: :request do
  let(:venue) { create(:venue) }
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:band) { create(:band) }

  describe 'Complete event submission and approval workflow' do
    context 'as a regular user' do
      before do
        sign_in user
      end

      it 'allows user to submit an event that requires approval' do
        # Step 1: User visits the new event page
        get new_event_path
        expect(response).to have_http_status(:success)

        # Step 2: User submits a new event
        event_params = {
          name: 'Amazing Rock Concert',
          date: 1.week.from_now,
          venue_id: venue.id
        }

        expect {
          post events_path, params: { event: event_params }
        }.to change(Event, :count).by(1)

        # Step 3: Verify event is created but not approved
        created_event = Event.last
        expect(created_event.name).to eq('Amazing Rock Concert')
        expect(created_event.submitted_by).to eq(user)
        expect(created_event.approved?).to be false
        expect(created_event.pending?).to be true

        # Step 4: Verify redirect and flash message
        expect(response).to redirect_to(created_event)
        follow_redirect!
        expect(response.body).to include('awaiting approval')

        # Step 5: Verify event appears on pending list for admin but not on public list
        get events_path
        expect(response.body).not_to include('Amazing Rock Concert')

        # Step 6: Admin can see pending events
        sign_out user
        sign_in admin

        get events_path, params: { pending: true }
        expect(response.body).to include('Amazing Rock Concert')

        # Step 7: Admin approves the event
        patch approve_event_path(created_event)
        expect(response).to redirect_to(created_event)

        created_event.reload
        expect(created_event.approved?).to be true

        # Step 8: Event now appears on public events list
        get events_path
        expect(response.body).to include('Amazing Rock Concert')
      end

      it 'allows user to edit their own submitted event' do
        # Create an event submitted by the user
        event = create(:event, submitted_by: user, venue: venue, approved: true)

        # User can access edit page
        get edit_event_path(event)
        expect(response).to have_http_status(:success)

        # User can update the event
        updated_params = { name: 'Updated Concert Name' }
        patch event_path(event), params: { event: updated_params }

        event.reload
        expect(event.name).to eq('Updated Concert Name')
        expect(event.approved?).to be false # Should be unapproved after non-admin edit
        expect(response).to redirect_to(event)
      end

      it 'prevents user from editing events they did not submit' do
        # Create an event submitted by another user
        other_user = create(:user)
        event = create(:event, submitted_by: other_user, venue: venue)

        # User cannot access edit page
        get edit_event_path(event)
        expect(response).to redirect_to(event)
        expect(flash[:alert]).to eq("You don't have permission to edit this event.")
      end

      it 'allows user to delete their own submitted event' do
        event = create(:event, submitted_by: user, venue: venue)

        expect {
          delete event_path(event)
        }.to change(Event, :count).by(-1)

        expect(response).to redirect_to(events_path)
      end
    end

    context 'as an admin user' do
      before do
        sign_in admin
      end

      it 'auto-approves events created by admin' do
        event_params = {
          name: 'Admin Concert',
          date: 1.week.from_now,
          venue_id: venue.id
        }

        post events_path, params: { event: event_params }

        created_event = Event.last
        expect(created_event.approved?).to be true
        expect(response).to redirect_to(created_event)
        follow_redirect!
        expect(response.body).to include('successfully created')
        expect(response.body).not_to include('awaiting approval')
      end

      it 'allows admin to approve and disapprove events' do
        pending_event = create(:event, approved: false, venue: venue)

        # Admin approves event
        patch approve_event_path(pending_event)
        pending_event.reload
        expect(pending_event.approved?).to be true

        # Admin can disapprove event
        patch disapprove_event_path(pending_event)
        pending_event.reload
        expect(pending_event.approved?).to be false
      end

      it 'allows admin to edit any event without affecting approval status' do
        approved_event = create(:event, :approved, venue: venue)

        patch event_path(approved_event), params: { event: { name: 'Admin Updated Name' } }

        approved_event.reload
        expect(approved_event.name).to eq('Admin Updated Name')
        expect(approved_event.approved?).to be true # Should remain approved
      end

      it 'allows admin to view pending events' do
        pending_event = create(:event, approved: false, venue: venue)
        approved_event = create(:event, :approved, venue: venue)

        # Admin can see pending events
        get events_path, params: { pending: true }
        expect(response.body).to include(pending_event.name)
        expect(response.body).not_to include(approved_event.name)

        # Admin can see approved events by default
        get events_path
        expect(response.body).to include(approved_event.name)
        expect(response.body).not_to include(pending_event.name)
      end
    end

    context 'as an unauthenticated user' do
      it 'can view approved events but not submit new ones' do
        approved_event = create(:event, :approved, venue: venue)
        pending_event = create(:event, approved: false, venue: venue)

        # Can view public events list
        get events_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(approved_event.name)
        expect(response.body).not_to include(pending_event.name)

        # Cannot access new event form
        get new_event_path
        expect(response).to redirect_to(new_user_session_path)

        # Cannot submit events
        post events_path, params: { event: { name: 'Test', venue_id: venue.id } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'can view individual approved events' do
        approved_event = create(:event, :approved, venue: venue)

        get event_path(approved_event)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(approved_event.name)
      end
    end

    context 'event with bands integration' do
      before do
        sign_in user
      end

      it 'allows creating events with band associations' do
        band1 = create(:band, name: 'First Band')
        band2 = create(:band, name: 'Second Band')

        event_params = {
          name: 'Multi-Band Concert',
          date: 1.week.from_now,
          venue_id: venue.id,
          band_ids: [band1.id, band2.id]
        }

        post events_path, params: { event: event_params }

        created_event = Event.last
        expect(created_event.bands).to include(band1, band2)
        expect(created_event.band_events.count).to eq(2)
      end
    end

    describe 'month filtering' do
      let!(:january_event) { create(:event, :approved, date: Date.new(2024, 1, 15), venue: venue) }
      let!(:february_event) { create(:event, :approved, date: Date.new(2024, 2, 15), venue: venue) }

      it 'filters events by month' do
        get events_path, params: { month: '2024-01' }

        expect(response.body).to include(january_event.name)
        expect(response.body).not_to include(february_event.name)
      end

      it 'shows appropriate flash message for month filter' do
        get events_path, params: { month: '2024-01' }

        expect(response.body).to include('Showing events for January 2024')
      end
    end

    describe 'JSON API responses' do
      let!(:event) { create(:event, :approved, venue: venue) }

      it 'returns events in JSON format' do
        get events_path, params: { format: :json }

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.first['title']).to eq(event.name)
      end
    end
  end
end 