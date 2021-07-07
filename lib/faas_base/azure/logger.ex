defmodule FaasBase.Azure.Logger do
  @moduledoc """
  A logger for Azure Functions.

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

  @type level() :: :error | :info | :warn | :debug
  @type on_start() :: {:ok, pid()} | {:error, {:already_started, pid()} | term()}

  @doc """
  Start Logger.

  `log_level` must be in `[:debug, :info, :warn, :error]`
  """
  @spec start_link(level()) :: on_start()
  def start_link(log_level \\ :info) do
    Agent.start_link(fn -> %{log_level: log_level, logs: []} end, name: __MODULE__)
  end

  @doc """
  Log Debug.
  """
  def debug(message) do
    if log?(:debug) do
      log("#{timestamp()} [DEBUG] #{message |> log_message}")
    end

    message
  end

  @doc """
  Log Information.
  """
  def info(message) do
    if log?(:info) do
      log("#{timestamp()} [INFO] #{message |> log_message}")
    end

    message
  end

  @doc """
  Log Warning.
  """
  def warn(message) do
    if log?(:warn) do
      log("#{timestamp()} [WARN] #{message |> log_message}")
    end

    message
  end

  @doc """
  Log Error.
  """
  def error(message) do
    if log?(:error) do
      log("#{timestamp()} [ERROR] #{message |> log_message}")
    end

    message
  end

  @doc """
  Get logs.
  """
  def logs() do
    Agent.get_and_update(__MODULE__, fn state -> {state, %{state | logs: []}} end).logs
  end

  defp timestamp do
    DateTime.utc_now() |> to_string
  end

  defp log_message(message) when is_binary(message), do: message
  defp log_message(message), do: inspect(message)

  defp log(message) do
    Agent.update(__MODULE__, fn %{logs: logs} = state -> %{state | logs: logs ++ [message]} end)
    message
  end

  defp log_level do
    Agent.get(__MODULE__, & &1).log_level
  end

  defp log?(level) do
    level |> log?(log_level())
  end

  defp log?(:debug, log_level) do
    case log_level do
      :debug -> true
      _ -> false
    end
  end

  defp log?(:info, log_level) do
    case log_level do
      :debug -> true
      :info -> true
      _ -> false
    end
  end

  defp log?(:warn, log_level) do
    case log_level do
      :debug -> true
      :info -> true
      :warn -> true
      _ -> false
    end
  end

  defp log?(:error, log_level) do
    case log_level do
      :debug -> true
      :info -> true
      :warn -> true
      :error -> true
      _ -> false
    end
  end
end
