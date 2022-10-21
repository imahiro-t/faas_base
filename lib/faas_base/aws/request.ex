defmodule FaasBase.Aws.Request do
  @moduledoc """
  A request for AWS Lambda. (format v1 and v2 in API Gateway)

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
  - `:resource` - resource
  - `:path` - path
  - `:http_method` - httpMethod
  - `:multi_value_headers` - multiValueHeaders
  - `:multi_value_query_string_parameters` - multiValueQueryStringParameters
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
    :stage_variables,
    :resource,
    :path,
    :http_method,
    :multi_value_headers,
    :multi_value_query_string_parameters
  ]

  @type t :: %__MODULE__{
          method: atom,
          version: String.t(),
          route_key: String.t(),
          raw_path: String.t(),
          raw_query_string: String.t(),
          cookies: list(String.t()),
          headers: map,
          query_string_parameters: map,
          request_context: map,
          body: String.t(),
          path_parameters: map,
          is_base64_encoded: boolean,
          stage_variables: map,
          resource: String.t(),
          path: String.t(),
          http_method: String.t(),
          multi_value_headers: map,
          multi_value_query_string_parameters: map
        }

  @doc """
  create request from event
  """
  def to_request(event) do
    method =
      case event |> Map.get("requestContext", %{}) |> Map.get("http", %{}) |> Map.get("method", event |> Map.get("httpMethod")) do
        nil -> nil
        method -> method |> String.downcase() |> String.to_atom()
      end
    
    path = event |> Map.get("rawPath", event |> Map.get("path"))

    %__MODULE__{
      method: method,
      version: event |> Map.get("version", "1.0"),
      route_key: event |> Map.get("routeKey"),
      raw_path: path,
      raw_query_string: event |> Map.get("rawQueryString"),
      cookies: event |> Map.get("cookies"),
      headers: event |> Map.get("headers"),
      query_string_parameters: event |> Map.get("queryStringParameters"),
      request_context: event |> Map.get("requestContext"),
      body: event |> Map.get("body"),
      path_parameters: event |> Map.get("pathParameters"),
      stage_variables: event |> Map.get("stageVariables"),
      is_base64_encoded: event |> Map.get("isBase64Encoded"),
      resource: event |> Map.get("resource"),
      path: path,
      http_method: method,
      multi_value_headers: event |> Map.get("multiValueHeaders"),
      multi_value_query_string_parameters: event |> Map.get("multiValueQueryStringParameters")
    }
  end
end
