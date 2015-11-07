defmodule Disorganizer.Bot do
  use Application
  use GenServer
  import Supervisor.Spec

  def init(_) do
    IO.puts "Init Bot"
    {:ok, []}
  end

  def start_link() do
    children = [
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_pivotal", name: :worker_pivotal),
      Supervisor.Spec.worker(Disorganizer.WebConnector, [], id: "worker_hipchat", name: :worker_hipchat)
    ]

    {:ok, super_pid} = Supervisor.start_link(children, strategy: :one_for_one)
    [{_, pivotal_pid, _, _}, {_, hipchat_pid, _, _}] = Supervisor.which_children(super_pid)

    IO.puts "Starting Bot"
    bot_link = GenServer.start_link(__MODULE__, [], [])

    message = GenServer.call(pivotal_pid, {:get, Disorganizer.Services.Pivotal})
    hipchat_status = GenServer.call(hipchat_pid, {:post, Disorganizer.Services.Hipchat, message})

    bot_link
  end

end
