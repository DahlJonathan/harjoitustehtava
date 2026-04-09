# Harjoitustehtava — Domain-hakusovellus

Phoenix LiveView -sovellus, joka hakee domaineja SQLite-tietokannasta ja näyttää ne selaimessa.

## Ominaisuudet

- **Domainhaku** — kirjoita hakukenttään ja tulokset suodattuvat reaaliajassa
- **Sivutus** — tulokset näytetään 20 riviä kerrallaan, sivuja voi selata eteen/taakse
- **Rivin laajentaminen** — klikkaa riviä nähdäksesi kaikki kentät (ID, notes, public comment, review status jne.)

## Käynnistys

```bash
mix setup
mix phx.server
```

Avaa selaimessa: [localhost:4000](http://localhost:4000)

## Tiedostorakenne

### `priv`
Sisältää db.sqlite3 tietokanta tiedostot valmiina

### `lib/harjoitustehtava/domain.ex`
Tämä on Ecto-skeema eli se kertoo Elixirille miltä tietokannan taulu näyttää. Se vastaa `bl_listing` nimistä taulua tietokannassa. Siinä on määritelty kaikki kentät mitä taulussa on:
- Tekstikenttiä: `list_entry`, `readable_entry`, `public_comment`, `notes`, `blacklist_id`, `public_review`, `review_status`, `reason`
- Aikakenttiä: `created` ja `modified` — nämä on UTC datetime -tyyppiä eli ne tallennetaan ja luetaan DateTime-structeina

### `lib/harjoitustehtava/search.ex`
Tämä hoitaa itse tietokantahaun. Siinä on yksi funktio `list_domains(query, page)` joka:
- Ottaa hakusanan ja sivunumeron parametreina
- Jos hakusana on tyhjä niin hakee kaikki rivit
- Jos hakusana on annettu niin käyttää SQL:n `LIKE`-hakua eli `%hakusana%` jolloin löytyy kaikki rivit joissa readable_entry sisältää sen sanan
- Sivutus toimii niin että se laskee offset-arvon sivunumerosta (sivu 1 = rivit 0-20, sivu 2 = rivit 20-40 jne.)
- Palauttaa joko `{:ok, tulokset}` tai `{:error, virheviesti}` jos tietokantayhteys ei toimi

### `lib/harjoitustehtava_web/live/search_live.ex`
- **`mount/3`** — tämä ajetaan kun käyttäjä avaa sivun ensimmäistä kertaa. Se hakee alkutulokset ja asettaa alkutilan (tyhjä haku, sivu 1)
- **`fetch_results/2`** — apufunktio joka kutsuu Search.list_domains funktiota ja käsittelee vastauksen
- **`format_datetime/1`** — muotoilee DateTime-arvon luettavaan muotoon (DD-MM-YYYY HH:MM) tai näyttää viivan jos arvo on nil
- **`handle_event("search", ...)`** — kun käyttäjä kirjoittaa hakukenttään, tämä suoritetaan. Se hakee uudet tulokset ja palaa aina sivulle 1
- **`handle_event("toggle-row", ...)`** — kun käyttäjä klikkaa riviä, tämä avaa tai sulkee sen rivin lisätiedot
- **`handle_event("next-page"/"prev-page", ...)`** — sivutusnapit, next lisää sivunumeroa yhdellä ja prev vähentää (mutta ei mene alle 1:n)
- **`render/1`** — tämä on se HTML-template joka näyttää hakukentän, tulokset ja sivutusnapit

### `lib/harjoitustehtava_web/router.ex`
Reititystiedosto joka kertoo mihin osoitteeseen mikäkin sivu tulee. On vain yksi reitti: `live "/", SearchLive` eli kun menet localhost:4000 niin se näyttää SearchLive-sivun.

### `config/dev.exs`
Kehitysympäristön asetukset. Täällä on mm. tietokantapolku eli mistä se db.sqlite3-tiedosto löytyy.