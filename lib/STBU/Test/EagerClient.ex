defmodule STBU.Test.EagerClient do
  import STBU.Interface.PetViewer

  def start(shelter_addr, patience) do
    viewer_addr = STBU.Interface.Shelter.view_pets(shelter_addr)
    start_with_viewer(viewer_addr, patience)

  end

  def start_with_viewer(viewer_addr, patience) do
    animal = view_next(viewer_addr)
    if (animal) do
      if !(try_play(viewer_addr) == :ok) do
        start_with_viewer(viewer_addr, patience)
      else
        if !(try_adopt(viewer_addr) == :ok) do
          start_with_viewer(viewer_addr, patience)
        end
      end
      {:eager_client_result, animal}
    else
      {:eager_client_result, nil}
    end
  end

end
