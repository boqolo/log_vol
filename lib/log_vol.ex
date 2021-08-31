defmodule LogVol do
  @moduledoc """
  Documentation for `LogVol`, a wrapper around Elixir's
  native `Logger` with volume controls.
  """

  @app :log_vol
  @supported_volumes [
    :very_verbose,
    :verbose,
    :normal,
    :quiet,
    :silent
  ]

  require Logger

  @doc """
  Sets the logging volume for the application. There are
  5 supported log volumes:

      :very_verbose
      :verbose
      :normal
      :quiet
      :silent

  Returns `:ok` if successful, else `{:error, reason}`.

  """
  def set(volume) do
    unless Enum.member?(@supported_volumes, volume) do
      {:error, "Unsupported volume. Try iex> h LogVol.set"}
    else
      Application.put_env(@app, :volume, volume)
    end
  end

  @doc """
  Returns the currently set logging volume for the application.

  ## Examples

      iex> LogVol.volume
      :normal

  """
  def volume do
    Application.fetch_env!(@app, :volume)
  end

  @doc """
  Logs the debug message at the currently set volume.
  If a message is not specified at a volume, nothing
  will be displayed if `debug` is called at that volume.

  ## Usage

  For convenience, `debug/1` can be given a string to log at
  `:normal` volume or a keyword list of strings to log at
  any volume. `debug/2` takes a string to log at `:normal` volume
  and a keyword list of strings to log at other volumes.

  ## Examples

      iex> LogVol.volume
      :normal
      iex> LogVol.debug("normal msg")
      timestamp [debug] normal msg
      :ok
      iex> LogVol.set :verbose
      :ok
      iex> LogVol.debug("normal msg", verbose: "verbose msg")
      :noop
      iex> LogVol.debug(verbose: "verbose msg")
      timestamp [debug] verbose msg
      :ok
      iex> LogVol.debug(very_verbose: "very verbose msg")
      :noop
      iex> LogVol.debug("normal msg")
      :noop

  """
  def debug(string_or_keyword)

  def debug(string) when is_binary(string) do
    string |> debug([])
  end

  def debug(options) when is_list(options) do
    Keyword.get(options, :normal) |> debug(options)
  end

  @doc """
  See docs for `debug/1.`
  """
  def debug(string, options) do
    handle_log(:debug, string, options)
  end

  @doc """
  Logs the info message at the currently set volume.
  If a message is not specified at a volume, nothing
  will be displayed if `info` is called at that volume.

  ## Usage

  For convenience, `info/1` can be given a string to log at
  `:normal` volume or a keyword list of strings to log at
  any volume. `info/2` takes a string to log at `:normal` volume
  and a keyword list of strings to log at other volumes.

  ## Examples

      iex> LogVol.volume
      :normal
      iex> LogVol.info("normal msg")
      timestamp [info] normal msg
      :ok
      iex> LogVol.set :verbose
      :ok
      iex> LogVol.info("normal msg", verbose: "verbose msg")
      :noop
      iex> LogVol.info(verbose: "verbose msg")
      timestamp [info] verbose msg
      :ok
      iex> LogVol.info(very_verbose: "very verbose msg")
      :noop
      iex> LogVol.info("normal msg")
      :noop

  """
  def info(string_or_keyword)

  def info(string) when is_binary(string) do
    string |> info([])
  end

  def info(options) when is_list(options) do
    Keyword.get(options, :normal) |> info(options)
  end

  @doc """
  See docs for `info/1.`
  """
  def info(string, options) do
    handle_log(:info, string, options)
  end

  @doc """
  Logs the warn message at the currently set volume.
  If a message is not specified at a volume, nothing
  will be displayed if `warn` is called at that volume.

  ## Usage

  For convenience, `warn/1` can be given a string to log at
  `:normal` volume or a keyword list of strings to log at
  any volume. `warn/2` takes a string to log at `:normal` volume
  and a keyword list of strings to log at other volumes.

  ## Examples

      iex> LogVol.volume
      :normal
      iex> LogVol.warn("normal msg")
      timestamp [warn] normal msg
      :ok
      iex> LogVol.set :verbose
      :ok
      iex> LogVol.warn("normal msg", verbose: "verbose msg")
      :noop
      iex> LogVol.warn(verbose: "verbose msg")
      timestamp [warn] verbose msg
      :ok
      iex> LogVol.warn(very_verbose: "very verbose msg")
      :noop
      iex> LogVol.warn("normal msg")
      :noop

  """
  def warn(string_or_keyword)

  def warn(string) when is_binary(string) do
    string |> warn([])
  end

  def warn(options) when is_list(options) do
    Keyword.get(options, :normal) |> warn(options)
  end

  @doc """
  See docs for `warn/1.`
  """
  def warn(string, options) do
    handle_log(:warn, string, options)
  end

  @doc """
  Logs the error message at the currently set volume.
  If a message is not specified at a volume, nothing
  will be displayed if `error` is called at that volume.

  ## Usage

  For convenience, `error/1` can be given a string to log at
  `:normal` volume or a keyword list of strings to log at
  any volume. `error/2` takes a string to log at `:normal` volume
  and a keyword list of strings to log at other volumes.

  ## Examples

      iex> LogVol.volume
      :normal
      iex> LogVol.error("normal msg")
      timestamp [error] normal msg
      :ok
      iex> LogVol.set :verbose
      :ok
      iex> LogVol.error("normal msg", verbose: "verbose msg")
      :noop
      iex> LogVol.error(verbose: "verbose msg")
      timestamp [error] verbose msg
      :ok
      iex> LogVol.error(very_verbose: "very verbose msg")
      :noop
      iex> LogVol.error("normal msg")
      :noop

  """
  def error(string_or_keyword)

  def error(string) when is_binary(string) do
    string |> error([])
  end

  def error(options) when is_list(options) do
    Keyword.get(options, :normal) |> error(options)
  end

  @doc """
  See docs for `error/1.`
  """
  def error(string, options) do
    handle_log(:error, string, options)
  end

  defp log_or_ignore(nil, _level) do
    :noop
  end

  defp log_or_ignore(string, level) do
    case level do
      :debug -> Logger.debug(string)
      :info -> Logger.info(string)
      :warn -> Logger.warn(string)
      :error -> Logger.error(string)
      _ -> raise "Log level #{level} isn't supported"
    end
  end

  defp handle_log(level, string, options) do
    case Application.fetch_env!(@app, :volume) do
      :very_verbose ->
        Keyword.get(options, :very_verbose) |> log_or_ignore(level)
      :verbose ->
        Keyword.get(options, :verbose) |> log_or_ignore(level)
      :normal -> string |> log_or_ignore(level)
      :quiet ->
        Keyword.get(options, :quiet) |> log_or_ignore(level)
      _ -> :noop
    end
  end

end
