defmodule STBU.IO do

  def read_json_from_io(device) do
    data = IO.binread(device, :eof)
    json_string = String.trim(data)

    # Parse the JSON string
    case Jason.decode(json_string) do
      {:ok, json_data} ->
        json_data
      {:error, reason} ->
        raise "Error decoding JSON: #{reason}"
    end
  end
end
