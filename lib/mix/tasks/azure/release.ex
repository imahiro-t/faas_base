defmodule Mix.Tasks.Azure.Release do
  @moduledoc """
  Create files to publish Azure Functions.

  Run this task inside Docker image `mcr.microsoft.com/azure-functions/base:4.22.0`.

  Docker image `erintheblack/elixir-azure-functions-builder:1.10.3` is prepared to build.

  ## How to build

  ```
  $ mkdir -p _build
  $ docker run -d -it --rm --name elx erintheblack/elixir-azure-functions-builder:1.10.3
  $ docker cp lib elx:/tmp
  $ docker cp mix.exs elx:/tmp
  $ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix azure.release ${handle_module} ${method_name} 'get post'"
  $ docker cp elx:/tmp/_azure ./_build
  $ docker stop elx
  ```
  """

  use Mix.Task

  @build_dir "_azure"

  @doc """
  Create files to publish Azure Functions.
  """
  @impl Mix.Task
  def run([handler_module]) do
    app_name = app_name()
    bootstrap = bootstrap(app_name)
    host_json = host_json(app_name)
    local_setting_json = local_setting_json(handler_module)
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
    Mix.Shell.cmd("cp -a ./_build/#{env}/rel/#{app_name} ./#{@build_dir}/", &IO.puts/1)
    File.write("./#{@build_dir}/host.json", host_json)
    File.write("./#{@build_dir}/local.settings.json", local_setting_json)
  end

  def run([handler_module, method_name, method_types]) do
    function_json = function_json(~w/#{method_types}/)
    run([handler_module])
    Mix.Shell.cmd("mkdir -p ./#{@build_dir}/#{method_name}", &IO.puts/1)
    File.write("./#{@build_dir}/#{method_name}/function.json", function_json)
  end

  defp app_name do
    Mix.Project.config() |> Keyword.get(:app) |> to_string
  end

  defp bootstrap(app_name) do
    """
    #!/bin/sh
    set -e
    bin/#{app_name} start
    """
  end

  defp host_json(app_name) do
    """
    {
      "version": "2.0",
      "logging": {
        "applicationInsights": {
          "samplingSettings": {
            "isEnabled": true,
            "excludedTypes": "Request"
          }
        }
      },
      "extensionBundle": {
        "id": "Microsoft.Azure.Functions.ExtensionBundle",
        "version": "[3.*, 4.0.0)"
      },
      "customHandler": {
        "description": {
          "defaultExecutablePath": "#{app_name}/bootstrap",
          "workingDirectory": "#{app_name}",
          "arguments": []
        }
      }
    }
    """
  end

  defp local_setting_json(handler_module) do
    """
    {
      "IsEncrypted": false,
      "Values": {
        "FUNCTIONS_WORKER_RUNTIME": "custom",
        "_HANDLER": "#{handler_module}",
        "LOG_LEVEL": "info"
      }
    }
    """
  end

  defp function_json(method_types) do
    """
    {
      "bindings": [
        {
          "authLevel": "function",
          "type": "httpTrigger",
          "direction": "in",
          "name": "req",
          "methods": #{method_types |> inspect}
        },
        {
          "type": "http",
          "direction": "out",
          "name": "res"
        }
      ]
    }
    """
  end
end
