if Mix.env() == :test do
  defmodule Mix.Tasks.Coveralls.SafeTravis do
    @moduledoc false
    alias Mix.Tasks.Coveralls

    use Mix.Task

    @preferred_cli_env :test
    @shortdoc "A safe `coveralls.travis` variant that doesn't crash on failed upload."

    def run(args) do
      Coveralls.Travis.run(args)
    rescue
      e in ExCoveralls.ReportUploadError ->
        Mix.shell().error("Failed coveralls upload: #{Exception.message(e)}")
    end
  end
end
