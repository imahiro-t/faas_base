defmodule FaasBase.Common.Logger do
  @moduledoc """
  A logger for Common.

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

  require Logger

  @type level() :: :error | :info | :warn | :debug

  @doc """
  Set log level.
  """
  @spec set_log_level(level()) :: :ok
  def set_log_level(log_level \\ :info) do
    Logger.configure(level: log_level)
  end

  @doc """
  Log Debug.
  """
  def debug(message) when message |> is_binary do
    Logger.debug(message)
    message
  end

  def debug(message) do
    Logger.debug(inspect(message))
    message
  end

  @doc """
  Log Information.
  """
  def info(message) when message |> is_binary do
    Logger.info(message)
    message
  end

  def info(message) do
    Logger.info(inspect(message))
    message
  end

  @doc """
  Log Warning.
  """
  def warn(message) when message |> is_binary do
    Logger.warn(message)
    message
  end

  def warn(message) do
    Logger.warn(inspect(message))
    message
  end

  @doc """
  Log Error.
  """
  def error(message) when message |> is_binary do
    Logger.warn(message)
    message
  end

  def error(message) do
    Logger.warn(inspect(message))
    message
  end
end
