defmodule Disorganizer.Services.Hipchat do
  use Application

  def url do
    room_id = Application.get_env(:disorganizer, :hipchat_room_id)
    auth_token = Application.get_env(:disorganizer, :hipchat_auth_token)
    url(%{id: room_id, auth_token: auth_token})
  end

  def url(room) do
    "https://api.hipchat.com/v2/room/" <> room.id <> "/notification?auth_token=" <> room.auth_token
  end

  def options(message_html) do
    color = "gray"
    [
      body: "
        {
        \"from\": \"Friendly Reminder Bot\",
        \"message\": \"" <> message_html <> " \",
        \"color\": \"" <> color <> "\",
        \"message_format\": \"html\"
        }
      ",
     headers: ["Content-Type": "application/json"]
   ]
  end
end
