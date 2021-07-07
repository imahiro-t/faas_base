defmodule FaasBase.Azure.Application do
  use Application

  alias FaasBase.Azure.Logger
  alias FaasBase.Azure.Base

  def start(_type, _args) do
    context = System.get_env()
    port = context |> Map.get("FUNCTIONS_CUSTOMHANDLER_PORT", "4444") |> String.to_integer()
    idle_timeout = context |> Map.get("IDLE_TIMEOUT", "300000") |> String.to_integer()

    children = [
      {Logger, context |> Map.get("LOG_LEVEL", "INFO") |> String.downcase() |> String.to_atom()},
      {FaasBase.Logger, Logger},
      {Plug.Cowboy,
       scheme: :http,
       plug: Base,
       options: [port: port, protocol_options: [idle_timeout: idle_timeout]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end
end
