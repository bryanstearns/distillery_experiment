defmodule DistilleryExperiment.VersionController do
  use DistilleryExperiment.Web, :controller

  def index(conn, _params) do
    {:ok, version} = :application.get_key(:distillery_experiment, :vsn)
    text conn, to_string(version) <> "\n"
  end
end
