defmodule Flatfoot.Web.NotificationRecordView do
  use Flatfoot.Web, :view
  alias Flatfoot.Web.NotificationRecordView

  def render("show.json", %{notification_record: notification_record}) do
    %{data: render_one(notification_record, NotificationRecordView, "notification_record.json")}
  end

  def render("notification_record.json", %{notification_record: record}) do
    %{
      user_id: record.user_id,
      nickname: record.nickname,
      email: record.email,
      role: record.role,
      threshold: record.threshold
    }
  end
end
