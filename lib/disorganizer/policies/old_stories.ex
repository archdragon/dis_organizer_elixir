# Check outdated stories
defmodule Disorganizer.Policies.OldStories do
  def apply(%{pivotal_pid: pivotal_pid}) do
    GenServer.call(
      pivotal_pid,
      {
        :get,
        Disorganizer.Services.Pivotal,
        fetch_settings()
      }
    )
    |> get_random_story
  end

  defp get_random_story([]) do
    {:error, :no_story}
  end

  defp get_random_story(response) do
    :random.seed(:os.timestamp)
    response
    |> Enum.random
    |> parse
  end

  defp parse(single_message) do
    title = "Found old finished story"
    name = single_message["name"]
    url = single_message["url"]
    story_id_name = "#" <> to_string(single_message["id"])
    link = "<a href=" <> url <> ">" <> story_id_name <> "</a>"

    %{
      text: title <> "\n" <> name <> "\n" <> url,
      html: "<b>" <> title <> "</b><br />" <> name <> "<br />" <> "[" <> link <> "]"
    }
  end

  defp fetch_settings do
    %{
      url_type: :project,
      filter: "state:finished%20created:-100weeks..-1weeks",
      limit: "15"
    }
  end
end
