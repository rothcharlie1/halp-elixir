defmodule STBU.Interface.AppointmentScheduler do
  use GenServer

  def init({appointment_manager, pet, timeout_millis}) do
    {:ok, {appointment_manager, pet, {nil, nil, nil, nil}, false, false, timeout_millis, nil}}
  end

  def init({appointment_manager, pet, timeout_millis, pet_viewer_pid}) do
    {:ok, {appointment_manager, pet, {nil, nil, nil, nil}, false, false, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:available_vets, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    response = GenServer.call(appointment_manager, {:available_vets, current_selection})
    {:reply, response, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:available_weeks, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    response = GenServer.call(appointment_manager, {:available_weeks, current_selection})
    {:reply, response, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:available_days, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    response = GenServer.call(appointment_manager, {:available_days, current_selection})
    {:reply, response, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:available_times, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    response = GenServer.call(appointment_manager, {:available_times, current_selection})
    {:reply, response, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call({:select_vet, vet}, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    {:reply, :ok, {appointment_manager, pet, Tuple.insert_at(current_selection, 0, vet), held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call({:select_week, week}, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    {:reply, :ok, {appointment_manager, pet, Tuple.insert_at(current_selection, 2, week), held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call({:select_day, day}, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    {:reply, :ok, {appointment_manager, pet, Tuple.insert_at(current_selection, 1, day), held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call({:select_time, time}, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    {:reply, :ok, {appointment_manager, pet, Tuple.insert_at(current_selection, 3, time), held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:current_selection, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    {:reply, current_selection, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
  end

  def handle_call(:finalize, from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    if (not held) and (not Enum.any?(current_selection, &is_nil/1)) do
      case GenServer.call(appointment_manager, {:hold, current_selection}) do
        :ok ->
          Process.send_after(self(), {:check_booked, from}, timeout_millis)
          {:reply, :ok, {appointment_manager, pet, current_selection, true, booked, timeout_millis, pet_viewer_pid}}
        :error -> {:reply, :error, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
      end
    else
      {:reply, :error, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
    end
  end

  def handle_call(:book, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    if held do
      if pet_viewer_pid do
        send pet_viewer_pid, {:booked, pet}
      end
      {:reply, :ok, {appointment_manager, pet, current_selection, held, true, timeout_millis, pet_viewer_pid}}
    else
      {:reply, :error, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
    end
  end

  def handle_info({:check_booked, from}, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    if not booked do
      GenServer.call(appointment_manager, {:release, current_selection})
      send from, {:appointment_timeout, current_selection}
      {:noreply, {appointment_manager, pet, current_selection, false, false, timeout_millis, pet_viewer_pid}}
    else
      {:noreply, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}}
    end
  end

  def handle_call(:reset, _from, {appointment_manager, pet, current_selection, held, booked, timeout_millis, pet_viewer_pid}) do
    if held do
      GenServer.call(appointment_manager, {:release, current_selection})
    end
    {:reply, :ok, {appointment_manager, pet, {nil, nil, nil, nil}, false, booked, timeout_millis, pet_viewer_pid}}
  end

  def available_vets(addr) do
    GenServer.call(addr, :available_vets)
  end

  def available_weeks(addr) do
    GenServer.call(addr, :available_weeks)
  end

  def available_days(addr) do
    GenServer.call(addr, :available_days)
  end

  def available_times(addr) do
    GenServer.call(addr, :available_times)
  end

  def select_vet(addr, vet) do
    GenServer.call(addr, {:select_vet, vet})
  end

  def select_week(addr, week) do
    GenServer.call(addr, {:select_week, week})
  end

  def select_day(addr, day) do
    GenServer.call(addr, {:select_day, day})
  end

  def select_time(addr, time) do
    GenServer.call(addr, {:select_time, time})
  end

  def finalize_details(addr) do
    GenServer.call(addr, :finalize)
  end

  def book(addr) do
    GenServer.call(addr, :book)
  end

  def current_selection(addr) do
    GenServer.call(addr, :current_selection)
  end

  def reset(addr) do
    GenServer.call(addr, :reset)
  end

  def cancel(addr) do
    GenServer.call(addr, :reset)
  end
end
