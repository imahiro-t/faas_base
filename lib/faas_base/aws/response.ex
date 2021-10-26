defmodule FaasBase.Aws.Response do
  @moduledoc """
  A response for AWS Lambda.

  ## properties
  - `:body` - Http body as string
  - `:headers` - Http headers as map
  - `:status_code` - Http status code as integer
  - `:is_base64_encoded` - for binary support
  """

  defstruct [
    :body,
    :headers,
    :status_code,
    is_base64_encoded: false
  ]

  @type t :: %__MODULE__{
          body: String.t(),
          headers: map,
          status_code: integer,
          is_base64_encoded: boolean
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

  @doc """
  create response
  """
  def to_response(body, headers, status_code, is_base64_encoded) do
    %__MODULE__{
      body: body,
      headers: headers,
      status_code: status_code,
      is_base64_encoded: is_base64_encoded
    }
  end
end
