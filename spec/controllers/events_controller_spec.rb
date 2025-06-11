require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:venue) { create(:venue) }
  let(:valid_attributes) do
    {
      name: 'Test Concert',
      date: 1.week.from_now,
      venue_id: venue.id
    }
  end

  describe 'GET #index' do
    let!(:approved_event) { create(:event, :approved) }
    let!(:pending_event) { create(:event, approved: false) }

    context 'when not signed in' do
      it 'shows only approved events' do
        get :index
        expect(assigns(:events)).to include(approved_event)
        expect(assigns(:events)).not_to include(pending_event)
      end
    end

    context 'when signed in as regular user' do
      it 'shows only approved events by default' do
        regular_user = create(:user)
        sign_in regular_user
        
        get :index
        expect(assigns(:events)).to include(approved_event)
        expect(assigns(:events)).not_to include(pending_event)
      end
    end

    context 'when signed in as admin' do
      it 'shows only approved events by default' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        get :index
        expect(assigns(:events)).to include(approved_event)
        expect(assigns(:events)).not_to include(pending_event)
      end

      it 'shows pending events when pending param is present' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        get :index, params: { pending: true }
        expect(assigns(:events)).to include(pending_event)
        expect(assigns(:events)).not_to include(approved_event)
      end
    end
  end

  describe 'POST #create' do
    context 'when not signed in' do
      it 'redirects to sign in page' do
        post :create, params: { event: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as regular user' do
      context 'with valid parameters' do
        it 'creates a new event' do
          regular_user = create(:user)
          sign_in regular_user
          
          expect {
            post :create, params: { event: valid_attributes }
          }.to change(Event, :count).by(1)
        end

        it 'sets the current user as submitter' do
          regular_user = create(:user)
          sign_in regular_user
          
          post :create, params: { event: valid_attributes }
          expect(Event.last.submitted_by).to eq(regular_user)
        end

        it 'creates event as unapproved by default' do
          regular_user = create(:user)
          sign_in regular_user
          
          post :create, params: { event: valid_attributes }
          expect(Event.last.approved?).to be false
        end

        it 'redirects to the event with appropriate message' do
          regular_user = create(:user)
          sign_in regular_user
          
          post :create, params: { event: valid_attributes }
          expect(response).to redirect_to(Event.last)
          expect(flash[:notice]).to include('awaiting approval')
        end
      end
    end

    context 'when signed in as admin' do
      it 'auto-approves events created by admin' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        post :create, params: { event: valid_attributes }
        expect(Event.last.approved?).to be true
      end

      it 'redirects with success message for approved event' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        post :create, params: { event: valid_attributes }
        expect(response).to redirect_to(Event.last)
        expect(flash[:notice]).to eq('Event was successfully created.')
      end
    end
  end

  describe 'PATCH #approve' do
    let(:event) { create(:event, approved: false) }

    context 'when not signed in' do
      it 'redirects to sign in page' do
        patch :approve, params: { id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as regular user' do
      it 'denies access' do
        regular_user = create(:user)
        sign_in regular_user
        
        patch :approve, params: { id: event.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You must be an admin to access this page.')
      end
    end

    context 'when signed in as admin' do
      it 'approves the event' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        patch :approve, params: { id: event.id }
        event.reload
        expect(event.approved?).to be true
      end

      it 'redirects with success message' do
        admin_user = create(:user, :admin)
        sign_in admin_user
        
        patch :approve, params: { id: event.id }
        expect(response).to redirect_to(event)
        expect(flash[:notice]).to eq('Event has been approved.')
      end
    end
  end

  describe 'PATCH #disapprove' do
    let(:event) { create(:event, :approved) }

    context 'when signed in as admin' do
      before do
        admin_user = create(:user, :admin)
        sign_in admin_user
        allow(controller).to receive(:current_user).and_return(admin_user)
        allow(controller).to receive(:current_user_admin?).and_return(true)
      end

      it 'unapproves the event' do
        patch :disapprove, params: { id: event.id }
        event.reload
        expect(event.approved?).to be false
      end

      it 'redirects with success message' do
        patch :disapprove, params: { id: event.id }
        expect(response).to redirect_to(event)
        expect(flash[:notice]).to eq('Event has been unapproved.')
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { name: 'Updated Concert Name' } }

    context 'when signed in as event submitter' do
      it 'updates the event' do
        submitter = create(:user)
        event = create(:event, submitted_by: submitter)
        allow(controller).to receive(:current_user).and_return(submitter)
        allow(controller).to receive(:current_user_admin?).and_return(false)
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:authorize_event_edit!).and_return(true)
        
        patch :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.name).to eq('Updated Concert Name')
      end

      it 'sets approved to false for non-admin updates' do
        submitter = create(:user)
        event = create(:event, submitted_by: submitter)
        event.update(approved: true)
        allow(controller).to receive(:current_user).and_return(submitter)
        allow(controller).to receive(:current_user_admin?).and_return(false)
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:authorize_event_edit!).and_return(true)
        
        patch :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.approved?).to be false
      end
    end

    context 'when signed in as admin' do
      it 'can update any event without affecting approval status' do
        admin_user = create(:user, :admin)
        regular_user = create(:user)
        event = create(:event, submitted_by: regular_user)
        event.update(approved: true)
        allow(controller).to receive(:current_user).and_return(admin_user)
        allow(controller).to receive(:current_user_admin?).and_return(true)
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:authorize_event_edit!).and_return(true)
        
        patch :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.name).to eq('Updated Concert Name')
        expect(event.approved?).to be true
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when signed in as event submitter' do
      it 'destroys the event' do
        submitter = create(:user)
        event = create(:event, submitted_by: submitter)
        sign_in submitter
        
        expect {
          delete :destroy, params: { id: event.id }
        }.to change(Event, :count).by(-1)
      end

      it 'redirects to events index with success message' do
        submitter = create(:user)
        event = create(:event, submitted_by: submitter)
        sign_in submitter
        
        delete :destroy, params: { id: event.id }
        expect(response).to redirect_to(events_path)
        expect(flash[:notice]).to eq('Event was successfully deleted.')
      end
    end
  end
end 