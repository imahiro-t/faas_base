defmodule FaasBase.Aws.Request do
  @moduledoc """
  A request for AWS Lambda.

  ## properties
  - `:method` - method
  - `:version` - version
  - `:route_key` - routeKey
  - `:raw_path` - rawPath
  - `:raw_query_string` - rawQueryString
  - `:cookies` - cookies
  - `:headers` - headers
  - `:query_string_parameters` - queryStringParameters
  - `:request_context` - requestContext
  - `:body` - body
  - `:path_parameters` - pathParameters
  - `:is_base64_encoded` - isBase64Encoded
  - `:stage_variables` - stageVariables
  """

  defstruct [
    :method,
    :version,
    :route_key,
    :raw_path,
    :raw_query_string,
    :cookies,
    :headers,
    :query_string_parameters,
    :request_context,
    :body,
    :path_parameters,
    :is_base64_encoded,
    :stage_variables
  ]

  @doc """
  create request from event
  """
  def to_request(event) do
    %__MODULE__{
      method:
        case event
             |> Map.get("requestContext", %{})
             |> Map.get("http", %{})
             |> Map.get("method") do
          nil -> nil
          method -> method |> String.downcase() |> String.to_atom()
        end,
      version: event |> Map.get("version"),
      route_key: event |> Map.get("routeKey"),
      raw_path: event |> Map.get("rawPath"),
      raw_query_string: event |> Map.get("rawQueryString"),
      cookies: event |> Map.get("cookies"),
      headers: event |> Map.get("headers"),
      query_string_parameters: event |> Map.get("queryStringParameters"),
      request_context: event |> Map.get("requestContext"),
      body: event |> Map.get("body", event |> Jason.encode!()),
      path_parameters: event |> Map.get("pathParameters"),
      is_base64_encoded: event |> Map.get("isBase64Encoded"),
      stage_variables: event |> Map.get("stageVariables")
    }
  end
end
