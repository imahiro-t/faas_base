defmodule Mix.Tasks.Ibm.Release do
  @moduledoc """
  Create zip file for IBM Functions with custom runtime.

  Run this task inside Docker image `elixir:1.10.4-slim`.

  ## How to build

  ```
  $ mkdir -p _build
  $ docker run -d -it --rm --name elx erintheblack/elixir-ibm-functions-builder:1.10.4
  $ docker cp lib elx:/tmp
  $ docker cp mix.exs elx:/tmp
  $ docker exec elx /bin/sh -c "mix deps.get; MIX_ENV=prod mix ibm.release ${handle_module}"
  $ docker cp elx:/tmp/_ibm ./_build
  $ docker stop elx
  ```
  """

  use Mix.Task

  @build_dir "_ibm"

  @doc """
  Create zip file for IBM functions with custom runtime.
  """
  @impl Mix.Task
  def run([handler_module]) do
    app_name = app_name()
    version = version()
    bootstrap = bootstrap(app_name, handler_module)
    env = Mix.env()
    Mix.Shell.cmd("rm -f -R ./#{@build_dir}/*", &IO.puts/1)
    Mix.Shell.cmd("mkdir -p ./#{@build_dir}", &IO.puts/1)
    Mix.Shell.cmd("rm -f -R ./_build/#{env}/*", &IO.puts/1)
    Mix.Shell.cmd("MIX_ENV=#{env} mix release --quiet", &IO.puts/1)
    File.write("./_build/#{env}/rel/#{app_name}/exec", bootstrap)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/exec", &IO.puts/1)

    Mix.Shell.cmd(
      "cd ./_build/#{env}/rel/#{app_name}; zip #{app_name}-#{version}.zip -r -q *",
      &IO.puts/1
    )

    Mix.Shell.cmd(
      "mv -f ./_build/#{env}/rel/#{app_name}/#{app_name}-#{version}.zip ./#{@build_dir}/",
      &IO.puts/1
    )
  end

  defp app_name do
    Mix.Project.config() |> Keyword.get(:app) |> to_string
  end

  defp version do
    Mix.Project.config() |> Keyword.get(:version)
  end

  defp bootstrap(app_name, handler_module) do
    """
    #!/bin/sh
    set -e
    export ___EVENT=$1
    chmod 755 bin/#{app_name}
    chmod 755 releases/*/elixir
    chmod 755 erts-*/bin/*
    exec "bin/#{app_name}" "eval" "#{handler_module}.start"
    """
  end
end
