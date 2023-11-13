defmodule Tucan.Axes do
  @moduledoc """
  Utilities for configuring plot axes.
  """
  alias Tucan.Utils

  @type axis :: :x | :y

  @doc """
  Sets the _x-axis_ and _y-axis_ titles at once.
  """
  @spec set_xy_titles(vl :: VegaLite.t(), x_title :: String.t(), y_title :: String.t()) ::
          VegaLite.t()
  def set_xy_titles(vl, x_title, y_title) do
    vl
    |> set_x_title(x_title)
    |> set_y_title(y_title)
  end

  @doc """
  Sets the x axis title.
  """
  @spec set_x_title(vl :: VegaLite.t(), title :: String.t()) :: VegaLite.t()
  def set_x_title(vl, title) when is_struct(vl, VegaLite) and is_binary(title) do
    set_title(vl, :x, title)
  end

  @doc """
  Sets the y axis title.
  """
  @spec set_y_title(vl :: VegaLite.t(), title :: String.t()) :: VegaLite.t()
  def set_y_title(vl, title) when is_struct(vl, VegaLite) and is_binary(title) do
    set_title(vl, :y, title)
  end

  @doc """
  Set the title of the given `axis`.
  """
  @spec set_title(vl :: VegaLite.t(), axis :: axis(), title :: String.t()) :: VegaLite.t()
  def set_title(vl, axis, title) do
    put_options(vl, axis, title: title)
  end

  @type orient :: :bottom | :top | :left | :right

  @doc """
  Sets the orientation for the given axis.

  Valid values for `orient` are:

  * `:top`, `:bottom` for the x axis
  * `:left`, `:right` for the y axis

  ## Examples

  ```tucan
  Tucan.scatter(:iris, "petal_width", "petal_length")
  |> Tucan.Axes.set_orientation(:x, :top)
  |> Tucan.Axes.set_orientation(:y, :right)
  ```
  """
  @spec set_orientation(vl :: VegaLite.t(), axis :: axis(), orient :: orient()) :: VegaLite.t()
  def set_orientation(vl, axis, orientation) do
    cond do
      axis not in [:x, :y] ->
        raise ArgumentError, "you can only set orientation for :x, :y axes, got: #{inspect(axis)}"

      axis == :x and orientation not in [:bottom, :top] ->
        raise ArgumentError,
              "you can only set :bottom or :top orientation for :x axis, " <>
                "got: #{inspect(orientation)}"

      axis == :y and orientation not in [:left, :right] ->
        raise ArgumentError,
              "you can only set :left or :right orientation for :y axis, " <>
                "got: #{inspect(orientation)}"

      true ->
        put_options(vl, axis, orient: orientation)
    end
  end

  @doc """
  Enables or disables both axes (`x`, `y`) at once.

  See also `set_enabled/3`
  """
  @spec set_enabled(vl :: VegaLite.t(), enabled :: boolean()) :: VegaLite.t()
  def set_enabled(vl, enabled) do
    vl
    |> set_enabled(:x, enabled)
    |> set_enabled(:y, enabled)
  end

  @doc """
  Enables or disables the given axis.

  Notice that axes are enabled by default.

  ## Examples

  ```tucan
  Tucan.scatter(:iris, "petal_width", "petal_length")
  |> Tucan.Axes.set_enabled(:x, false)
  |> Tucan.Axes.set_enabled(:y, false)
  ```
  """
  @spec set_enabled(vl :: VegaLite.t(), axis :: axis(), enabled :: boolean()) :: VegaLite.t()
  def set_enabled(vl, axis, true) when is_struct(vl, VegaLite) do
    Utils.put_encoding_options(vl, axis, axis: [])
  end

  def set_enabled(vl, axis, false) when is_struct(vl, VegaLite) do
    Utils.put_encoding_options(vl, axis, axis: nil)
  end

  @doc """
  Sets an arbitrary set of options to the given `encoding` axis object.

  Notice that no validation is performed, any option set will be merged with
  the existing `axis` options of the given `encoding`.

  An `ArgumentError` is raised if the given encoding channel is not defined.
  """
  @spec put_options(vl :: VegaLite.t(), encoding :: atom(), options :: keyword()) ::
          VegaLite.t()
  def put_options(vl, encoding, options) do
    Utils.put_encoding_options(vl, encoding, axis: options)
  end
end
