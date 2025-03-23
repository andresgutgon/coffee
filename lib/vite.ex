defmodule Vite do
  @moduledoc false

  # Provide "constants" as functions so that inner modules can refer to them.
  def manifest_file, do: "priv/static/assets/vite_manifest.json"
  def cache_key, do: {:vite, "vite_manifest"}
  def default_env, do: :dev
  def endpoint, do: PingcrmWeb.Endpoint

  defmodule PhxManifestReader do
    @moduledoc """
    Reads Vite manifest data either from a built digest (for prod) or directly from disk (for non-prod).
    """
    require Logger
    alias Vite

    @spec read() :: map()
    def read do
      case :persistent_term.get(Vite.cache_key(), nil) do
        nil ->
          manifest = do_read(current_env())
          :persistent_term.put(Vite.cache_key(), manifest)
          manifest

        manifest ->
          manifest
      end
    end

    @spec current_env() :: atom()
    def current_env do
      Application.get_env(:pingcrm, :env, Vite.default_env())
    end

    @spec do_read(atom()) :: map()
    defp do_read(:prod), do: read_prod_manifest()
    defp do_read(_env), do: read_file_manifest(Vite.manifest_file())

    # Reads the manifest file from the built static digest in production.
    @spec read_prod_manifest() :: map()
    defp read_prod_manifest do
      # In production the manifest location is picked up from the parent's manifest_file/0.

      {otp_app, relative_path} = {Vite.endpoint().config(:otp_app), Vite.manifest_file()}

      manifest_path = Application.app_dir(otp_app, relative_path)

      with true <- File.exists?(manifest_path),
           {:ok, content} <- File.read(manifest_path),
           {:ok, decoded} <- Phoenix.json_library().decode(content) do
        decoded
      else
        _ ->
          Logger.error(
            "Could not find static manifest at #{inspect(manifest_path)}. " <>
              "Run \"mix phx.digest\" after building your static files " <>
              "or remove the configuration from \"config/prod.exs\"."
          )

          %{}
      end
    end

    # Reads the manifest from a file for non-production environments.
    @spec read_file_manifest(String.t()) :: map()
    defp read_file_manifest(path) do
      path
      |> File.read!()
      |> Jason.decode!()
    end
  end

  defmodule Manifest do
    @moduledoc """
    Retrieves Vite's generated file references.
    """
    alias Vite.PhxManifestReader

    @app_file "js/app.tsx"

    @spec read() :: map()
    def read, do: PhxManifestReader.read()

    @spec js_bundle() :: String.t()
    def js_bundle, do: get_file(@app_file)

    @spec css_files() :: [String.t()]
    def css_files do
      read()
      |> get_in([@app_file, "css"])
      |> List.wrap()
      |> Enum.map(&prepend_slash/1)
    end

    @spec get_file(String.t()) :: String.t()
    def get_file(file) do
      read()
      |> get_in([file, "file"])
      |> prepend_slash()
    end

    defp prepend_slash(nil), do: ""
    defp prepend_slash(path) when is_binary(path), do: "/" <> path
    defp prepend_slash(_), do: ""
  end
end
