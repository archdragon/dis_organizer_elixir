defmodule Disorganizer.WebConnector do
  use Application
  use GenServer

  def init(_) do
    {:ok, []}
  end

  def start_link() do
    start_link([], [])
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def handle_call({:get, service}, _from, state) do
     response = HTTPotion.get service.url, service.options
     {:reply, service.to_html(response), state}
  end

  def handle_call({:post, service, message}, _from, state) do
     response = HTTPotion.post service.url, service.options(message)
     {:reply, response, state}
  end
end
