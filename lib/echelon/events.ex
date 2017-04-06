defmodule Echelon.Events do
  @moduledoc """
  Simple interface for starting the queue GenEvent and 
  for sending event notifications
  """

  @name {:global, __MODULE__}

  @doc """
  Start the Events GenEvent manager
  """
  def start_link do
    GenEvent.start_link(name: @name)
  end

  @doc """
  Notifies listeners that the specified item has been added to the
  Queue whose pid matches 'queue_pid'
  """
  def new_item(item, queue_pid) do
    GenEvent.notify(@name, {:new_item, item, queue_pid})
  end
end