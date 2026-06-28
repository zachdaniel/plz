# Plz

A wildly dangerous piece of shell magic that runs claude in yolo mode to do whatever you want.

See the examples below. Anyone who lives out of shell will get why this is cool.

## Magic Shell Command that integrates well with `nushell`

```nushell
echo "zachdaniel,josevalim" 
  | plz "get their github usernames and locations" 
  | jq . 
  | plz "capitalize the keys"
  | where Username == "zachdaniel"
```

╭───┬────────────┬────────────────╮
│ # │  Username  │    Location    │
├───┼────────────┼────────────────┤
│ 0 │ zachdaniel │ Summit, NJ     │
╰───┴────────────┴────────────────╯

## Installation

Put the single `plz` script on your `PATH`. Then wire up your shell so `plz`
becomes *pipeline-aware* — it can see what you pipe **from** and **to**, which
is what lets it pick the right output format (e.g. JSON when you pipe into
`jq`). `plz init <shell>` prints the glue; there are no other files to install.

The glue uses your shell's own parser (`(z)` in zsh, `ast` in nushell) to
locate the running `plz` within the pipeline — no fragile string munging. If a
pipeline contains two identical `plz "…"` calls with different neighbors (so the
correct output format is genuinely ambiguous), `plz` errors out loudly instead
of guessing.

`plz` shells out to the [`claude`](https://docs.claude.com/claude-code) CLI,
which must be installed and authenticated.

### Get the script

With Homebrew (no separate tap repo — tap this repo by URL and install `--HEAD`):

```sh
brew tap zachdaniel/plz https://github.com/zachdaniel/plz
brew install --HEAD plz
```

Or just drop the single `plz` file anywhere on your `PATH`.

Then wire up your shell:

### Zsh

```zsh
# ~/.zshrc
eval "$(plz init zsh)"
```

### Nushell

Nushell can't `source` from stdin, so generate the glue once and source the
file (re-run the first line whenever you update `plz`):

```nu
plz init nu | save -f ($nu.default-config-dir | path join plz.nu)
# then, in config.nu:
source plz.nu
```

> Tip: `PLZ_DEBUG=1 <your pipeline>` prints the resolved `piped_from` /
> `piped_to` context and exits without calling Claude — handy for confirming
> pipeline detection.

## Examples

### Tell it to do stuff

```nushell
ls -la | plz "extract the filenames"
```

#### Output (any shell)

```
README.md
plz
```
#### Pipe into it

It knows what data format is coming *in*

```bash
echo '{"users": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}' | plz "extract just the names"
```

#### Output (any shell)

```
Alice
Bob
```

#### Pipe out of it into anything

It also knows what data format it needs to go *to* (i.e json, because of jq)

```bash
curl -s https://api.github.com/users/zachdaniel | plz "get the username and location" | jq .
```

##### Output (any shell)

```
{
  "username": "zachdaniel",
  "location": "Summit, NJ"
}
```

### It streams — pipe a live source into it

`plz` doesn't buffer stdin. It peeks the first few bytes (just to see the format),
then runs the generated command against the **live** stream, so unbounded sources
work and output flows as it's produced:

```bash
tail -f /var/log/app.log | plz "only show lines that look like errors"
```

### It understands nushell's structured data

When you pipe a nushell value (a table, record, or list) into `plz`, the wrapper
hands the engine clean JSON plus the value's shape (its columns and types) —
instead of nushell's rendered ASCII table — so the model works with named
fields. Plain text and byte streams pass straight through untouched (and keep
streaming). It also prefers for its final *return* to be structured data for display in nushell

```nushell
ls -la | plz "extract the filenames"
sys | plz "summarize memory and cpu as one line"
```

### It can fall back to an LLM for messy data

When a regex or parser would be too brittle, the generated command can pipe
through `plz transform "<instructions>"` — an LLM filter that reads stdin and
writes only the transformed result. `plz` reaches for this on its own when it
helps (e.g. turning ad-hoc log lines into JSON for `jq`), but you can use it
directly too:

```bash
tail -n 50 /var/log/app.log | plz transform "turn each line into a JSON object"
```

(Deterministic tools are still preferred when they'll do the job — they're
faster and they stream; `plz transform` reads its whole input.)

### Put it all together

```nushell
echo "zachdaniel,josevalim" | plz "get their github usernames and locations" | jq . | plz "capitalize the keys"
```

#### Output (nushell)

```
╭───┬────────────┬────────────────╮
│ # │   Login    │    Location    │
├───┼────────────┼────────────────┤
│ 0 │ zachdaniel │ Summit, NJ     │
│ 1 │ josevalim  │ Kraków, Poland │
╰───┴────────────┴────────────────╯
```

#### Output (zsh)

```
[
  {
    "Username": "zachdaniel",
    "Location": "Summit, NJ"
  },
  {
    "Username": "josevalim",
    "Location": "Kraków, Poland"
  }
]
```
