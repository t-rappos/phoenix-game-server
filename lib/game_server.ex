defmodule Hello.GameServer do
    use GenServer
    @moduledoc """
    Hello keeps the contexts that define your domain
    and business logic.

    Contexts are also responsible for managing your data, regardless
    if it comes from the database, an external API or others.
    """

    #client  
    def start_link do
        IO.puts "start_link"
        GenServer.start_link(__MODULE__, %{}, name: :game_server)
    end

    def get_state do
        GenServer.call(:game_server, :get_state)
    end

    def move_player(player, dx, dy) do
        GenServer.cast(:game_server, {:move_player, player, dx, dy} )
    end

    def set_view_callback(cb) do
        GenServer.call(:game_server, {:set_view_callback, cb})
    end

    #server
    def init(state) do
        IO.puts "init"
        Process.send_after(self(), :trigger, div(1000,20))
        {:ok, state}
    end

    def handle_info(:trigger , state) do
        if Map.has_key?(state, :view_callback) do
            state[:view_callback].(state)
        end
        Process.send_after(self(), :trigger, div(1000,20))
        {:noreply, state}
    end

    def handle_call(:get_state, _from, state) do
        {:reply, state, state}
    end

    def handle_call({:set_view_callback, cb}, _from, state) do
        if Map.has_key?(state, :view_callback) do
            {:reply, state, state}
        else
            state = Map.put_new(state, :view_callback, cb)
            {:reply, state, state}
        end
    end

    #%{
    #   input %{player: [x,y]}
    #   pos %{player: [x,y]}
    #}
    def handle_cast({:move_player, player, dx, dy}, state) do
        if Map.has_key?(state, player) do
            [x,y] = state[player]
            state = Map.replace(state, player, [x+dx,y+dy])
            {:noreply, state}
        else
            state = Map.put_new(state, player, [100,100])
            {:noreply, state}
        end
    end

end