defmodule Disorganizer.Services.Rollbar do
  use Application

  def url(settings) do
    url_deploy()
  end

  def url_deploy do
    auth_token = Application.get_env(:disorganizer, :rollbar_auth_token)
    "https://api.rollbar.com/api/1/deploys/?access_token=" <> auth_token
  end

  def options do
    []
  end

  def to_html(response) do
    all_json = Poison.Parser.parse!(response.body)
    [json | _ ] = all_json["result"]["deploys"]

    revision = json["revision"]

    message_text = "Last deploy: " <> revision

    %{text: message_text, format: "html"}
  end
end
