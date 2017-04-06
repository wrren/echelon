defmodule Echelon.ItemStore do
  @moduledoc """
  Acts as a safe storage area for Queue items on the local node. The
  local Queue process designates the ItemStore as a secondary parent 
  for its ETS table so that, in the event that the Events GenEvent 
  fails and the Queue must be restarted, it can retrieve its items
  from the ItemStore
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, :no_table}
  end

  @doc """
  Gets the ETS table ID of the table that was transferred to the item store
  if the transfer occurred
  """
  def table do
    GenServer.call(__MODULE__, :table)
  end

  @doc """
  Handle a call to transfer table ownership back to the calling process.
  """
  def handle_call(:table, from, :no_table) do
    {:reply, :no_table, :no_table}
  end

  def handle_call(:table, from, table) do
    :ets.give_away(table, from, :ok)
    {:reply, {:ok, table}, :no_table}
  end

  @doc """
  Handle a message indicating that the ETS table owned by the Queue on this 
  node is being transferred to use due to the Queue process' death.
  """
  def handle_info({:'ETS-TRANSFER', table, _from, _heir_data}, _state) do
    {:noreply, table}
  end
end