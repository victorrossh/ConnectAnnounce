#include <amxmodx>
#include <geoip>
#include <cromchat2>

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

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Chat prefix
	CC_SetPrefix("&x04[FWO]");
}

public plugin_cfg() {
	register_dictionary("connect_announce.txt");
}

public client_putinserver(id) { 
	set_task(3.0, "CheckPlayerConnect", id + TASK_CHECK_CONNECT);
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
	
	// Check if it's Steam using the authid
	new authid[40];
	get_user_authid(id, authid, charsmax(authid));
	formatex(steam, charsmax(steam), "%s", containi(authid, "STEAM_") == 0 ? "Steam" : "No-Steam");
	
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
	new role_text[32];
	for (new i = 0; i < num; i++) {
		new target = players[i];
		if (role == 0) {
			role_text[0] = EOS;
		} else {
			LookupLangKey(role_text, charsmax(role_text), g_szRoleKeys[role], target);
		}
		CC_SendMessage(target, "%L", target, "PLAYER_JOIN", name, city, region, country, steam, role_text);
	}
}

public client_disconnected(id) {   
	if (is_user_bot(id)) return;
	
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
	
	// Check if it's Steam using the authid
	new authid[40];
	get_user_authid(id, authid, charsmax(authid));
	formatex(steam, charsmax(steam), "%s", containi(authid, "STEAM_") == 0 ? "Steam" : "No-Steam");
	
	CC_SendMessage(0, "%l", "PLAYER_LEAVE", name, city, region, country, steam);
}