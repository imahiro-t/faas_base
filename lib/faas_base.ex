defmodule FaasBase do
  @moduledoc """
  This is FaaS base.
  Use FaasBase and implement `handle(event, context)` function
  """

  alias FaasBase.Aws
  alias FaasBase.Azure
  alias FaasBase.Ibm

  @doc """
  Called at initialization process.
  """
  @callback init(context :: map()) :: {:ok, map()} | :ok

  @doc """
  Called at request.
  """
  @callback handle(
              request :: Aws.Request.t() | Azure.Request.t() | Ibm.Request.t(),
              event :: map(),
              context :: map()
            ) ::
              {:ok, String.t()}
              | {:ok, Aws.Response.t()}
              | {:ok, Azure.Response.t()}
              | {:ok, Ibm.Response.t()}
              | {:error, String.t()}
              | {:error, Aws.Response.t()}
              | {:error, Azure.Response.t()}
              | {:error, Ibm.Response.t()}

  defmacro __using__(service: :aws) do
    quote do
      @behaviour FaasBase
    end
  end

  defmacro __using__(service: :azure) do
    quote do
      @behaviour FaasBase
    end
  end

  defmacro __using__(service: :ibm) do
    quote do
      @behaviour FaasBase
      def start() do
        FaasBase.Ibm.Base.start(__MODULE__)
      end
    end
  end
end
