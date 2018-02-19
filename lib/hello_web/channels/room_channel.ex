defmodule HelloWeb.RoomChannel do
    use HelloWeb, :channel
    alias HelloWeb.Presence

    def join("room:lobby", _, socket) do
        send self(), :after_join
        {:ok, socket}
    end

    def handle_info(:after_join, socket) do
        Presence.track(socket, socket.assigns.user, %{online_at: :os.system_time(:milli_seconds)})
        push socket, "presence_state", Presence.list(socket)
        {:noreply, socket}
    end

    def handle_in("message:new", message, socket) do
        broadcast! socket, "message:new", %{
            user: socket.assigns.user,
            body: message,
            timestamp: :os.system_time(:milli_seconds)
        }
        {:noreply, socket}
    end

    def handle_in("message:move", message, socket) do
        IO.puts message
        
        case message do
            "w" -> IO.inspect Hello.GameServer.move_player(socket.assigns.user, 0, -1)
            "s" -> IO.inspect Hello.GameServer.move_player(socket.assigns.user, 0, 1)
            "a" -> IO.inspect Hello.GameServer.move_player(socket.assigns.user, -1, 0)
            "d" -> IO.inspect Hello.GameServer.move_player(socket.assigns.user, 1, 0)
        end
        {:noreply, socket}
    end

    def handle_in("message:fire", message, socket) do
        IO.puts message
        IO.inspect Hello.GameServer.get_state
        {:noreply, socket}
    end
end