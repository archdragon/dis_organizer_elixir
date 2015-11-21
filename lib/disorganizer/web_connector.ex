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

  def handle_call({:get, service, settings}, _from, state) do
     url = service.url(settings)
     options = service.options(settings)
     response = HTTPotion.get url, options
     {:reply, service.collection(response), state}
  end

  def handle_call({:post, service, message}, _from, state) do
     response = HTTPotion.post service.url, service.options(message)
     {:reply, response, state}
  end
end
