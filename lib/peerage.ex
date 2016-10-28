defmodule Peerage do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    cluster_poller = Application.fetch_env!(:peerage, :via)

    # Define workers and child supervisors to be supervised
    children = [
      worker(cluster_poller, [])
    ]

    opts = [strategy: :one_for_one, name: Peerage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
