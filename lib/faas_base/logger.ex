defmodule FaasBase.Logger do
  @moduledoc """
  A logger for FaaS.

  ## Levels
  The supported levels, ordered by precedence, are:
  - `:debug` - for debug-related messages
  - `:info` - for information of any kind
  - `:warn` - for warnings
  - `:error` - for errors
  For example, `:info` takes precedence over `:debug`. If your log level is set to `:info`, `:info`, `:warn`, and `:error` will be printed to the console. If your log level is set to `:warn`, only `:warn` and `:error` will be printed.

  ## Setting
  Set Log level to `environment` -> `LOG_LEVEL`
  """

  use Agent

  @type on_start() :: {:ok, pid()} | {:error, {:already_started, pid()} | term()}

  @doc """
  Start Logger.

  `module` must be actual Logger module
  """
  def start_link(logger_module \\ FaasBase.Common.Logger) do
    Agent.start_link(fn -> logger_module end, name: __MODULE__)
  end

  @doc """
  Log Debug.
  """
  def debug(message) do
    logger_module()
    |> apply(:debug, [message])
  end

  @doc """
  Log Information.
  """
  def info(message) do
    logger_module()
    |> apply(:info, [message])
  end

  @doc """
  Log Warning.
  """
  def warn(message) do
    logger_module()
    |> apply(:warn, [message])
  end

  @doc """
  Log Error.
  """
  def error(message) do
    logger_module()
    |> apply(:error, [message])
  end

  defp logger_module do
    Agent.get(__MODULE__, & &1)
  end
end
