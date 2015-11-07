defmodule Disorganizer.Services.Pivotal do
  use Application

  def url do
    project_id = Application.get_env(:disorganizer, :pivotal_project_id)
    url(%{project_id: project_id})
  end

  def url(story) do
    "https://www.pivotaltracker.com/services/v5/projects/" <> story.project_id <> "/stories?limit=15&filter=state:finished%20created:-100weeks..-2weeks"
  end

  def options do
    auth_token = Application.get_env(:disorganizer, :pivotal_auth_token)
    [headers: ["X-TrackerToken": auth_token]]
  end

  def to_html(response) do
    :random.seed(:os.timestamp)
    json = Enum.random(Poison.Parser.parse!(response.body))

    task_name = json["name"]
    task_url = json["url"]

    task_url_html = "<a href=" <> task_url <> ">" <> task_url <> "</a>"

    message_text = "Found old, undelivered task: <br /> <i>" <> task_name <> "</i> <br /> " <> task_url_html <> " "

    %{text: message_text, format: "html"}
  end
end
