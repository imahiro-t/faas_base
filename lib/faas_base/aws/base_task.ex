defmodule FaasBase.Aws.BaseTask do
  use Task

  alias FaasBase.Aws.Base

  @doc """
  Start BaseTask.
  """
  def start_link(context) do
    Task.start_link(__MODULE__, :run, [context])
  end

  @doc """
  Call Base.
  """
  def run(context) do
    if context |> Map.has_key?("AWS_LAMBDA_RUNTIME_API") do
      case context |> Base.init() do
        {:ok, context} ->
          Base.loop(context)

        :ok ->
          Base.loop(context)

        _ ->
          :halt
      end
    else
      :halt
    end
  end
end
