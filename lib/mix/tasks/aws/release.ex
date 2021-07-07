defmodule Mix.Tasks.Aws.Release do
  @moduledoc """
  Create zip file for AWS Lamdba with custom runtime.

  Run this task inside Docker image `amazonlinux:2.0.20200722.0`.

  Docker image `erintheblack/elixir-lambda-builder:al2_1.10.4` is prepared to build.

  ## How to build

  ### zip file

  ```
  $ mkdir -p _build
  $ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
  $ docker cp mix.exs elx:/tmp
  $ docker cp lib elx:/tmp
  $ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix aws.release"
  $ docker cp elx:/tmp/_aws ./_build
  $ docker stop elx
  ```

  ### Docker image

  ```
  $ mkdir -p _build
  $ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
  $ docker cp mix.exs elx:/tmp
  $ docker cp lib elx:/tmp
  $ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix aws.release ${handle_module}"
  $ docker cp elx:/tmp/_aws ./_build
  $ docker stop elx
  $ docker build -t ${image_name}:latest ./_build/_aws/
  ```

  ## Lambda setting

  - Set `Module Name` to `handler`.
  - Set Log level to `environment` -> `LOG_LEVEL`
  """

  use Mix.Task

  @build_dir "_aws"

  @doc """
  Create zip file for AWS Lamdba with custom runtime.
  """
  @impl Mix.Task
  def run([handler_module]), do: run_internal(true, handler_module)
  def run(_args), do: run_internal(false, nil)

  defp run_internal(docker?, handler_module) do
    app_name = app_name()
    version = version()
    bootstrap = bootstrap(app_name)
    env = Mix.env()
    Mix.Shell.cmd("rm -f -R ./#{@build_dir}/*", &IO.puts/1)
    Mix.Shell.cmd("mkdir -p ./#{@build_dir}", &IO.puts/1)
    Mix.Shell.cmd("rm -f -R ./_build/#{env}/*", &IO.puts/1)
    Mix.Shell.cmd("MIX_ENV=#{env} mix release --quiet", &IO.puts/1)
    File.write("./_build/#{env}/rel/#{app_name}/bootstrap", bootstrap)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bin/#{app_name}", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/releases/*/elixir", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/erts-*/bin/erl", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bootstrap", &IO.puts/1)

    if docker? do
      Mix.Shell.cmd("mkdir -p ./#{@build_dir}/docker", &IO.puts/1)

      Mix.Shell.cmd(
        "mv -f ./_build/#{env}/rel/#{app_name}/* ./#{@build_dir}/docker/",
        &IO.puts/1
      )

      File.write("./#{@build_dir}/Dockerfile", dockerfile(handler_module))
    else
      Mix.Shell.cmd(
        "cd ./_build/#{env}/rel/#{app_name}; zip #{app_name}-#{version}.zip -r -q *",
        &IO.puts/1
      )

      Mix.Shell.cmd(
        "mv -f ./_build/#{env}/rel/#{app_name}/#{app_name}-#{version}.zip ./#{@build_dir}/",
        &IO.puts/1
      )
    end
  end

  defp app_name do
    Mix.Project.config() |> Keyword.get(:app) |> to_string
  end

  defp version do
    Mix.Project.config() |> Keyword.get(:version)
  end

  defp bootstrap(app_name) do
    """
    #!/bin/sh
    set -euo pipefail
    export HOME=/
    $(bin/#{app_name} start)
    """
  end

  defp dockerfile(handler_module) do
    """
    FROM amazon/aws-lambda-provided:al2.2021.07.05.11

    COPY docker/bootstrap /var/runtime/

    COPY docker/ /var/task/

    CMD [ "#{handler_module}" ]
    """
  end
end
