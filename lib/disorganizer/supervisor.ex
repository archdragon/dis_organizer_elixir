defmodule Disorganizer.Supervisor do
  use Supervisor

  def init([]) do
    children = [
      worker(Disorganizer.Bot, [], id: "worker_bot", name: :worker_bot)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
