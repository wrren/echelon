defmodule Echelon.Queue do
  @moduledoc """
  This GenServer contains any items queued on this node
  """
  use GenServer
  
  alias Echelon.{Queue, ItemStore}

  defstruct items:  :queue.new, 
            opts:   [], 
            table:  :undefined

  @doc """
  Start the Queue GenServer
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Initialize the Queue state
  """
  def init(opts) do
    table = case ItemStore.table do
              :no_table ->
                :ets.new(:queue_backup, [{:heir, Process.whereis(ItemStore), :ok}, :protected])
              t ->
                t
            end
    
    items   = table
              |> :ets.tab2list
              |> Enum.sort(fn {id1, _}, {id2, _} -> id1 < id2 end)
              |> Enum.reduce(:queue.new, fn({_id, item}, q) -> :queue.in(item, q) end)

    {:ok, %Queue{items: items, opts: opts, table: table}} 
  end

  @doc """
  Push an item onto the queue
  """
  @spec push(any) :: :ok
  def push(item) do
    GenServer.call(__MODULE__, {:push, item})
  end

  @doc """
  Pop an item off the head of the queue
  """
  @spec pop :: {:value, any} | :empty
  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  @doc """
  Handle a call to push a new item onto the queue
  """
  def handle_call({:push, item}, _from, %Queue{items: items, table: table} = state) do
    id = :ets.update_counter(table, :next_id, 1, 0)
    :ets.insert(table, {id, item})
    {:reply, :ok, %{state | items: :queue.in({id, item}, items)}}
  end

  @doc """
  Handle a call to pop an item off the head of the queue
  """
  def handle_call(:pop, _from, %Queue{items: items, table: table} = state) do
    case :queue.out(items) do
      {{:value, {id, item}}, new_items} ->
        :ets.delete(table, id)
        {:reply, {:value, item}, %{state | items: new_items}}
      {:empty, _items} ->
        {:reply, :empty, state}
    end
  end

  @doc """
  Handle a message indicating that the ETS table held by the ItemStore is 
  being transferred to this Queue
  """
  def handle_info({:'ETS-TRANSFER', table, _from, _heir_data}, state) do
    {:noreply, %{state | table: table}}
  end
end