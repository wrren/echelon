defmodule Echelon.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Echelon.ItemStore, []),
      worker(Echelon.Events, []),
      worker(Echelon.Queue, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end