#!/usr/bin/env bash
# lib/presets.sh — Built-in API presets

cmd_preset() {
  local name="$1"
  local fmt="${2:-json}"

  case "$name" in
    ip)
      cmd_get "https://api.ipify.org?format=json" "$fmt"
      ;;
    weather)
      local city="${3:-London}"
      cmd_get "https://wttr.in/${city}?format=j1" "$fmt"
      ;;
    joke)
      cmd_get "https://official-joke-api.appspot.com/random_joke" "$fmt"
      ;;
    dog)
      cmd_get "https://dog.ceo/api/breeds/image/random" "$fmt"
      ;;
    crypto)
      local coin="${3:-bitcoin}"
      cmd_get "https://api.coingecko.com/api/v3/simple/price?ids=${coin}&vs_currencies=usd" "$fmt"
      ;;
    github)
      local user="${3:-octocat}"
      cmd_get "https://api.github.com/users/${user}" "$fmt"
      ;;
    uuid)
      cmd_get "https://httpbin.org/uuid" "$fmt"
      ;;
    *)
      error "Unknown preset '$name'. Available: ip, weather, joke, dog, crypto, github, uuid"
      ;;
  esac
}
# ip preset
# weather preset
# joke preset
# dog preset
# crypto preset
# github preset
