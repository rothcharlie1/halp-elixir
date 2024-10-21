
defmodule STBU.Interface.Entry do

  def initialize_shelter(device, timeout_millis) do
    config = STBU.IO.read_json_from_io(device)
    {:ok, clinic} = STBU.Interface.Clinic.start_link({config, timeout_millis})
    {:ok, shelter} = STBU.Interface.Shelter.start_link({config, timeout_millis, clinic})
    shelter
  end

  def initialize_shelter_and_clinic(device, timeout_millis) do
    config = STBU.IO.read_json_from_io(device)
    {:ok, clinic} = STBU.Interface.Clinic.start_link({config, timeout_millis})
    {:ok, shelter} = STBU.Interface.Shelter.start_link({config, timeout_millis, clinic})
    {shelter, clinic}
  end

end
