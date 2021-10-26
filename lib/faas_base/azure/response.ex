defmodule FaasBase.Azure.Response do
  @moduledoc """
  A response for Azure Functions.

  ## properties
  - `:body` - Http body as string
  - `:headers` - Http headers as map
  - `:status_code` - Http status code as integer
  """

  defstruct [
    :body,
    :headers,
    :status_code
  ]

  @type t :: %__MODULE__{
          body: String.t(),
          headers: map,
          status_code: integer
        }

  @doc """
  create response
  """
  def to_response(body) do
    %__MODULE__{
      body: body,
      headers: %{},
      status_code: 200
    }
  end

  @doc """
  create response
  """
  def to_response(body, headers) do
    %__MODULE__{
      body: body,
      headers: headers,
      status_code: 200
    }
  end

  @doc """
  create response
  """
  def to_response(body, headers, status_code) do
    %__MODULE__{
      body: body,
      headers: headers,
      status_code: status_code
    }
  end
end
