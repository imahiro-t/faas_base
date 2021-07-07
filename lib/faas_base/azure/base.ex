defmodule FaasBase.Azure.Base do
  use Plug.Router

  alias FaasBase.Azure.Request
  alias FaasBase.Azure.Response
  alias FaasBase.Azure.Logger

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  def init(options) do
    context = System.get_env()

    Module.concat([Elixir, context |> handler()])
    |> apply(:init, [context])

    options
  end

  # health check
  get "/" do
    send_resp(conn, 200, "OK")
  end

  # request
  match _ do
    context = System.get_env()
    event = conn.body_params
    Logger.debug(event)
    Logger.debug(context)

    Module.concat([Elixir, context |> handler()])
    |> apply(:handle, [event |> Request.to_request(), event, context])
    |> case do
      {:ok, %Response{} = result} ->
        Logger.debug(result)
        conn |> send_response(result)

      {:ok, result} ->
        Logger.debug(result)
        conn |> send_response(result |> Response.to_response(%{}, 200))

      {:error, %Response{} = error} ->
        Logger.debug(error)
        conn |> send_response(error)

      {:error, error} ->
        Logger.debug(error)
        conn |> send_response(error |> Response.to_response(%{}, 400))
    end
  end

  defp handler(context) do
    context |> Map.get("_HANDLER")
  end

  defp send_response(conn, %Response{} = response) do
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, response |> response_message())
  end

  defp response_message(%Response{body: body, headers: headers, status_code: status_code}) do
    %{
      Outputs: %{
        res: %{
          headers: headers,
          body: body,
          statusCode: status_code
        }
      },
      Logs: Logger.logs(),
      ReturnValue: body
    }
    |> Jason.encode!()
  end
end
