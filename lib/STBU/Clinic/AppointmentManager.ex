defmodule STBU.Clinic.AppointmentManager do
  use GenServer

  def init(slots) do
    {:ok, slots}
  end

  def handle_call({:available_vets, current_selection}, _from, slots) do
    {:reply, find_available_at_index(slots, current_selection, 0), slots}
  end

  def handle_call({:available_weeks, current_selection}, _from, slots) do
    {:reply, find_available_at_index(slots, current_selection, 2), slots}
  end

  def handle_call({:available_days, current_selection}, _from, slots) do
    {:reply, find_available_at_index(slots, current_selection, 1), slots}
  end

  def handle_call({:available_times, current_selection}, _from, slots) do
    {:reply, find_available_at_index(slots, current_selection, 3), slots}
  end

  def handle_call({:hold, current_selection}, _from, slots) do
    new_slots = slots
    |> Enum.reduce([], fn slot, acc ->
      case STBU.Utils.slot_is_selection(slot, current_selection) do
        true ->
          if elem(slot, 4) do
            :error
          else
            [Tuple.insert_at(slot, 4, true) | acc]
          end
        false -> [slot | acc]
      end
    end)

    case new_slots do
      :error -> {:reply, :error, slots}
      _ -> {:reply, :ok, new_slots}
    end
  end

  def handle_call({:release, current_selection}, _from, slots) do
    slots = slots
    |> Enum.map(fn slot ->
      case STBU.Utils.slot_is_selection(slot, current_selection) do
        true -> Tuple.insert_at(slot, 4, false)
        false -> slot
      end
    end)

    {:reply, :ok, slots}
  end

  defp find_available_at_index(slots, current_selection, index) do
    slots
    |> Enum.filter(fn slot ->
      (elem(slot, 4) == false) && (STBU.Utils.slot_matches_selection(slot, current_selection))
    end)
    |> Enum.map(fn slot -> elem(slot, index) end)
    |> Enum.uniq()
  end

end
