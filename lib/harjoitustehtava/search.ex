defmodule Harjoitustehtava.Search do
  import Ecto.Query # ottaa Ecto.Query käyttöön (from, where, select, limit, jne.)
  alias Harjoitustehtava.Repo # alias tekee että voi vain käyttää esim Repo.All eikä Harjoitustehtava.Repo.All
  alias Harjoitustehtava.Domain

  # 20 riviä per sivu
  @page_size 20

  def list_domains(query, page \\ 1) do
    offset_value = (page - 1) * @page_size # laskee montako riviä hypätään yli, esim. sivu 1: 0-20, sivu 2: 20-40

    # hakuehto: jos tyhjä niin kaikki, muuten LIKE-haku
    filter_query =
      if query in ["", nil] do
        Domain
      else
        search_term = "%#{query}%"
        Domain |> where([d], like(d.readable_entry, ^search_term))
      end

    # hakee sivun rivit
    page_query = filter_query |> limit(@page_size) |> offset(^offset_value)

    # laskee kokonaismäärän sivumäärää varten
    count_query = filter_query |> select([d], count(d.id))

    try do
      results = Repo.all(page_query)
      total = Repo.one(count_query)
      total_pages = max(ceil(total / @page_size), 1)
      {:ok, results, total_pages}
    rescue
      e in DBConnection.ConnectionError ->
        {:error, "Tietokantayhteys epäonnistui: #{Exception.message(e)}"} # tietokantavirhe
    end
  end
end
