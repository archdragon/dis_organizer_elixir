defmodule Disorganizer.Services.Slack do
  use Application

  def url do
    auth_token = Application.get_env(:disorganizer, :slack_auth_token)
    "https://hooks.slack.com/services/" <> auth_token
  end

  def options(message) do
    [
      body: "
        {
        \"text\": \"" <> message.text <> "\"
        }
      "
   ]
  end
end
