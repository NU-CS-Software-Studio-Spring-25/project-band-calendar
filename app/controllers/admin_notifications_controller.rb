class AdminNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_notification, only: [:show, :destroy]
  
  def index
    @notifications = AdminNotification.includes(:sent_by)
                                     .recent
                                     .page(params[:page])
                                     .per(10)
  end

  def new
    @notification = AdminNotification.new
    @events = Event.approved.includes(:venue, :bands).order(:date)
    @users = User.all.order(:email)
  end

  def create
    @notification = AdminNotification.new(notification_params)
    @notification.sent_by = current_user
    
    respond_to do |format|
      if @notification.save
        send_notifications
        format.html { redirect_to admin_notifications_path, notice: 'Notification sent successfully!' }
        format.turbo_stream { redirect_to admin_notifications_path, notice: 'Notification sent successfully!' }
      else
        @events = Event.approved.includes(:venue, :bands).order(:date)
        @users = User.all.order(:email)
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show
  end
  
  def destroy
    @notification.destroy
    redirect_to admin_notifications_path, notice: 'Notification deleted successfully!'
  end

  private

  def ensure_admin
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def set_notification
    @notification = AdminNotification.find(params[:id])
  end

  def notification_params
    params.require(:admin_notification).permit(:subject, :content, event_ids: [], user_ids: [])
  end
  
  def send_notifications
    # Determine recipients
    recipients = if @notification.user_ids.present?
                   User.where(id: @notification.user_ids)
                 else
                   User.all
                 end
    
    # Update the notification with actual user IDs if "all users" was selected
    if @notification.user_ids.blank?
      @notification.update(user_ids: recipients.pluck(:id))
    end
    
    # Send emails to each recipient
    recipients.find_each do |user|
      NotificationMailer.user_notification(user, @notification).deliver_now
    end
    
    # Mark as sent
    @notification.update(sent_at: Time.current)
  end
end
