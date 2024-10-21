defmodule EagerClientTest do
  use ExUnit.Case

  test "eager client" do
    {:ok, device} = StringIO.open("{\"animals\":[{\"name\":\"Luna\",\"age\":96,\"type\":\"Cat\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Luna-91387816-465a-41cd-b39c-a6cb3bbec36a.jpg\"},{\"name\":\"LunaJr\",\"age\":194,\"type\":\"Dog\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/LunaJr-1b105818-4ae2-4205-9064-b0828725c9a3.jpg\"},{\"name\":\"Begus\",\"age\":36,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Begus-0bdec920-cd23-4bc0-aaa6-d0723c51de66.jpg\"},{\"name\":\"Biggie\",\"age\":126,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Biggie-35ff7923-a138-4bdc-999f-99150214b90f.jpg\"},{\"name\":\"SmallsJr\",\"age\":6,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/SmallsJr-f4875b19-cff8-46e8-85ce-b1dcd6040e2d.jpg\"},{\"name\":\"Luna\",\"age\":96,\"type\":\"Cat\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/Luna-91387816-465a-41cd-b39c-a6cb3bbec36a.jpg\"},{\"name\":\"LunaJr\",\"age\":194,\"type\":\"Dog\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/LunaJr-1b105818-4ae2-4205-9064-b0828725c9a3.jpg\"},{\"name\":\"Begus\",\"age\":36,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Begus-0bdec920-cd23-4bc0-aaa6-d0723c51de66.jpg\"}],\"clinicians\":[{\"name\":\"Victoria Maitland-Niles\",\"specialties\":[\"Behavioral Medicine\",\"Emergency Care\"],\"schedule\":[\"Su\",\"W\",\"F\"]},{\"name\":\"Victoria Nguyen\",\"specialties\":[\"Internal Medicine\"],\"schedule\":[\"M\",\"W\"]},{\"name\":\"Sherry Maitland-Niles\",\"specialties\":[],\"schedule\":[\"Tu\",\"Sa\"]},{\"name\":\"Charlie Stone\",\"specialties\":[\"Behavioral Medicine\",\"Anesthesia\"],\"schedule\":[\"W\",\"M\",\"Th\"]},{\"name\":\"John Wallace\",\"specialties\":[\"Dermatology\",\"Emergency Care\",\"Toxicology\"],\"schedule\":[\"F\",\"Su\",\"Sa\",\"Th\",\"W\",\"Tu\",\"M\"]}]}")

    shelter_pid = STBU.Interface.Entry.initialize_shelter(device, 1000)
    pet_viewer = STBU.Test.EagerClient.start(shelter_pid, 1000)
    assert pet_viewer ==
      {:eager_client_result, %{name: "Luna", type: :cat, age: 96, beenVacinated: true, picture: {:ok, %URI{scheme: "file", userinfo: nil, host: "localhost", port: nil, path: "/shelter/Luna-91387816-465a-41cd-b39c-a6cb3bbec36a.jpg", query: nil, fragment: nil}}}}
  end


end
