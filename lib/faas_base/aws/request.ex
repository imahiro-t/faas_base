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
    :resource,
    :path,
    :http_method,
    :headers,
    :multi_value_headers,
    :query_string_parameters,
    :multi_value_query_string_parameters,
    :request_context,
    :path_parameters,
    :stage_variables,
    :body,
    :is_base64_encoded
  ]

  @doc """
  create request from event
  """
  def to_request(event) do
    http_method =
      case event |> Map.get("httpMethod") do
        nil -> nil
        method -> method |> String.downcase() |> String.to_atom()
      end

    %__MODULE__{
      method: http_method,
      version: event |> Map.get("version", "1.0"),
      resource: event |> Map.get("resource"),
      path: event |> Map.get("path"),
      http_method: http_method,
      headers: event |> Map.get("headers"),
      multi_value_headers: event |> Map.get("multiValueHeaders"),
      query_string_parameters: event |> Map.get("queryStringParameters"),
      multi_value_query_string_parameters: event |> Map.get("multiValueQueryStringParameters"),
      request_context: event |> Map.get("requestContext"),
      path_parameters: event |> Map.get("pathParameters"),
      stage_variables: event |> Map.get("stageVariables"),
      body: event |> Map.get("body", event |> Jason.encode!()),
      is_base64_encoded: event |> Map.get("isBase64Encoded")
    }
  end
end
