# Event Submission Step Definitions

Given('the following venues exist:') do |table|
  table.hashes.each do |venue_attrs|
    FactoryBot.create(:venue, venue_attrs)
  end
end

Given('the following bands exist:') do |table|
  table.hashes.each do |band_attrs|
    FactoryBot.create(:band, band_attrs)
  end
end

Given('I am registered as a user with email {string} and password {string}') do |email, password|
  @user = FactoryBot.create(:user, email: email, password: password, password_confirmation: password)
end

Given('I am signed in as a regular user') do
  @user ||= FactoryBot.create(:user)
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'
end

Given('an approved event exists with name {string} and date {string}') do |name, date|
  venue = Venue.first || FactoryBot.create(:venue)
  user = User.first || FactoryBot.create(:user)
  FactoryBot.create(:event, :approved, name: name, date: Date.parse(date), venue: venue, submitted_by: user)
  @events_created_in_given = Event.count
end

When('I visit the new event page') do
  visit new_event_path
end

When('I fill in the event form with:') do |table|
  table.hashes.each do |field_data|
    case field_data['field']
    when 'Name'
      fill_in 'event_name', with: field_data['value']
    when 'Date'
      fill_in 'event_date', with: field_data['value']
    when 'Venue'
      venue = Venue.find_by(name: field_data['value'])
      select venue.name, from: 'event_venue_id'
    end
  end
end

When('I select the bands {string}') do |band_names|
  band_names.split(', ').each do |band_name|
    band = Band.find_by(name: band_name)
    if band
      # Create hidden input fields for band selection without JavaScript
      page.find('#band-ids-container').find(:xpath, '..').append(<<-HTML)
        <input type="hidden" name="event[band_ids][]" value="#{band.id}">
      HTML
    end
  end
end

When('I submit the event') do
  click_button 'Create'
end

When('I submit the event without filling required fields') do
  click_button 'Create'
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end

Then('the event should be created with status {string}') do |status|
  event = Event.last
  expect(event).to be_present
  case status
  when 'pending'
    expect(event.approved).to be false
  when 'approved'
    expect(event.approved).to be true
  end
end

Then('the event should be associated with the current user') do
  event = Event.last
  expect(event.submitted_by).to eq(@user)
end

Then('no new event should be created') do
  expected_count = @events_created_in_given || @scenario_start_event_count
  expect(Event.count).to eq(expected_count)
end

Then('I should see validation errors for required fields') do
  # Look for common validation error patterns
  has_blank_error = page.has_content?("can't be blank")
  has_required_error = page.has_content?("is required") 
  has_presence_error = page.has_content?("presence")
  has_error_class = page.has_css?('.field_with_errors, .invalid-feedback, .error')
  
  expect(has_blank_error || has_required_error || has_presence_error || has_error_class).to be true
end

# Hook to track initial event count for each scenario
Before do
  @scenario_start_event_count = Event.count
end 