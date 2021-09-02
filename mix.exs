defmodule LogVol.MixProject do
  use Mix.Project

  def project do
    [
      app: :log_vol,
      version: "0.0.2",
      elixir: "~> 1.12",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    Is your system too quiet or too loud? Whether you want
    your code to speak up or shut up, control the volume of
    logs with LogVol, a library for increased logging resolution.
    """
  end

  defp package do
  [
   files: ["lib", "mix.exs", "README.md"],
   maintainers: ["Rayyan Abdi"],
   licenses: ["GNU GPL 3.0"],
   links: %{"GitHub" => "https://github.com/boqolo/log_vol",
            "Docs" => "http://hexdocs.pm/log_vol/"}
   ]
 end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:earmark, ">= 1.4.14", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
