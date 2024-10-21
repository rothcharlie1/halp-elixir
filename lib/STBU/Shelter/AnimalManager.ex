defmodule STBU.Shelter.AnimalManager do
  use GenServer

  def init({animal_states, timeout_millis, clinic}) do
    {:ok, {animal_states, timeout_millis, clinic}}
  end

  def handle_call({:play, idx, client_pid}, _from, {animal_states, timeout_millis, clinic}) do
    if elem(Enum.at(animal_states, idx), 1) == {false, false} do
      timeout_manager = STBU.Shelter.PlayTimeoutManager.start_link({self(), client_pid, idx, timeout_millis, elem(Enum.at(animal_states, idx), 0)})
      {:reply, {:playing, timeout_manager}, {List.update_at(animal_states, idx, fn {animal, _} -> {animal, {true, false}} end), timeout_millis, clinic}}
    else
      {:reply, :busy, {animal_states, timeout_millis, clinic}}
    end
  end

  def handle_call({:stop_play, idx}, _from, {animal_states, timeout_millis, clinic}) do
    {:reply, :ok, {
        List.update_at(
          animal_states,
          idx,
          fn {animal, {_, adopted}} -> {animal, {false, adopted}} end
        ),
        timeout_millis,
        clinic
      }
    }
  end

  def handle_call({:adopt, idx, playing}, from, {animal_states, timeout_millis, clinic}) do
    case {playing, elem(Enum.at(animal_states, idx), 1)} do
      {true, {true, true}} -> {:reply, :adopted, {animal_states, timeout_millis, clinic}}
      {true, {true, false}} -> adopt_helper(animal_states, idx, from, timeout_millis, clinic)
      {false, {false, false}} -> adopt_helper(animal_states, idx, from, timeout_millis, clinic)
      _ -> {:reply, :busy, {animal_states, timeout_millis, clinic}}
    end
  end

  defp adopt_helper(animal_states, idx, pid, timeout, clinic) do
    pet = elem(Enum.at(animal_states, idx), 0)
    if pet["beenVaccinated"] do
      {:reply, :adopted, {
          List.update_at(
            animal_states,
            idx,
            fn {animal, _} -> {animal, {true, true}} end
          ),
          timeout,
          clinic
        }
      }
    else
      sched = STBU.Interface.Clinic.request_appointment(clinic, pet, pid)
      {:reply, {:schedule, sched, pet}, {animal_states, timeout, clinic}}
    end
  end

  def handle_call({:force_adopt, idx}, _from, {animal_states, timeout, clinic}) do
    {:reply, :ok, {
        List.update_at(
          animal_states,
          idx,
          fn {animal, _} -> {animal, {true, true}} end
        ),
      timeout,
      clinic
      }
    }
  end

  def handle_call({:view, idx}, _from, {animal_states, timeout_millis, clinic}) do
    case elem(Enum.at(animal_states, idx), 1) do
      {false, false} ->
        {:reply, {:viewing, elem(Enum.at(animal_states, idx), 0)}, {animal_states, timeout_millis, clinic}}
      {_, _} ->
        {:reply, :busy, {animal_states, timeout_millis, clinic}}
    end
  end

  def handle_call({:new_animals, animals}, _from, {animal_states, timeout_millis, clinic}) do
    {:reply, :ok, {
        animal_states ++ Enum.map(
        animals,
        fn animal -> {animal, {false, false}} end
      ),
      timeout_millis,
      clinic
      }
    }
  end

end
