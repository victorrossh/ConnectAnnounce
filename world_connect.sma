#include <amxmodx>
#include <geoip>
#include <cromchat2>
#include <reapi_reunion>

#define PLUGIN "Connect Announce"
#define VERSION "1.0"
#define AUTHOR "ftl~"
#define TASK_CHECK_CONNECT 1000

// Define the keys for roles in the dictionary
new const g_szRoleKeys[][] = {
	"",                 // Index 0: Normal player
	"ROLE_HELPER",      // Index 1: Helper
	"ROLE_MOD",         // Index 2: Moderator
	"ROLE_SUPER_MOD",   // Index 3: Super-Moderator
	"ROLE_ADMIN",       // Index 4: Administrator
	"ROLE_CO_OWNER",    // Index 5: Co-Owner
	"ROLE_OWNER"        // Index 6: Owner
};

// CVARs for connection
new cvar_msg_city_connect, cvar_msg_region_connect, cvar_msg_country_connect, cvar_msg_steam_connect, cvar_msg_role_connect;
new cvar_msg_connect;

// CVARs for disconnection
new cvar_msg_city_disconnect, cvar_msg_region_disconnect, cvar_msg_country_disconnect, cvar_msg_steam_disconnect, cvar_msg_role_disconnect;
new cvar_msg_disconnect;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Chat prefix
	CC_SetPrefix("&x04[FWO]");
	
	// Register CVARs for connection
	cvar_msg_city_connect = register_cvar("msg_city_connect", "1");                  // 1 = show city in connection message, 0 = hide
	cvar_msg_region_connect = register_cvar("msg_region_connect", "1");              // 1 = show region in connection message, 0 = hide
	cvar_msg_country_connect = register_cvar("msg_country_connect", "1");            // 1 = show country in connection message, 0 = hide
	cvar_msg_steam_connect = register_cvar("msg_steam_connect", "1");                // 1 = show steam status in connection message, 0 = hide
	cvar_msg_role_connect = register_cvar("msg_role_connect", "1");                  // 1 = show role in connection message, 0 = hide
	cvar_msg_connect = register_cvar("msg_connect", "1");                            // 1 = show connection messages, 0 = hide
	
	// Register CVARs for disconnection
	cvar_msg_city_disconnect = register_cvar("msg_city_disconnect", "1");            // 1 = show city in disconnection message, 0 = hide
	cvar_msg_region_disconnect = register_cvar("msg_region_disconnect", "1");        // 1 = show region in disconnection message, 0 = hide
	cvar_msg_country_disconnect = register_cvar("msg_country_disconnect", "1");      // 1 = show country in disconnection message, 0 = hide
	cvar_msg_steam_disconnect = register_cvar("msg_steam_disconnect", "1");          // 1 = show steam status in disconnection message, 0 = hide
	cvar_msg_role_disconnect = register_cvar("msg_role_disconnect", "1");            // 1 = show role in disconnection message, 0 = hide
	cvar_msg_disconnect = register_cvar("msg_disconnect", "1");                      // 1 = show disconnection messages, 0 = hide
}

public plugin_cfg() {
	register_dictionary("connect_announce.txt");
}

public client_putinserver(id) { 
	if (get_pcvar_num(cvar_msg_connect)) {
		set_task(3.0, "CheckPlayerConnect", id + TASK_CHECK_CONNECT);
	}
}

