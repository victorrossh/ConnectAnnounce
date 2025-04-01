# Connect Announce Plugin

**Connect Announce** is an AMX Mod X plugin for Counter-Strike 1.6 servers that displays customizable connection and disconnection messages for players. It leverages GeoIP for location information, Reunion for Steam/No-Steam detection, and supports role-based announcements based on admin flags. Messages can be tailored separately for connection and disconnection events using distinct CVARs.

- **Plugin Name**: Connect Announce
- **Version**: 1.0
- **Author**: ftl~

## Features

- Displays player connection and disconnection messages in chat with a custom prefix (`[FWO]`).
- Includes optional GeoIP-based location details (city, region, country).
- Detects Steam/No-Steam status using the Reunion module (`REU_GetAuthtype`).
- Shows player roles based on admin flags.
- Fully customizable via CVARs, with separate controls for connection and disconnection messages.
- Supports multilingual messages through a dictionary file (`connect_announce.txt`).

## Configuration

### CVARs

The plugin uses separate CVARs for connection and disconnection messages, allowing independent customization. All CVARs are registered with a default value of `1` (enabled).

#### Connection CVARs

| CVAR                  | Description                                      | Values                 |
|-----------------------|--------------------------------------------------|------------------------|
| `msg_city_connect`    | Show city in connection message                  | `1` = show, `0` = hide |
| `msg_region_connect`  | Show region in connection message                | `1` = show, `0` = hide |
| `msg_country_connect` | Show country in connection message               | `1` = show, `0` = hide |
| `msg_steam_connect`   | Show Steam/No-Steam status in connection message | `1` = show, `0` = hide |
| `msg_role_connect`    | Show role in connection message                  | `1` = show, `0` = hide |
| `msg_connect`         | Enable connection messages                       | `1` = show, `0` = hide |

#### Disconnection CVARs

| CVAR                     | Description                                         | Values                 |
|--------------------------|-----------------------------------------------------|------------------------|
| `msg_city_disconnect`    | Show city in disconnection message                  | `1` = show, `0` = hide |
| `msg_region_disconnect`  | Show region in disconnection message                | `1` = show, `0` = hide |
| `msg_country_disconnect` | Show country in disconnection message               | `1` = show, `0` = hide |
| `msg_steam_disconnect`   | Show Steam/No-Steam status in disconnection message | `1` = show, `0` = hide |
| `msg_role_disconnect`    | Show role in disconnection message                  | `1` = show, `0` = hide |
| `msg_disconnect`         | Enable disconnection messages                       | `1` = show, `0` = hide |

## Role System

Roles are determined by admin flags:

| Flag                    | Role                | Index |
|-------------------------|---------------------|-------|
| `ADMIN_CFG` (h)         | Owner               | 6     |
| `ADMIN_IMMUNITY` (a)    | Co-Owner            | 5     |
| `ADMIN_CVAR` (g)        | Administrator       | 4     |
| `ADMIN_BAN_TEMP` (v)    | Super-Moderator     | 3     |
| `ADMIN_BAN` (d)         | Moderator           | 2     |
| `ADMIN_RESERVATION` (b) | Helper              | 1     |
| None                    | Normal Player       | 0     |
