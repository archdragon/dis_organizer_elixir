# Check outdated PRs
defmodule Disorganizer.Policies.MissingPlusOnes do
  def apply(%{github_pid: github_pid}) do
    GenServer.call(
      github_pid,
      {
        :get,
        Disorganizer.Services.Github,
        fetch_settings()
      }
    )
    |> select_pull_requests
    |> select_single_labels
    |> get_random_story
  end

  defp select_pull_requests([]) do
    []
  end

  defp select_pull_requests(response) do
    Enum.filter(response, fn(item) ->
      item["pull_request"]
    end)
  end

  defp select_single_labels([]) do
    []
  end

  defp select_single_labels(response) do
    Enum.filter(response, fn(item) ->
      Enum.count(item["labels"]) > 0
    end)
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
    title = "Pull requests needs another +1"
    name = single_message["title"]
    url = single_message["html_url"]
    pr_id_name = "#" <> to_string(single_message["id"])
    link = "<a href=" <> url <> ">" <> name <> "</a>"

    %{
      text: title <> "\n" <> name <> "\n" <> url,
      html: "<b>" <> title <> "</b><br />" <> link
    }
  end

  defp fetch_settings do
    %{}
  end
end
