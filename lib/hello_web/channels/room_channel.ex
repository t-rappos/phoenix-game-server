defmodule HelloWeb.RoomChannel do
    use HelloWeb, :channel
    alias HelloWeb.Presence

    def broadcast_view(state) do
        # IO.puts "broadcast view"
        # IO.inspect users
        users = :maps.filter((fn k, _ -> is_bitstring(k) end), state)
        # IO.inspect users
        HelloWeb.Endpoint.broadcast_from! self(), "room:lobby", "message:view", %{ data: users}
    end

    def join("room:lobby", _, socket) do
        send self(), :after_join
        Hello.GameServer.set_view_callback(&__MODULE__.broadcast_view/1) #TODO: only do this once at startup
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

    def handle_in("message:keydown", message, socket) do
        case message do
            "w" -> Hello.GameServer.move_player(socket.assigns.user, 0, -1)
            "s" -> Hello.GameServer.move_player(socket.assigns.user, 0, 1)
            "a" -> Hello.GameServer.move_player(socket.assigns.user, -1, 0)
            "d" -> Hello.GameServer.move_player(socket.assigns.user, 1, 0)
        end
        {:noreply, socket}
    end

    def handle_in("message:keyup", message, socket) do
        Hello.GameServer.move_player(socket.assigns.user, 0, 0)
        {:noreply, socket}
    end

    def handle_in("message:fire", message, socket) do
        # IO.puts message
        # IO.inspect Hello.GameServer.get_state
        {:noreply, socket}
    end

    def handle_in(msg_type, message, socket) do
         IO.puts "invalid message " <> msg_type <> " with content " <> message
         {:noreply, socket}
    end
end