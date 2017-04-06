defmodule Echelon do
  @moduledoc """
  Exposes the queueing interface
  """
  use Application

  def start(_type, _args) do
    Echelon.Supervisor.start_link
  end

  
end
