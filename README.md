# Connect Announce Plugin

**Connect Announce** is an AMX Mod X plugin for Counter-Strike 1.6 servers that displays customizable connection and disconnection messages for players. It leverages GeoIP for location information, Reunion for Steam/No-Steam detection, and supports role-based announcements based on admin flags. Messages can be tailored separately for connection and disconnection events using distinct CVARs, with improved handling for scenarios where location information is disabled.

- **Plugin Name**: Connect Announce
- **Version**: 1.0
- **Author**: ftl~

## Features

- Displays player connection and disconnection messages in chat with a custom prefix (`[FWO]`).
- Includes optional GeoIP-based location details (city, region, country), with optimized handling when location CVARs are disabled.
- Detects Steam/No-Steam status using the Reunion module (`REU_GetAuthtype`).
- Shows player roles based on admin flags, with proper spacing for readability.
- Fully customizable via CVARs, with separate controls for connection and disconnection messages.
- Supports multilingual messages through a dictionary file (`connect_announce.txt`).
- New: Uses distinct message formats (`PLAYER_JOIN_NO_LOCATION` and `PLAYER_LEAVE_NO_LOCATION`) when all location CVARs are disabled, ensuring clear and meaningful messages (e.g., "connected to the server" instead of "connected from []").

## Message Behavior

The plugin now dynamically adjusts its messages based on the state of the location CVARs (`msg_city_connect`, `msg_region_connect`, `msg_country_connect` for connection, and their equivalents for disconnection):

- **When at least one location CVAR is enabled**: The plugin uses the `PLAYER_JOIN` or `PLAYER_LEAVE` keys, showing the player's location if available.  
  Example: `[FWO] ftl~ツ connected from [Santo André, São Paulo, Brazil] [Steam] [Owner]`

- **When all location CVARs are disabled**: The plugin switches to the `PLAYER_JOIN_NO_LOCATION` or `PLAYER_LEAVE_NO_LOCATION` keys, omitting location information entirely for clarity.  
  Example: `[FWO] ftl~ツ connected to the server [Steam] [Owner].`

- **Spacing and Punctuation**: Spacing before Steam and Role tags (e.g., `[Steam]`, `[Owner]`) is now handled programmatically, ensuring consistency (e.g., `server [Steam] [Owner]`). A period is added to `PLAYER_JOIN_NO_LOCATION` and `PLAYER_LEAVE_NO_LOCATION` messages for proper punctuation when no tags are present (e.g., `connected to the server.`).

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
