defmodule FaasBase.Ibm.Request do
  @moduledoc """
  A request for IBM Functions.

  ## properties
  - `:method` - Http method as an atom(`:get`, `:post`, etc.)
  - `:headers` - Http headers as map
  - `:body` - Http body as string
  - `:path` - Http body as string
  """

  defstruct [
    :method,
    :headers,
    :body,
    :path
  ]

  @doc """
  create request from event
  """
  def to_request(event) do
    %__MODULE__{
      method:
        case event |> Map.get("__ow_method") do
          nil -> nil
          method -> method |> String.downcase() |> String.to_atom()
        end,
      headers: event |> Map.get("__ow_headers"),
      body: event |> Map.drop(["__ow_method", "__ow_headers", "__ow_path"]) |> Jason.encode!(),
      path: event |> Map.get("__ow_path")
    }
  end
end
