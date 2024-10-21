defmodule STBU.Utils do

  @spec day_to_number(nonempty_binary()) :: 1 | 2 | 3 | 4 | 5 | 6 | 7
  def day_to_number(day) do
    case day do
      "M" -> 1
      "Tu" -> 2
      "W" -> 3
      "Th" -> 4
      "F" -> 5
      "Sa" -> 6
      "Su" -> 7
    end
  end

  def convert_to_pet_view(animal) do
    %{
      :name => animal["name"],
      :age => animal["age"],
      :type => if(animal["type"] == "Dog", do: :dog, else: :cat),
      :beenVacinated => animal["beenVaccinated"],
      :picture => URI.new(animal["picture"])
    }
  end

  def generate_appointment_slots(vets) do
    Enum.flat_map(vets, fn vet ->
      Enum.flat_map(vet["schedule"], fn day ->
        Enum.flat_map([0,1,2,3], fn week ->
          Enum.map(generate_times(day), fn time ->
            {%{name: vet["name"], specialties: vet["specialties"]}, String.to_atom(day), week, time, false}
          end)
        end)
      end)
    end)
  end

  def generate_times(day) do
    case day do
      d when d in ["Sa", "Su"] -> [9, 10, 11, 12, 1]
      _ -> [8, 9, 10, 11, 12, 1, 2, 3, 4, 5]
    end
    |> Enum.flat_map(
      fn hour ->
        {:ok, first} = Time.new(hour, 0, 0)
        {:ok, second} = Time.new(hour, 30, 0)
        [first, second]
      end
    )
  end

  def slot_matches_selection({vet, day, week, time, _held}, {svet, sweek, sday, stime}) do
    (svet == nil or svet == vet) and
    (sweek == nil or sweek == week) and
    (sday == nil or sday == day) and
    (stime == nil or stime == time)
  end

  def slot_is_selection({vet, day, week, time, _held}, {svet, sweek, sday, stime}) do
    svet == vet and sweek == week and sday == day and stime == time
  end
end
