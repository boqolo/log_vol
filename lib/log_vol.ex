defmodule LogVol do
  @moduledoc """
  Documentation for `LogVol`, a wrapper around Elixir's
  native `Logger` with global volume control.
  """

  @app :log_vol
  @supported_volumes [
    :very_verbose,
    :verbose,
    :normal,
    :quiet,
    :silent
  ]
  @supported_levels [
    :debug,
    :info,
    :warn,
    :error
  ]

  require Logger

  @doc """
  Configures the underlying Elixir `Logger`. This is a wrapper
  for `configure/1` in the `Logger` module and therefore
  takes the same options [found in the docs here](https://hexdocs.pm/logger/master/Logger.html#module-runtime-configuration).
  """
  def configure(options) do
    Logger.configure(options)
  end

  @doc """
  Sets the logging volume for the application. There are
  5 supported log volumes:

      :very_verbose
      :verbose
      :normal
      :quiet
      :silent # all logs will be suppressed

  Returns `:ok` if successful or returns `{:error, reason}`.

  """
  def set(volume) do
    unless Enum.member?(@supported_volumes, volume) do
      {:error,
        "Unsupported volume. Try #{Enum.join(@supported_volumes, ", ")}"}
    else
      Application.put_env(@app, :volume, volume)
    end
  end

  @doc """
  Same as `set/1` except raises if unsuccessful.
  """
  def set!(volume) do
    case set(volume) do
      :ok -> :ok
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Sets the logging level for the application.
  Attempting to log any message with severity less than the given
  level will cause the message to be ignored. This is a
  convenience for `LogVol.configure(level: some_level)`.

  Whereas `configure/1` supports all the options of
  [`Logger.configure/1`](https://hexdocs.pm/logger/master/Logger.html#configure/1), this function only accepts LogVol's
  supported levels along with (per the [docs here](https://hexdocs.pm/logger/master/Logger.html#module-runtime-configuration)):

      :all - all messages will be logged, conceptually identical to :debug
      :none - no messages will be logged at all

  Returns `:ok` if successful or `{:error, reason}` if unsuccessful.

  """
  def set_level(level) do
    valid_levels = @supported_levels ++ [:all, :none]
    unless Enum.member?(valid_levels, level) do
      {:error, "Unsupported level. Try #{Enum.join(valid_levels, ", ")}"}
    else
      Logger.configure(level: level)
    end
  end

  @doc """
  Same as `set_level/1` except raises if unsuccessful.
  """
  def set_level!(level) do
    case set_level(level) do
      :ok -> :ok
      {:error, reason} -> raise reason
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
      timestamp [debug] verbose msg
      :ok
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

  def debug(messages) when is_list(messages) do
    Keyword.get(messages, :normal) |> debug(messages)
  end

  @doc """
  See docs for `debug/1.`
  """
  def debug(string, messages) do
    handle_log(:debug, string, messages)
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
      timestamp [info] verbose msg
      :ok
      iex> LogVol.info(verbose: "verbose msg")
      timestamp [info] verbose msg
      :ok
      iex> LogVol.info(quiet: "quiet msg")
      :noop
      iex> LogVol.info("normal msg")
      :noop

  """
  def info(string_or_keyword)

  def info(string) when is_binary(string) do
    string |> info([])
  end

  def info(messages) when is_list(messages) do
    Keyword.get(messages, :normal) |> info(messages)
  end

  @doc """
  See docs for `info/1.`
  """
  def info(string, messages) do
    handle_log(:info, string, messages)
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
      timestamp [warn] verbose msg
      :ok
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

  def warn(messages) when is_list(messages) do
    Keyword.get(messages, :normal) |> warn(messages)
  end

  @doc """
  See docs for `warn/1.`
  """
  def warn(string, messages) do
    handle_log(:warn, string, messages)
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
      timestamp [error] verbose msg
      :ok
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

  def error(messages) when is_list(messages) do
    Keyword.get(messages, :normal) |> error(messages)
  end

  @doc """
  See docs for `error/1.`
  """
  def error(string, messages) do
    handle_log(:error, string, messages)
  end

  @doc """
  Logs the given messages at the given level, where level is
  an atom from the following list of supported log levels:

      #{Enum.join(@supported_levels, "\n")}

  ## Examples

      iex> LogVol.volume
      :normal
      iex> LogVol.log(:debug, normal: "normal msg") # same as LogVol.debug("normal msg")
      timestamp [debug] normal msg
      :ok
      iex> LogVol.log(:error, quiet: "quiet msg", verbose: "verbose msg")
      :noop

  """
  def log(level, messages) when is_list(messages) do
    handle_log(level, Keyword.get(messages, :normal) , messages)
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

  defp handle_log(level, string, messages) do
    case Application.fetch_env!(@app, :volume) do
      :very_verbose ->
        Keyword.get(messages, :very_verbose) |> log_or_ignore(level)
      :verbose ->
        Keyword.get(messages, :verbose) |> log_or_ignore(level)
      :normal -> string |> log_or_ignore(level)
      :quiet ->
        Keyword.get(messages, :quiet) |> log_or_ignore(level)
      _ -> :noop
    end
  end

end
