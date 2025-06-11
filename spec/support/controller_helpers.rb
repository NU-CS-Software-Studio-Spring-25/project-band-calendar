module ControllerHelpers
  # Add any common controller test helpers here
  
  def json_response
    JSON.parse(response.body)
  end
  
  def expect_unauthorized_access(path_method, params = {})
    send(path_method, params)
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('You must be an admin to access this page.')
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :request
end 