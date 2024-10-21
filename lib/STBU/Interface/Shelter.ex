
defmodule STBU.Interface.Shelter do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def whereis do
    Process.whereis(__MODULE__)
  end

  def init({config, timeout_millis, clinic}) do
    animal_states = Enum.map(config["animals"], fn animal -> {animal, {false, false}} end)
    animal_manager = GenServer.start_link(STBU.Shelter.AnimalManager, {animal_states, timeout_millis, clinic})
    {:ok, {animal_manager, config, timeout_millis}}
  end

  def handle_call({:import, device}, _from, {animal_manager, config, timeout_millis}) do
    animals = STBU.IO.read_json_from_io(device)
    config = Map.update(config, "animals", animals, fn ans -> ans ++ animals end)
    GenServer.call(animal_manager, {:new_animals, animals})
    {:reply, :ok, {animal_manager, config, timeout_millis}}
  end

  def handle_call(:view_pets, _from, {animal_manager, config, timeout_millis}) do
    viewer = GenServer.start_link(STBU.Shelter.PetViewerServer, {animal_manager, timeout_millis})
    {:reply, {:pet_viewer, viewer}, {animal_manager, config, timeout_millis}}
  end

  def view_pets(shelter_addr) do
    {:pet_viewer, pid} = GenServer.call(shelter_addr, :view_pets)
    pid
  end

  def import_animals(shelter_addr, device) do
    GenServer.call(shelter_addr, {:import, device})
  end
end
