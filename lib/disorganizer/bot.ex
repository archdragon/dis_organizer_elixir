defmodule Disorganizer.Bot do
  use Application
  use GenServer
  import Supervisor.Spec
  @interval 10 * 60 * 1000

  def init(_) do
    {:ok, []}
  end

  def start_link() do
    children = [
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_pivotal", name: :worker_pivotal),
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_github",  name: :worker_github),
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_hipchat", name: :worker_hipchat),
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_rollbar", name: :worker_rollbar),
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_slack", name: :worker_slack)
    ]

    {:ok, super_pid} = Supervisor.start_link(children, strategy: :one_for_one)

    bot_link = GenServer.start_link(__MODULE__, [], [])

    perform(super_pid)

    bot_link
  end

  defp apply_policies(children) do
    [
      {_, pivotal_pid, _, _},
      {_, github_pid,  _, _},
      {_, hipchat_pid, _, _},
      {_, rollbar_pid, _, _},
      {_, slack_pid, _, _}
    ] = children
  end

  defp send_messages do
  end

  defp perform(super_pid) do
    IO.puts "Running Bot Actions..."

    [
      {_, pivotal_pid, _, _},
      {_, github_pid,  _, _},
      {_, hipchat_pid, _, _},
      {_, rollbar_pid, _, _},
      {_, slack_pid, _, _}
    ] = Supervisor.which_children(super_pid)

    # Supervisor.which_children(super_pid)
    # |> apply_policies
    # |> send_messages

    message1 = GenServer.call(pivotal_pid, {:get, Disorganizer.Services.Pivotal})
    message2 = GenServer.call(github_pid, {:get, Disorganizer.Services.Github})
    message3 = GenServer.call(rollbar_pid, {:get, Disorganizer.Services.Rollbar})

    hipchat_status = GenServer.call(hipchat_pid, {:post, Disorganizer.Services.Hipchat, message2})
    slack_status = GenServer.call(slack_pid, {:post, Disorganizer.Services.Slack, message2})

    :timer.sleep(@interval)

    perform(super_pid)
  end

end
