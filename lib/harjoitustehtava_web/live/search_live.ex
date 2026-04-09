defmodule HarjoitustehtavaWeb.SearchLive do
  use HarjoitustehtavaWeb, :live_view
  alias Harjoitustehtava.Search

  def mount(_params, _session, socket) do
    {results, total_pages, error} = fetch_results("", 1)
    {:ok, assign(socket, results: results, query: "", page: 1, total_pages: total_pages, expanded_id: nil, error: error)}
  end

  # hakee hakutulokset Search.list_domains funktiolla ja käsittelee mahdolliset virheet
  defp fetch_results(query, page) do
    case Search.list_domains(query, page) do
      {:ok, results, total_pages} -> {results, total_pages, nil}
      {:error, message} -> {[], 1, message}
    end
  end

  # jos datetime on nil, näytä viivaviivan tilalla
  defp format_datetime(nil), do: "-"

  # datetime muotoon DD-MM-YYYY HH:MM
  defp format_datetime(%DateTime{} = dt) do
    Calendar.strftime(dt, "%d-%m-%Y %H:%M")
  end

    # Käsittelee tekstinhaun: kun käyttäjä kirjoittaa, hypätään aina takaisin sivulle 1
  def handle_event("search", %{"q" => query}, socket) do
    {results, total_pages, error} = fetch_results(query, 1)
    {:noreply, assign(socket, results: results, query: query, page: 1, total_pages: total_pages, expanded_id: nil, error: error)}
  end

  # Avaa/sulje rivin tiedot
  def handle_event("toggle-row", %{"id" => id}, socket) do
    id = String.to_integer(id)

    new_id = if socket.assigns.expanded_id == id, do: nil, else: id
    {:noreply, assign(socket, expanded_id: new_id)}
  end

  # lisätään sivu-laskuriin 1
  def handle_event("next-page", _params, socket) do
    new_page = socket.assigns.page + 1

    {results, total_pages, error} = fetch_results(socket.assigns.query, new_page)
    {:noreply, assign(socket, results: results, page: new_page, total_pages: total_pages, error: error)}
  end

  # vähennetään 1 sivu mutta varmistetaan ettei mennä alle ykkösen
  def handle_event("prev-page", _params, socket) do
    new_page = max(socket.assigns.page - 1, 1)

    {results, total_pages, error} = fetch_results(socket.assigns.query, new_page)
    {:noreply, assign(socket, results: results, page: new_page, total_pages: total_pages, error: error)}
  end


  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
    <div class="p-8 max-w-5xl mx-auto font-sans">
      <h1 class="text-3xl font-bold mb-6 text-gray-800 items-center justify-center text-center">Domain Haku</h1>

      <form phx-change="search" class="mb-6">
        <input type="text" name="q" value={@query} placeholder="Hae domainia..."
               class="w-full p-4 border border-black rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 outline-none"
               autocomplete="off" />
      </form>

      <%= if @error do %>
        <div class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
          {"Virhe: #{@error}"}
        </div>
      <% end %>

      <%= if @results == [] and is_nil(@error) do %>
        <div class="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg text-yellow-700 text-sm">
          Ei hakutuloksia.
        </div>
      <% end %>

      <div class="bg-white shadow rounded-lg overflow-hidden">
        <table class="w-full text-left border-separate border-spacing-0 table-fixed">
          <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
            <tr>
              <th class="p-4 border w-[35%] rounded-tl-lg">Domain</th>
              <th class="p-4 border-t border-b border-r w-[15%]">Reason</th>
              <th class="p-4 border-t border-b border-r w-[30%]">Blacklist ID</th>
              <th class="p-4 border w-[20%] rounded-tr-lg border-l-0">Created</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <%= for entry <- @results do %>
              <tr phx-click="toggle-row" phx-value-id={entry.id} class="hover:bg-blue-50 transition cursor-pointer">
                <td class="p-4 font-medium text-blue-900 truncate">{entry.readable_entry}</td>
                <td class="p-4 text-sm text-gray-600 truncate">{entry.reason}</td>
                <td class="p-4 text-sm text-gray-500 truncate">{entry.blacklist_id}</td>
                <td class="p-4 text-sm text-gray-500 truncate">{format_datetime(entry.created)}</td>
              </tr>
              <%= if @expanded_id == entry.id do %>
                <tr class="bg-gray-50">
                  <td colspan="4" class="p-6">
                    <div class="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <span class="font-semibold text-gray-700">ID:</span>
                        <span class="ml-2 text-gray-600">{entry.id}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">List Entry:</span>
                        <span class="ml-2 text-gray-600">{entry.list_entry}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Readable Entry:</span>
                        <span class="ml-2 text-gray-600">{entry.readable_entry}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Public Comment:</span>
                        <span class="ml-2 text-gray-600">{entry.public_comment}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Notes:</span>
                        <span class="ml-2 text-gray-600">{entry.notes}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Created:</span>
                        <span class="ml-2 text-gray-600">{format_datetime(entry.created)}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Modified:</span>
                        <span class="ml-2 text-gray-600">{format_datetime(entry.modified)}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Blacklist ID:</span>
                        <span class="ml-2 text-gray-600">{entry.blacklist_id}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Public Review:</span>
                        <span class="ml-2 text-gray-600">{entry.public_review}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Review Status:</span>
                        <span class="ml-2 text-gray-600">{entry.review_status}</span>
                      </div>
                      <div>
                        <span class="font-semibold text-gray-700">Reason:</span>
                        <span class="ml-2 text-gray-600">{entry.reason}</span>
                      </div>
                    </div>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <div class="mt-6 flex items-center justify-between border-t pt-4">
        <button
          phx-click="prev-page"
          disabled={@page <= 1}
          class="px-6 py-2 bg-blue-600 text-white rounded-md disabled:bg-gray-300 disabled:cursor-not-allowed hover:bg-blue-700 transition">
          &larr; Edellinen
        </button>

        <div class="text-gray-600 font-medium">
          Sivu <span class="text-blue-600"><%= @page %></span> / <span class="text-blue-600"><%= @total_pages %></span>
        </div>

        <button
          phx-click="next-page"
          disabled={@page >= @total_pages}
          class="px-6 py-2 bg-blue-600 text-white rounded-md disabled:bg-gray-300 disabled:cursor-not-allowed hover:bg-blue-700 transition">
          Seuraava &rarr;
        </button>
      </div>
    </div>
    </Layouts.app>
    """
  end
end
