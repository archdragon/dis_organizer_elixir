defmodule Disorganizer.Bot do
  use Application
  use GenServer
  import Supervisor.Spec
  @loop_interval 1000
  @run_every 60 * 60 * 2

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

    run(super_pid, @run_every + 1)

    bot_link
  end

  defp run(super_pid, seconds_since_last_message) do
    case seconds_since_last_message do
      _ when seconds_since_last_message >= @run_every ->
        IO.puts "-> Performing a full run"
        full_run(super_pid)
        :timer.sleep(@loop_interval)
        run(super_pid, 0)
      _ ->
        # IO.puts "-> Too early to run, waiting..."
        :timer.sleep(@loop_interval)
        run(super_pid, (seconds_since_last_message + @loop_interval/1000.0))
    end
  end

  defp full_run(super_pid) do
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
      Disorganizer.Policies.OldStories,
      Disorganizer.Policies.MissingPlusOnes
    ])
    |> select_message
    |> send_message(pids)

    # message2 = GenServer.call(github_pid, {:get, Disorganizer.Services.Github})
    # message3 = GenServer.call(rollbar_pid, {:get, Disorganizer.Services.Rollbar})

    # hipchat_status = GenServer.call(hipchat_pid, {:post, Disorganizer.Services.Hipchat, message2})
    # slack_status = GenServer.call(slack_pid, {:post, Disorganizer.Services.Slack, message2})

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

        send_message(message, pids)
        send_messages(tail, pids)
      [] ->
        {:ok}
    end
  end

  defp select_message(messages) do
    Enum.random messages
  end

  defp send_message(message, pids) do
    hipchat_status = GenServer.call(
      pids.hipchat_pid,
     {:post, Disorganizer.Services.Hipchat, message.html}
    )
  end

end
