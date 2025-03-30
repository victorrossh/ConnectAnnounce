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

new cvar_msg_city, cvar_msg_region, cvar_msg_country, cvar_msg_steam, cvar_msg_role;
new cvar_msg_show_connect, cvar_msg_show_disconnect;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Chat prefix
	CC_SetPrefix("&x04[FWO]");
	
	// Register CVARs
	cvar_msg_city = register_cvar("msg_show_city", "1");                   // 1 = show city, 0 = hide
	cvar_msg_region = register_cvar("msg_show_region", "1");               // 1 = show region, 0 = hide
	cvar_msg_country = register_cvar("msg_show_country", "1");             // 1 = show country, 0 = hide
	cvar_msg_steam = register_cvar("msg_show_steam", "1");                 // 1 = show steam, 0 = hide
	cvar_msg_role = register_cvar("msg_show_role", "1");                   // 1 = show role, 0 = hide
	cvar_msg_show_connect = register_cvar("msg_show_connect", "1");        // 1 = show connect messages, 0 = hide
	cvar_msg_show_disconnect = register_cvar("msg_show_disconnect", "1");  // 1 = show disconnect messages, 0 = hide
}

public plugin_cfg() {
	register_dictionary("connect_announce.txt");
}

public client_putinserver(id) { 
	if (get_pcvar_num(cvar_msg_show_connect)) {
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
	
	// Check if it's Steam using the authid
	new authid[40];
	get_user_authid(id, authid, charsmax(authid));
	copy(steam, charsmax(steam), containi(authid, "STEAM_") == 0 ? "Steam" : "No-Steam");
	
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
	new role_text[64], location[128], extra[64];
	for (new i = 0; i < num; i++) {
		new target = players[i];
		
		location[0] = EOS;
		if (get_pcvar_num(cvar_msg_city)) {
			copy(location, charsmax(location), "&x04");
			add(location, charsmax(location), city);
			add(location, charsmax(location), "&x01");
		}
		if (get_pcvar_num(cvar_msg_region)) {
			if (location[0]) {
				add(location, charsmax(location), "&x01, ");
				add(location, charsmax(location), "&x04");
				add(location, charsmax(location), region);
				add(location, charsmax(location), "&x01");
			} else {
				copy(location, charsmax(location), "&x04");
				add(location, charsmax(location), region);
				add(location, charsmax(location), "&x01");
			}
		}
		if (get_pcvar_num(cvar_msg_country)) {
			if (location[0]) {
				add(location, charsmax(location), "&x01, ");
				add(location, charsmax(location), "&x04");
				add(location, charsmax(location), country);
				add(location, charsmax(location), "&x01");
			} else {
				copy(location, charsmax(location), "&x04");
				add(location, charsmax(location), country);
				add(location, charsmax(location), "&x01");
			}
		}
		if (location[0]) {
			new temp[128];
			copy(temp, charsmax(temp), location);
			copy(location, charsmax(location), "&x01[");
			add(location, charsmax(location), temp);
			add(location, charsmax(location), "&x01]");
		}
		
		extra[0] = EOS;
		if (get_pcvar_num(cvar_msg_steam)) {
			copy(extra, charsmax(extra), "&x01[&x04");
			add(extra, charsmax(extra), steam);
			add(extra, charsmax(extra), "&x01]");
		}
		if (role != 0 && get_pcvar_num(cvar_msg_role)) {
			LookupLangKey(role_text, charsmax(role_text), g_szRoleKeys[role], target);
			replace_all(role_text, charsmax(role_text), "&x04", "");
			replace_all(role_text, charsmax(role_text), "&x01", "");
			new temp_role[64];
			copy(temp_role, charsmax(temp_role), "&x01[&x04");
			add(temp_role, charsmax(temp_role), role_text);
			add(temp_role, charsmax(temp_role), "&x01]");
			if (extra[0]) {
				add(extra, charsmax(extra), " ");
				add(extra, charsmax(extra), temp_role);
			} else {
				copy(extra, charsmax(extra), temp_role);
			}
		}
		
		CC_SendMessage(target, "%L", target, "PLAYER_JOIN", name, location, extra);
	}
}

public client_disconnected(id) {   
	if (is_user_bot(id) || !get_pcvar_num(cvar_msg_show_disconnect)) {
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
	
	// Check if it's Steam using the authid
	new authid[40];
	get_user_authid(id, authid, charsmax(authid));
	copy(steam, charsmax(steam), containi(authid, "STEAM_") == 0 ? "Steam" : "No-Steam");
	
	new players[32], num;
	get_players(players, num, "ch");
	new location[128];
	for (new i = 0; i < num; i++) {
		new target = players[i];
		
		location[0] = EOS;
		if (get_pcvar_num(cvar_msg_city)) {
			copy(location, charsmax(location), "&x04");
			add(location, charsmax(location), city);
			add(location, charsmax(location), "&x01");
		}
		if (get_pcvar_num(cvar_msg_region)) {
			if (location[0]) {
				add(location, charsmax(location), "&x01, ");
				add(location, charsmax(location), "&x04");
				add(location, charsmax(location), region);
				add(location, charsmax(location), "&x01");
			} else {
				copy(location, charsmax(location), "&x04");
				add(location, charsmax(location), region);
				add(location, charsmax(location), "&x01");
			}
		}
		if (get_pcvar_num(cvar_msg_country)) {
			if (location[0]) {
				add(location, charsmax(location), "&x01, ");
				add(location, charsmax(location), "&x04");
				add(location, charsmax(location), country);
				add(location, charsmax(location), "&x01");
			} else {
				copy(location, charsmax(location), "&x04");
				add(location, charsmax(location), country);
				add(location, charsmax(location), "&x01");
			}
		}
		if (location[0]) {
			new temp[128];
			copy(temp, charsmax(temp), location);
			copy(location, charsmax(location), "&x01[");
			add(location, charsmax(location), temp);
			add(location, charsmax(location), "&x01]");
		}
		
		CC_SendMessage(target, "%L", target, "PLAYER_LEAVE", name, location);
	}
}