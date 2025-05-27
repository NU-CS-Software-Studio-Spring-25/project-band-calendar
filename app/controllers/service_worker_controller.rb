class ServiceWorkerController < ActionController::Base
  protect_from_forgery except: :index

  def index
    respond_to do |format|
      format.js { render file: Rails.root.join("app/javascript/controllers/service_worker.js"), content_type: "application/javascript" }
    end
  end
end