class AnnouncementsController < ApplicationController
  before_action :mark_as_read, if: :user_signed_in?

  def index
    @announcements = Announcement.order(published_at: :desc)
  end

  private

    def mark_as_read
      current_user.update(last_read_announcements_at: Time.zone.now)
    end
end
