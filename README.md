# LogVol

Is your system too quiet or too loud? Whether you want
your code to speak up or shut up, control the volume of
logs with LogVol, a library for increased logging resolution.

LogVol is a simple wrapper around Elixir's native `Logger` module. 
Therefore, it has no other dependencies. Its API is also designed
to mirror that of the native `Logger` so that it can be used as a
drop in replacement in any project.

[Elixir's Logger](https://hexdocs.pm/logger/master/Logger.html#content) is
great. It has [controls](https://hexdocs.pm/logger/master/Logger.html#module-runtime-configuration) 
for limiting output logs by level/severity (`debug`, `info`, `warn`, `error`, etc.). However,
when you want to specify which logs to output and suppress within a log level, there isn't a standard solution,
save for checking `dev` or `prod` environments, or, writing and deleting logs over and over when you want more
details or less terminal clutter.

LogVol aims to provide an intuitive interface for logging with more resolution across the project.

## Usage

There are currently 5 supported log volumes:

```elixir
  :very_verbose
  :verbose
  :normal
  :quiet
  :silent
```
      
Set `LogVol`'s global volume at runtime with `LogVol.set/1`, like so: 

```elixir
LogVol.set :verbose
```
    
Write a log in your code like so:

```elixir
def foo(bar) do 
  bee = Enum.to_list(1..10)
  bum = Enum.random(bee)
  boo = :rand.uniform(5)
  LogVol.debug(
    "in foo(), got #{bar}", # message at :normal volume
    very_verbose: "in foo():\ngot #{bar},\nbum --> #{bum},\nboo --> #{boo}",
    verbose: "in foo(), got #{bar}, boo: #{boo}",
    quiet: "foo(#{bar})"
  )
  bar + bum * boo
end
```

A message does not have to be specified for all volumes. 

```elixir
def foo(bar) do 
  # ...
  LogVol.debug(verbose: "in foo(), got #{bar}, boo: #{boo}")
  # ...
end
```

More examples and details can be found at the official documentation:
[https://hexdocs.pm/log_vol](https://hexdocs.pm/log_vol).

#### Personal TODO
1. add `typespecs` for module functions
2. Better docs?
3. Formatter
4. full Logger api support

## Installation

The package can be installed
by adding `log_vol` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:log_vol, "~> 0.0.2"}
  ]
end
```

