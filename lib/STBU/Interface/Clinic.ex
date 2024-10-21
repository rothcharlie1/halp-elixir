import STBU.Utils

defmodule STBU.Interface.Clinic do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def whereis do
    Process.whereis(__MODULE__)
  end

  def request_appointment(addr, pet) do
    GenServer.call(addr, {:schedule, pet})
  end

  def request_appointment(addr, pet, pet_viewer_pid) do
    GenServer.call(addr, {:schedule, pet, pet_viewer_pid})
  end

  def init({config, timeout_millis}) do
    {:ok, appointment_manager} = GenServer.start_link(STBU.Clinic.AppointmentManager, generate_appointment_slots(config["clinicians"]))
    {:ok, {appointment_manager, timeout_millis}}
  end

  def handle_call({:schedule, pet}, _from, {appointment_manager, timeout_millis}) do
    {:ok, scheduler} = GenServer.start_link(AppointmentScheduler, {appointment_manager, pet, timeout_millis})
    {:reply, scheduler, {appointment_manager, timeout_millis}}
  end

  def handle_call({:schedule, pet, viewer}, _from, {appointment_manager, timeout_millis}) do
    {:ok, scheduler} = GenServer.start_link(AppointmentScheduler, {appointment_manager, pet, timeout_millis, viewer})
    {:reply, scheduler, {appointment_manager, timeout_millis}}
  end

end