public CheckPlayerConnect(id) {
	id -= TASK_CHECK_CONNECT;
	
	if (!is_user_connected(id) || is_user_bot(id)) {
		remove_task(id + TASK_CHECK_CONNECT);
		return;
	}
	
	new name[32], city[32], region[32], country[32], steam[16];
	get_user_name(id, name, charsmax(name));
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);
	
	geoip_city(ip, city, charsmax(city), 0);
	geoip_region_name(ip, region, charsmax(region), 0);
	geoip_country_ex(ip, country, charsmax(country), 0);
	
	server_print("GeoIP - Player: %s, IP: %s, City: %s, Region: %s, Country: %s", name, ip, city, region, country);
	
	// If the city, region, or country information is not detected (value 0), set it to "Unknown"
	if (city[0] == EOS) copy(city, charsmax(city), "Unknown");
	if (region[0] == EOS) copy(region, charsmax(region), "Unknown");
	if (country[0] == EOS) copy(country, charsmax(country), "Unknown");
	
	// Check if it's Steam using Reunion (REU_GetAuthtype)
	switch (REU_GetAuthtype(id)) {
		case CA_TYPE_STEAM: {
			formatex(steam, charsmax(steam), "Steam");
		}
		default: {
			formatex(steam, charsmax(steam), "No-Steam");
		}
	}
	
	// Check player flag
	new flags = get_user_flags(id);
	
	new role = (flags & ADMIN_CFG) ? 6 :               // Owner (flag h)
			   (flags & ADMIN_IMMUNITY) ? 5 :         // Co-Owner (flag a)
			   (flags & ADMIN_CVAR) ? 4 :             // Administrator (flag g)
			   (flags & ADMIN_BAN_TEMP) ? 3 :         // Super-Moderator (flag v)
			   (flags & ADMIN_BAN) ? 2 :              // Moderator (flag d)
			   (flags & ADMIN_RESERVATION) ? 1 : 0;   // Helper (flag b), if not, normal player
		
	new players[32], num;
	get_players(players, num, "ch"); // Ignore the bots
	new role_text[64], location[128];
	for (new i = 0; i < num; i++) {
		new target = players[i];
		
		location[0] = EOS;
		if (get_pcvar_num(cvar_msg_city_connect)) {
			if (get_pcvar_num(cvar_msg_region_connect)) {
				if (get_pcvar_num(cvar_msg_country_connect)) {
					formatex(location, charsmax(location), "%s, %s, %s", city, region, country);
				} else {
					formatex(location, charsmax(location), "%s, %s", city, region);
				}
			} else if (get_pcvar_num(cvar_msg_country_connect)) {
				formatex(location, charsmax(location), "%s, %s", city, country);
			} else {
				formatex(location, charsmax(location), "%s", city);
			}
		} else if (get_pcvar_num(cvar_msg_region_connect)) {
			if (get_pcvar_num(cvar_msg_country_connect)) {
				formatex(location, charsmax(location), "%s, %s", region, country);
			} else {
				formatex(location, charsmax(location), "%s", region);
			}
		} else if (get_pcvar_num(cvar_msg_country_connect)) {
			formatex(location, charsmax(location), "%s", country);
		}
		
		new steam_open[2], steam_value[32], steam_close[2];
		new role_open[2], role_value[64], role_close[2];
		
		steam_open[0] = steam_value[0] = steam_close[0] = EOS;
		role_open[0] = role_value[0] = role_close[0] = EOS;
		
		if (get_pcvar_num(cvar_msg_steam_connect)) {
			copy(steam_open, charsmax(steam_open), "[");
			copy(steam_value, charsmax(steam_value), steam);
			copy(steam_close, charsmax(steam_close), "]");
		}
		
		if (role != 0 && get_pcvar_num(cvar_msg_role_connect)) {
			LookupLangKey(role_text, charsmax(role_text), g_szRoleKeys[role], target);
			copy(role_open, charsmax(role_open), "[");
			copy(role_value, charsmax(role_value), role_text);
			copy(role_close, charsmax(role_close), "]");
		}

		CC_SendMessage(target, "%L", target, "PLAYER_JOIN", name, location[0] ? location : "", steam_open, steam_value, steam_close, role_open, role_value, role_close);
	}
}

