defmodule STBU.Shelter.PlayTimeoutManager do
  use GenServer

  def init({manager_pid, client_pid, idx, timeout, animal}) do
    manager_future = Process.send_after(manager_pid, {:stop_play, idx}, timeout)
    client_future = Process.send_after(client_pid, {:play_timeout, STBU.Utils.convert_to_pet_view(animal)}, timeout)
    {:ok, {manager_future, client_future, manager_pid, client_pid, idx, animal}}
  end

  def handle_call(:cancel, _from, {manager_future, client_future, manager_pid, client_pid, idx, animal}) do
    Process.cancel_timer(manager_future)
    Process.cancel_timer(client_future)
    send manager_pid, {:stop_play, idx}
    {:reply, :ok, {nil, nil, manager_pid, client_pid, idx, animal}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def cancel(pid) do
    GenServer.call(pid, :cancel)
    GenServer.stop(pid)
  end
end
