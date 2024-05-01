# khizarb — Detailed Usage Guide

## Installation

```bash
git clone https://github.com/khiziarb/khizarb.git
cd khizarb
chmod +x khizarb.sh
sudo ln -s "$PWD/khizarb.sh" /usr/local/bin/khizarb
khizarb help
```

## Configuration

On first run, khizarb creates `~/.config/khizarb/config.env`:

```env
DEFAULT_FORMAT=json   # json | plain | table
TIMEOUT=10            # curl timeout in seconds
MAX_RETRIES=3         # number of retry attempts
CACHE_TTL=300         # cache lifetime in seconds (5 min)
```

## Commands

### `get`
```bash
khizarb get <url> [format]
```
Fetches a URL via GET. Caches the response for CACHE_TTL seconds.

### `post`
```bash
khizarb post <url> <json-body> [format]
```
Sends a POST request with a JSON body.

### `headers`
```bash
khizarb headers <url>
```
Shows response headers only.

### `preset`
```bash
khizarb preset <name> [format] [arg]
```

| Preset  | Description              | Optional arg  |
|---------|--------------------------|---------------|
| ip      | Your public IP address   | —             |
| weather | Current weather          | city name     |
| joke    | Random joke              | —             |
| dog     | Random dog image URL     | —             |
| crypto  | Crypto price in USD      | coin id       |
| github  | GitHub user profile      | username      |
| uuid    | Random UUID              | —             |

### `history`
```bash
khizarb history          # show all past requests
khizarb history clear    # delete history
```

### `cache`
```bash
khizarb cache clear      # delete cached responses
```

## Output Formats

| Format  | Description                              |
|---------|------------------------------------------|
| `json`  | Pretty-printed via `jq`                  |
| `plain` | Raw response text                        |
| `table` | Aligned columns (arrays or key-value)    |

## Running Tests

```bash
bash tests/test_fetch.sh
bash tests/test_cache.sh
bash tests/test_format.sh
```
