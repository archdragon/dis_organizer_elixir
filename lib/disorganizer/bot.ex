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

    run(super_pid)

    bot_link
  end

  defp run(super_pid) do
    IO.puts "Running main bot loop..."

    [
      {_, pivotal_pid, _, _},
      {_, github_pid,  _, _},
      {_, hipchat_pid, _, _},
      {_, rollbar_pid, _, _},
      {_, slack_pid, _, _}
    ] = Supervisor.which_children(super_pid)

    pids = %{
      pivotal_pid: pivotal_pid,
      github_pid: github_pid,
      hipchat_pid: hipchat_pid,
      rollbar_pid: rollbar_pid,
      slack_pid: slack_pid
    }

    pids
    |> apply_policies([
      Disorganizer.Policies.OldStories
    ])
    |> send_messages(pids)

    # message2 = GenServer.call(github_pid, {:get, Disorganizer.Services.Github})
    # message3 = GenServer.call(rollbar_pid, {:get, Disorganizer.Services.Rollbar})

    # hipchat_status = GenServer.call(hipchat_pid, {:post, Disorganizer.Services.Hipchat, message2})
    # slack_status = GenServer.call(slack_pid, {:post, Disorganizer.Services.Slack, message2})

    :timer.sleep(@interval)

    run(super_pid)
  end

  defp apply_policies(children_pids, policies) do
    apply_policies(children_pids, policies, [])
  end

  defp apply_policies(children_pids, policies, messages) do
    case policies do
      [policy | tail] ->
        apply_policies(
          children_pids,
          tail,
          [policy.apply(children_pids) | messages]
        )
      [] ->
        messages
    end
  end

  defp send_messages(messages, pids) do
    case messages do
      [message | tail] when message == {:error, :no_story} ->
        IO.puts "-> Skipping empty message"
        send_messages(tail, pids)
      [message | tail] ->
        IO.puts "-> Sending a message"
        IO.inspect message
        hipchat_status = GenServer.call(
          pids.hipchat_pid,
          {:post, Disorganizer.Services.Hipchat, message.html}
        )
        send_messages(tail, pids)
      [] ->
        {:ok}
    end
  end

end
