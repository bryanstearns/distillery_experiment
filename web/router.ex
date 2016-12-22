defmodule DistilleryExperiment.Router do
  use DistilleryExperiment.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DistilleryExperiment do
    pipe_through :api
  end
end
