defmodule Disorganizer.Supervisor do
  use Supervisor

  def init([]) do
    IO.puts "init"
    children = [
      # worker(ElixirWebCrawler.RedisSupervisor, []),
      # worker(ElixirWebCrawler.Worker, [], restart: :permanent, id: "worker_parse", function: :spawn_parse),
      worker(Disorganizer.Bot, [], id: "worker_bot", name: :worker_bot)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
