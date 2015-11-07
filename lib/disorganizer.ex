defmodule Disorganizer do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(Disorganizer.Supervisor, [])
  end
end
