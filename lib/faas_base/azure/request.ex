defmodule FaasBase.Azure.Request do
  @moduledoc """
  A request for Azure Functions.

  ## properties
  - `:method` - Http method as an atom(`:get`, `:post`, etc.)
  - `:url` - request url
  - `:headers` - Http headers as map
  - `:body` - Http body as string
  - `:params` - Http params as map
  - `:query` - Http query as map
  - `:method_name` - Http query as string
  """

  defstruct [
    :method,
    :url,
    :headers,
    :body,
    :params,
    :query,
    :method_name
  ]

  @doc """
  create request from event
  """
  def to_request(event) do
    %{"Data" => %{"req" => request}, "Metadata" => metadata} = event

    %__MODULE__{
      method:
        case request |> Map.get("Method") do
          nil -> nil
          method -> method |> String.downcase() |> String.to_atom()
        end,
      url: request |> Map.get("Url"),
      headers: metadata |> Map.get("Headers"),
      body: request |> Map.get("Body"),
      params: request |> Map.get("Params"),
      query: request |> Map.get("Query"),
      method_name: metadata |> Map.get("sys", %{}) |> Map.get("MethodName")
    }
  end
end
