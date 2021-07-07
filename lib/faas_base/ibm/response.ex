defmodule FaasBase.Ibm.Response do
  @moduledoc """
  A response for IBM Functions.

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
