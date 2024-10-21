defmodule STBU.Shelter.PetViewerServer do

  def init({manager_pid, timeout_millis}) do
    {:ok, {-1, false, manager_pid, nil, timeout_millis, {nil, nil}}}
  end

  def handle_call(:view_next, _from, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}) do
    case GenServer.call(manager_pid, {:view, idx + 1}) do
      {:viewing, animal} ->
        if playing do
          GenServer.call(timeout_pid, :cancel)
        end
        {:reply, {:animal, STBU.Utils.convert_to_pet_view(animal)}, {idx + 1, false, manager_pid, nil, timeout_millis, {adopt_timer, client_pid}}}
      :busy ->
        {:reply, :busy, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
    end
  end

  def handle_call(:try_play, from, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}) do
    case GenServer.call(manager_pid, {:play, idx, from}) do
      {:playing, timeout_manager} ->
        {:reply, :playing, {idx, true, manager_pid, timeout_manager, timeout_millis, {adopt_timer, client_pid}}}
      :busy ->
        {:reply, :busy, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
    end
  end

  def handle_call(:try_adopt, from, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}) do
    case GenServer.call(manager_pid, {:adopt, idx, playing}) do
      :adopted -> {:reply, :adopted, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
      :busy -> {:reply, :busy, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
      {:schedule, sched, pet} ->
        adopt_timer = Process.send_after(from, {:adoption_failed, STBU.Utils.convert_to_pet_view(pet)}, timeout_millis)
        {:reply, {:schedule, sched}, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
    end
  end

  def handle_info({:booked, pet}, _from, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}) do
    Process.cancel_timer(adopt_timer)
    send client_pid, {:adopted, STBU.Utils.convert_to_pet_view(pet)}
    {:noreply, {idx, playing, manager_pid, timeout_pid, timeout_millis, {adopt_timer, client_pid}}}
  end

  def handle_call(:finished, _from, {idx, playing, manager_pid, _, _, _}) do
    if playing do
      GenServer.call(manager_pid, {:stop_play, idx})
    end
    nil
  end
end
