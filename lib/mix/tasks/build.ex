if Mix.env() == :test do
  defmodule Mix.Tasks.Yamlixir.Build do
    @moduledoc false
    import IO.ANSI, only: [cyan: 0, bright: 0]

    use Mix.Task

    @preferred_cli_env :test
    @required_elixir_version "1.8"

    @spec run(argv :: [String.t()]) :: nil
    def run(argv) do
      {opts, argv, _} = OptionParser.parse(argv, switches: [format: :boolean])
      if Keyword.get(opts, :format, true), do: run_formatter(argv)
      do_run(argv)
    end

    @spec run_formatter([binary()]) :: any()
    def run_formatter(argv) do
      if System.version() >= @required_elixir_version do
        Mix.shell().info("#{cyan()}#{bright()}Running formatter")
        Mix.Task.run("format", ["--check-equivalent" | argv])
      else
        raise RuntimeError, """
        #{bright()}Elixir version must be >= #{@required_elixir_version} for proper formatting. Detected version:

            * #{System.version()}

        Please upgrade to Elixir #{@required_elixir_version} or above to continue development on this project.
        """
      end
    end

    @spec do_run([binary()]) :: nil
    def do_run(argv) do
      Mix.Task.run("coveralls.html", argv)
      Mix.Task.run("inch", argv)
      Mix.Task.run("docs", argv)
      Mix.Task.run("credo", ["--strict" | argv])
    end
  end
end
