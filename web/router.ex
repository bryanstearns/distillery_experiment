defmodule DistilleryExperiment.Router do
  use DistilleryExperiment.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DistilleryExperiment do
    pipe_through :api
    get "/*path", VersionController, :index
  end
end
