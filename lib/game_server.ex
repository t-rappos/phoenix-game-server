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
        IO.puts "get_state"
        GenServer.call(:game_server, :get_state)
    end

    def move_player(player, dx, dy) do
        IO.puts "move_player"
        GenServer.cast(:game_server, {:move_player, player, dx, dy} )
    end

    #server
    def init(state) do 
        IO.puts "init"
        {:ok, state}
    end

    def handle_call(:get_state, _from, state) do
        IO.puts "handle_call"
        {:reply, state, state}
    end

    def handle_cast({:move_player, player, dx, dy}, state) do
        IO.puts "handle_cast"
        if Map.has_key?(state, player) do
            IO.puts "found key for " <> player
            IO.inspect [dx,dy]
            IO.inspect state
            [x,y] = state[player]
            state = Map.replace(state, player, [x+dx,y+dy])
            IO.inspect state
            {:noreply, state}
        else
            IO.puts "couldnt find key for " <> player
            state = Map.put_new(state, player, [100,100])
            IO.inspect state
            {:noreply, state}
        end
    end

end