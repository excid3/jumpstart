module AnnouncementsHelper
  def unread_announcements(user)
    last_announcement = Announcement.order(published_at: :desc).first
    return if last_announcement.nil?

    # Highlight announcements for anyone not logged in, cuz tempting
    if user.nil? || user.last_read_announcements_at.nil? || user.last_read_announcements_at < last_announcement.published_at
      "unread-announcements"
    end
  end

  def announcement_class(type)
    {
      "new" => "text-sucess",
      "update" => "text-warning",
      "fix" => "text-danger",
    }.fetch(type, "text-success")
  end
end
