defmodule STBU.Analytics do
  @moduledoc """
  This module is responsible for analytics of the SBTU configuration.
  """

  @doc """
  Reads a JSON configuration from the device and returns a map with the oldest
  pets of each type and the day-of-week with the most available vets.

  Results are returned as a map with the following structure:
  %{
    seniors: [StringOrNil, StringOrNil],
    availability: Day
  }
  where Day is one of "M", "Tu", "W", "Th", "F", "Sa", "Su"
  """
  @spec analyze_config(IO.device()) :: map
  def analyze_config(device) do
    config = STBU.IO.read_json_from_io(device)

    %{
      seniors: [
        oldest_animal_of_type(config["animals"], "Dog")["name"],
        oldest_animal_of_type(config["animals"], "Cat")["name"]
      ],
      availability: most_available_day(config["clinicians"])
    }
  end

  @doc """
  Finds the oldest animal in 'animals' of the given type 'type'.
  """
  @spec oldest_animal_of_type([%{String => any()}], bitstring()) :: map
  def oldest_animal_of_type(animals, type) do
    Enum.reduce(animals, nil, fn animal, oldest_animal ->
      if animal["type"] == type do
        case oldest_animal do
          nil -> animal
          _ -> if animal["age"] > oldest_animal["age"]
            || (animal["age"] == oldest_animal["age"] && animal["name"] < oldest_animal["name"]),
            do: animal, else: oldest_animal
        end
      else
        oldest_animal
      end
    end)
  end

  @doc"""
  Finds the day with the most available clinicians.
  """
  @spec most_available_day([map]) :: String
  def most_available_day(clinicians) do
    Enum.reduce(clinicians, %{}, fn clinician, availability -> # accumulate over clinicians
      Enum.reduce(clinician["schedule"], availability, fn day, availability ->
        Map.update(availability, day, 1, fn current -> current + 1 end) # add each day to the map
      end)
    end)
    |> Map.to_list()
    |> Enum.max_by(fn {day, count} -> {count, 7 - STBU.Utils.day_to_number(day)} end)
    |> elem(0)
  end
end
