defmodule Tucan.Themes.Helpers do
  @moduledoc false

  # helper functions for loading themes from the themes top level folder

  @themes_dir Path.expand("../../../themes", __DIR__)

  @doc false
  @spec load_themes() :: keyword()
  def load_themes do
    themes_pattern = Path.join(@themes_dir, "*.exs")

    Path.wildcard(themes_pattern)
    |> Enum.map(&load_theme/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn theme -> {theme[:name], theme} end)
  end

  defp load_theme(path) do
    with {:ok, theme} <- eval_theme(path),
         {:ok, theme} <- validate_theme(theme) do
      theme
    else
      {:error, reason} ->
        IO.warn(reason)
        nil
    end
  end

  defp eval_theme(path) do
    {theme, _bindings} = Code.eval_file(path)
    {:ok, theme}
  rescue
    _e -> {:error, "failed to load theme from #{path}"}
  end

  defp validate_theme(theme) do
    case Keyword.validate(theme, [:theme, :name, :doc, :source]) do
      {:ok, theme} ->
        {:ok, theme}

      {:error, invalid} ->
        {:error, "the following theme attributes are not supported: #{inspect(invalid)}"}
    end
  end

  @doc false
  @spec docs(themes :: keyword(), example :: binary()) :: binary()
  def docs(themes, example),
    do: Enum.map_join(themes, "\n\n", fn {_name, opts} -> theme_docs(opts, example) end)

  defp theme_docs(opts, example) do
    theme_name =
      case opts[:source] do
        nil -> inspect(opts[:name])
        source -> "[#{opts[:name]}](#{source})"
      end

    {%VegaLite{} = vl, _} = Code.eval_string(example, [], __ENV__)

    spec =
      vl
      |> VegaLite.config(opts[:theme])
      |> VegaLite.config(legend: [disable: true])
      |> VegaLite.resolve(:scale, color: :independent)
      |> VegaLite.to_spec()
      |> Jason.encode!()

    """
    * #{theme_name} - #{opts[:doc]}

    ```vega-lite
    #{spec}
    ```
    """
  end
end
