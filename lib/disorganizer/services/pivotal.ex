defmodule Disorganizer.Services.Pivotal do
  use Application

  def url(settings) do
    project_id = Application.get_env(:disorganizer, :pivotal_project_id)
    url(%{project_id: project_id}, settings)
  end

  def url(story, settings) do
    "https://www.pivotaltracker.com/services/v5/projects/" <> story.project_id <> "/stories?limit=" <> settings.limit  <>  "&filter=" <> settings.filter
  end

  def options(_) do
    auth_token = Application.get_env(:disorganizer, :pivotal_auth_token)
    [headers: ["X-TrackerToken": auth_token]]
  end

  def collection(response) do
    Poison.Parser.parse!(response.body)
  end
end
