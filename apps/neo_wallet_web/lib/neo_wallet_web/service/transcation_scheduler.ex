defmodule NeoWalletWeb.Service.TrascationScheduler do

  use GenServer

  @breakMilliTime 1000 * 10 * 1 # milliseconds
  @switch true

  def start_link(_opt) do
    IO.puts("#{__MODULE__}.start_link")
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    IO.puts("#{__MODULE__}.init")
    do_scheduler()
    {:ok, []}
  end

  def handle_info(:work, state) do
    if @switch do
      work()
    end

    # Reschedule once more
    do_scheduler()
    {:noreply, state}
  end

  defp do_scheduler() do
    Process.send_after(self(), :work, @breakMilliTime)
  end

  defp work() do
    IO.puts("#{__MODULE__} working")
  end
end
