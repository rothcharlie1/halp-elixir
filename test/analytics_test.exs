defmodule AnalyticsTest do
  use ExUnit.Case


  test "oldest animal of type" do
    animal1 = %{
      "name" => "Fluffy",
      "age" => 3,
      "type" => "dog",
      "beenVaccinated" => true,
      "picture" => "https://example.com/fluffy.jpg"
    }

    animal2 = %{
      "name" => "Whiskers",
      "age" => 2,
      "type" => "cat",
      "beenVaccinated" => false,
      "picture" => "https://example.com/whiskers.jpg"
    }

    animal3 = %{
      "name" => "Bubbles",
      "age" => 2,
      "type" => "cat",
      "beenVaccinated" => true,
      "picture" => "https://example.com/bubbles.jpg"
    }

    test_animals = [animal1, animal2, animal3]

    assert STBU.Analytics.oldest_animal_of_type(test_animals, "dog") == animal1
    assert STBU.Analytics.oldest_animal_of_type(test_animals, "cat") == animal3
  end

  test "day with most available clinicians" do
    test_clinicians = [
      %{
        "name" => "Dr. Smith",
        "specialties" => ["Pediatrics", "Internal Medicine"],
        "schedule" => ["M", "W", "Th"]
      },
      %{
        "name" => "Dr. Johnson",
        "specialties" => ["Dermatology", "Allergy"],
        "schedule" => ["M", "W"]
      },
      %{
        "name" => "Dr. Lee",
        "specialties" => ["Ophthalmology"],
        "schedule" => ["M", "W", "F"]
      }
    ]

    assert STBU.Analytics.most_available_day(test_clinicians) == "M"
  end

  test "analyze_config" do
    {:ok, device} = StringIO.open("{\"animals\":[{\"name\":\"Luna\",\"age\":96,\"type\":\"Cat\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/Luna-91387816-465a-41cd-b39c-a6cb3bbec36a.jpg\"},{\"name\":\"LunaJr\",\"age\":194,\"type\":\"Dog\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/LunaJr-1b105818-4ae2-4205-9064-b0828725c9a3.jpg\"},{\"name\":\"Begus\",\"age\":36,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Begus-0bdec920-cd23-4bc0-aaa6-d0723c51de66.jpg\"},{\"name\":\"Biggie\",\"age\":126,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Biggie-35ff7923-a138-4bdc-999f-99150214b90f.jpg\"},{\"name\":\"SmallsJr\",\"age\":6,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/SmallsJr-f4875b19-cff8-46e8-85ce-b1dcd6040e2d.jpg\"},{\"name\":\"Luna\",\"age\":96,\"type\":\"Cat\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/Luna-91387816-465a-41cd-b39c-a6cb3bbec36a.jpg\"},{\"name\":\"LunaJr\",\"age\":194,\"type\":\"Dog\",\"beenVaccinated\":false,\"picture\":\"file://localhost/shelter/LunaJr-1b105818-4ae2-4205-9064-b0828725c9a3.jpg\"},{\"name\":\"Begus\",\"age\":36,\"type\":\"Dog\",\"beenVaccinated\":true,\"picture\":\"file://localhost/shelter/Begus-0bdec920-cd23-4bc0-aaa6-d0723c51de66.jpg\"}],\"clinicians\":[{\"name\":\"Victoria Maitland-Niles\",\"specialties\":[\"Behavioral Medicine\",\"Emergency Care\"],\"schedule\":[\"Su\",\"W\",\"F\"]},{\"name\":\"Victoria Nguyen\",\"specialties\":[\"Internal Medicine\"],\"schedule\":[\"M\",\"W\"]},{\"name\":\"Sherry Maitland-Niles\",\"specialties\":[],\"schedule\":[\"Tu\",\"Sa\"]},{\"name\":\"Charlie Stone\",\"specialties\":[\"Behavioral Medicine\",\"Anesthesia\"],\"schedule\":[\"W\",\"M\",\"Th\"]},{\"name\":\"John Wallace\",\"specialties\":[\"Dermatology\",\"Emergency Care\",\"Toxicology\"],\"schedule\":[\"F\",\"Su\",\"Sa\",\"Th\",\"W\",\"Tu\",\"M\"]}]}")

    assert STBU.Analytics.analyze_config(device) ==
      %{
        seniors: ["LunaJr", "Luna"],
        availability: "W"
      }
  end


end
