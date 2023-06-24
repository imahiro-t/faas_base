# FaasBase

Base library to create FaaS application.

## Installation

The package can be installed by adding `faas_base` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:faas_base, "~> 1.1.1"}
  ]
end
```

## Basic Usage

### AWS Lambda

1. Add module to your list of application in `mix.exs`:

```elixir
def application do
  [
    mod: {FaasBase.Aws.Application, []}
  ]
end
```

2. Create AWS Lambda module. Implement handle(request, event, context) function.

```elixir
defmodule Upcase do
  use FaasBase, service: :aws
  alias FaasBase.Logger
  alias FaasBase.Aws.Request
  alias FaasBase.Aws.Response
  @impl FaasBase
  def init(context) do
    # call back one time
    {:ok, context}
  end
  @impl FaasBase
  def handle(%Request{body: body} = request, event, context) do
    Logger.info(request)
    Logger.info(event)
    Logger.info(context)
    {:ok, Response.to_response(body |> String.upcase, %{}, 200)}
  end
end
```

3a. Create zip file for AWS Lambda.

```
$ mkdir -p _build
$ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
$ docker cp mix.exs elx:/tmp
$ docker cp lib elx:/tmp
$ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix aws.release"
$ docker cp elx:/tmp/_aws ./_build
$ docker stop elx
```

4a. Upload zip file and set configuration.
- Set `Module Name` to `handler`.
- Set Log level to `environment` -> `LOG_LEVEL`
  - `debug`, `info`, `warn`, `error`

3b. Create Docker image for AWS Lambda.

```
$ handle_module=Upcase
$ image_name=upcase
$ mkdir -p _build
$ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
$ docker cp mix.exs elx:/tmp
$ docker cp lib elx:/tmp
$ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix aws.release ${handle_module}"
$ docker cp elx:/tmp/_aws ./_build
$ docker stop elx
$ docker build -t ${image_name}:latest ./_build/_aws/
```

4b. Register Docker image and set configuration.
- Set Log level to `environment` -> `LOG_LEVEL`
  - `debug`, `info`, `warn`, `error`

### Azure Functions

1. Add module to your list of application in `mix.exs`:

```elixir
def application do
  [
    mod: {FaasBase.Azure.Application, []}
  ]
end
```

2. Create Azure Functions handler module. Implement handle(request, event, context) function.

```elixir
defmodule Upcase do
  use FaasBase, service: :azure
  alias FaasBase.Logger
  alias FaasBase.Azure.Request
  alias FaasBase.Azure.Response
  @impl FaasBase
  def init(_context) do
    # call back one time
    :ok
  end
  @impl FaasBase
  def handle(%Request{body: body} = request, event, context) do
    Logger.info(request)
    Logger.info(event)
    Logger.info(context)
    {:ok, Response.to_response(body |> String.upcase, %{}, 200)}
  end
end
```

3. Create files for Azure Functions.

```
$ handle_module=Upcase
$ method_name=upcase
$ mkdir -p _build
$ docker run -d -it --rm --name elx erintheblack/elixir-azure-functions-builder:1.10.3
$ docker cp lib elx:/tmp
$ docker cp mix.exs elx:/tmp
$ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix azure.release ${handle_module} ${method_name} 'get post'"
$ docker cp elx:/tmp/_azure ./_build
$ docker stop elx
```

4. Publish.

```
$ cd ./_build/_azure
$ func azure functionapp publish ${functionName} --publish-local-settings --overwrite-settings
```

### IBM Functions

1. Create IBM Functions handler module. Implement handle(request, event, context) function.

```elixir
defmodule Upcase do
  use FaasBase, service: :ibm
  alias FaasBase.Logger
  alias FaasBase.Ibm.Request
  alias FaasBase.Ibm.Response
  @impl FaasBase
  def init(context) do
    {:ok, context}
  end
  @impl FaasBase
  def handle(%Request{body: body} = request, event, context) do
    Logger.info(request)
    Logger.info(event)
    Logger.info(context)
    {:ok, Response.to_response(body |> String.upcase, %{}, 200)}
  end
end
```

2. Create zip file for IBM Functions.

```
$ handle_module=Upcase
$ mkdir -p _build
$ docker run -d -it --rm --name elx erintheblack/elixir-ibm-functions-builder:1.10.4
$ docker cp lib elx:/tmp
$ docker cp mix.exs elx:/tmp
$ docker exec elx /bin/sh -c "mix deps.get; MIX_ENV=prod mix ibm.release ${handle_module}"
$ docker cp elx:/tmp/_ibm ./_build
$ docker stop elx
```

3. Publish.

```
$ cd ./_build/_azure
$ ibmcloud fn action create upcase upcase-0.1.0.zip --native --web true --param LOG_LEVEL info
```


The docs can be found at [https://hexdocs.pm/faas_base](https://hexdocs.pm/faas_base).