public client_disconnected(id) {   
	if (is_user_bot(id) || !get_pcvar_num(cvar_msg_disconnect)) {
		return;
	}
	
	task_exists(id + TASK_CHECK_CONNECT) && remove_task(id + TASK_CHECK_CONNECT);
	
	new name[32], city[32], region[32], country[32], steam[16];
	get_user_name(id, name, charsmax(name));
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);
	
	geoip_city(ip, city, charsmax(city), 0);
	geoip_region_name(ip, region, charsmax(region), 0);
	geoip_country_ex(ip, country, charsmax(country), 0);
	
	server_print("GeoIP - Player: %s, IP: %s, City: %s, Region: %s, Country: %s", name, ip, city, region, country);
	
	// If the city, region, or country information is not detected (value 0), set it to "Unknown"
	if (city[0] == EOS) copy(city, charsmax(city), "Unknown");
	if (region[0] == EOS) copy(region, charsmax(region), "Unknown");
	if (country[0] == EOS) copy(country, charsmax(country), "Unknown");
	
	// Check if it's Steam using Reunion (REU_GetAuthtype)
	switch (REU_GetAuthtype(id)) {
		case CA_TYPE_STEAM: {
			formatex(steam, charsmax(steam), "Steam");
		}
		default: {
			formatex(steam, charsmax(steam), "No-Steam");
		}
	}
	
	// Check player flag
	new flags = get_user_flags(id);
	
	new role = (flags & ADMIN_CFG) ? 6 :               // Owner (flag h)
			   (flags & ADMIN_IMMUNITY) ? 5 :         // Co-Owner (flag a)
			   (flags & ADMIN_CVAR) ? 4 :             // Administrator (flag g)
			   (flags & ADMIN_BAN_TEMP) ? 3 :         // Super-Moderator (flag v)
			   (flags & ADMIN_BAN) ? 2 :              // Moderator (flag d)
			   (flags & ADMIN_RESERVATION) ? 1 : 0;   // Helper (flag b), if not, normal player
	
	new players[32], num;
	get_players(players, num, "ch"); // Ignore the bots
	new role_text[64], location[128];
	for (new i = 0; i < num; i++) {
		new target = players[i];
		
		location[0] = EOS;
		if (get_pcvar_num(cvar_msg_city_disconnect)) {
			if (get_pcvar_num(cvar_msg_region_disconnect)) {
				if (get_pcvar_num(cvar_msg_country_disconnect)) {
					formatex(location, charsmax(location), "%s, %s, %s", city, region, country);
				} else {
					formatex(location, charsmax(location), "%s, %s", city, region);
				}
			} else if (get_pcvar_num(cvar_msg_country_disconnect)) {
				formatex(location, charsmax(location), "%s, %s", city, country);
			} else {
				formatex(location, charsmax(location), "%s", city);
			}
		} else if (get_pcvar_num(cvar_msg_region_disconnect)) {
			if (get_pcvar_num(cvar_msg_country_disconnect)) {
				formatex(location, charsmax(location), "%s, %s", region, country);
			} else {
				formatex(location, charsmax(location), "%s", region);
			}
		} else if (get_pcvar_num(cvar_msg_country_disconnect)) {
			formatex(location, charsmax(location), "%s", country);
		}
		
		new steam_open[2], steam_value[32], steam_close[2];
		new role_open[2], role_value[64], role_close[2];
		
		steam_open[0] = steam_value[0] = steam_close[0] = EOS;
		role_open[0] = role_value[0] = role_close[0] = EOS;
		
		if (get_pcvar_num(cvar_msg_steam_disconnect)) {
			copy(steam_open, charsmax(steam_open), "[");
			copy(steam_value, charsmax(steam_value), steam);
			copy(steam_close, charsmax(steam_close), "]");
		}
		
		if (role != 0 && get_pcvar_num(cvar_msg_role_disconnect)) {
			LookupLangKey(role_text, charsmax(role_text), g_szRoleKeys[role], target);
			copy(role_open, charsmax(role_open), "[");
			copy(role_value, charsmax(role_value), role_text);
			copy(role_close, charsmax(role_close), "]");
		}
		
		CC_SendMessage(target, "%L", target, "PLAYER_LEAVE", name, location[0] ? location : "", steam_open, steam_value, steam_close, role_open, role_value, role_close);
	}
}