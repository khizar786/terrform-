# khizarb

A lightweight, dependency-minimal Bash CLI for fetching and querying REST APIs — with caching, retry logic, request history, and multiple output formats.

---

## Features

- **GET / POST** any URL from the terminal
- **Response caching** with configurable TTL
- **Automatic retries** with rate-limit handling
- **Output formats**: JSON (pretty-printed), plain text, table
- **Built-in presets**: IP lookup, weather, jokes, dog images, crypto prices
- **Request history** logging
- **Fully configurable** via `~/.config/khizarb/config.env`

---

## Requirements

- `bash` 4+
- `curl`
- `jq` (for JSON and table formatting)

---

## Installation

```bash
git clone https://github.com/khiziarb/khizarb.git
cd khizarb
chmod +x khizarb.sh
sudo ln -s "$PWD/khizarb.sh" /usr/local/bin/khizarb
```

---

## Usage

```
khizarb <command> [options]
```

### Commands

| Command | Description |
|---|---|
| `get <url> [format]` | Fetch a URL via GET |
| `post <url> <json> [format]` | POST JSON to a URL |
| `headers <url>` | Show response headers |
| `preset <name> [format] [arg]` | Run a built-in preset |
| `history` | Show request history |
| `history clear` | Clear history |
| `cache clear` | Clear cached responses |
| `version` | Show version |
| `help` | Show help |

### Formats

- `json` — pretty-printed (default)
- `plain` — raw response
- `table` — aligned columns (arrays or objects)

---

## Examples

```bash
# Simple GET
khizarb get https://api.github.com/users/octocat json

# POST request
khizarb post https://httpbin.org/post '{"tool":"khizarb"}' table

# Built-in presets
khizarb preset ip
khizarb preset weather json London
khizarb preset crypto plain ethereum
khizarb preset joke

# History & cache
khizarb history
khizarb cache clear
```

---

## Configuration

Config is stored at `~/.config/khizarb/config.env`:

```env
DEFAULT_FORMAT=json
TIMEOUT=10
MAX_RETRIES=3
CACHE_TTL=300
```

---

## Project Structure

```
khizarb/
├── khizarb.sh        # Main CLI entrypoint
├── lib/
│   ├── fetch.sh      # HTTP fetch & retry logic
│   ├── cache.sh      # Caching layer
│   ├── format.sh     # Output formatters
│   ├── history.sh    # Request history
│   └── presets.sh    # Built-in API presets
├── tests/
│   ├── test_fetch.sh
│   ├── test_cache.sh
│   └── test_format.sh
├── docs/
│   └── USAGE.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## License

MIT © Khiziar Bashir
