# Changelog

All notable changes to khizarb are documented here.

## [1.0.0] - 2025-04-14
### Added
- Initial stable release
- GET and POST commands with retry logic
- Response caching with configurable TTL
- Output formats: json, plain, table
- Built-in presets: ip, weather, joke, dog, crypto, github, uuid
- Request history logging
- Full test suite

## [0.9.0] - 2025-03-20
### Added
- Preset system for common APIs
- github and uuid presets
### Fixed
- Cache TTL comparison off-by-one error

## [0.8.0] - 2025-02-10
### Added
- Table output formatter using jq + column
### Changed
- Refactored lib/ into separate modules

## [0.7.0] - 2025-01-05
### Added
- Request history with timestamps
- `history clear` subcommand

## [0.6.0] - 2024-12-01
### Added
- Response caching layer (lib/cache.sh)
- `cache clear` subcommand

## [0.5.0] - 2024-10-15
### Added
- Retry logic with exponential back-off
- Rate-limit (HTTP 429) handling

## [0.4.0] - 2024-09-01
### Added
- POST command support
- Content-Type header injection

## [0.3.0] - 2024-07-20
### Added
- JSON pretty-print output via jq
- Plain text output option

## [0.2.0] - 2024-06-10
### Added
- Config file at ~/.config/khizarb/config.env
- Configurable TIMEOUT and MAX_RETRIES

## [0.1.0] - 2024-05-01
### Added
- Basic GET fetch via curl
- Coloured terminal output
