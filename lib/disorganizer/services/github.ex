defmodule Disorganizer.Services.Github do
  use Application
  use Calendar

  def url do
    repo_addr = Application.get_env(:disorganizer, :github_repo_addr)
    "https://api.github.com/repos/" <> repo_addr <> "/pulls"
  end

  def options do
    auth_token = Application.get_env(:disorganizer, :github_auth_token)
    user_agent = Application.get_env(:disorganizer, :github_user_agent)
    [headers: ["Authorization": "token " <> auth_token, "User-Agent": user_agent]]
  end

  def to_html(response) do
    json = Enum.random(Poison.Parser.parse!(response.body))

    message_text = "Name here<br />This pull request needs another +1<br />" <> json["html_url"]

    %{text: message_text, format: "html"}
  end

  defp extract_days_passed(json) do
    {:ok, parsed} = DateTime.Parse.rfc3339_utc json["created_at"]

    now_unix = Calendar.DateTime.now_utc |> DateTime.Format.unix
    pt_unix = DateTime.Format.unix(parsed)

    days_passed = (now_unix - pt_unix)/(24*60*60) |>  Float.to_string [decimals: 2, compact: true]

    days_text = " days passed " <> days_passed
  end
end
