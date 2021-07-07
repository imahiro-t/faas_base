defmodule FaasBase.Ibm.Base do
  alias FaasBase.Ibm.Request
  alias FaasBase.Ibm.Response
  alias FaasBase.Ibm.Logger

  def start(module) do
    context = System.get_env()
    event = context |> Map.get("___EVENT", "{}") |> Jason.decode!()
    log_level = event |> Map.get("LOG_LEVEL", "INFO") |> String.downcase() |> String.to_atom()
    Logger.start_link(log_level)
    FaasBase.Logger.start_link(Logger)
    event = event |> Map.delete("LOG_LEVEL")

    case context |> module.init() do
      {:ok, context} ->
        handle_event(event, context, module)

      :ok ->
        handle_event(event, context, module)

      _ ->
        :halt
    end
  end

  def handle_event(event, context, module) do
    Logger.debug(event)
    Logger.debug(context)
    request = event |> Request.to_request()

    module
    |> apply(:handle, [request, event, context])
    |> case do
      {:ok, %Response{} = result} ->
        Logger.debug(result)
        result

      {:ok, result} ->
        Logger.debug(result)
        result |> Response.to_response(%{}, 200)

      {:error, %Response{} = error} ->
        Logger.debug(error)
        error

      {:error, error} ->
        Logger.debug(error)
        error |> Response.to_response(%{}, 400)
    end
    |> response_message
    |> IO.puts()
  end

  defp response_message(%Response{body: body, headers: headers, status_code: status_code}) do
    %{
      headers: headers,
      body: body,
      statusCode: status_code
    }
    |> Jason.encode!()
  end
end
