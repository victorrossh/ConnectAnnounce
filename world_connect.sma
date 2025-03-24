#include <amxmodx>
#include <geoip>
#include <cromchat2>

#define PLUGIN "Connect Announce"
#define VERSION "1.0"
#define AUTHOR "ftl~"
#define TASK_CHECK_CONNECT 1000

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
	
	new city_ret = geoip_city(ip, city, charsmax(city), 0);
	new region_ret = geoip_region_name(ip, region, charsmax(region), 0);
	new country_ret = geoip_country_ex(ip, country, charsmax(country), 0);
	
	server_print("GeoIP - Player: %s, IP: %s, City: %s (ret: %d), Region: %s (ret: %d), Country: %s (ret: %d)", name, ip, city, city_ret, region, region_ret, country, country_ret);
				 
	// If the city, region, or country information is not detected (value 0), set it to "Unknown"
	if (city[0] == EOS) copy(city, charsmax(city), "Unknown");
	if (region[0] == EOS) copy(region, charsmax(region), "Unknown");
	if (country[0] == EOS) copy(country, charsmax(country), "Unknown");
	
	// Check if it's Steam using the authid
	new authid[40];
	get_user_authid(id, authid, charsmax(authid));
	formatex(steam, charsmax(steam), "%s", containi(authid, "STEAM_") == 0 ? "Steam" : "No-Steam");
	
	if (get_user_flags(id) & ADMIN_BAN) {
		CC_SendMessage(0, "%l", "PLAYER_JOIN_ADMIN", name, city, region, country, steam);
	} else {
		CC_SendMessage(0, "%l", "PLAYER_JOIN", name, city, region, country, steam);
	}
}

public client_disconnected(id) {   
	if (is_user_bot(id)) return;
	
	task_exists(id + TASK_CHECK_CONNECT) && remove_task(id + TASK_CHECK_CONNECT);
	
	new name[32], city[32], region[32], country[32], steam[16];
	get_user_name(id, name, charsmax(name));
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);
	
	new city_ret = geoip_city(ip, city, charsmax(city), 0);
	new region_ret = geoip_region_name(ip, region, charsmax(region), 0);
	new country_ret = geoip_country_ex(ip, country, charsmax(country), 0);
	
	server_print("GeoIP - Player: %s, IP: %s, City: %s (ret: %d), Region: %s (ret: %d), Country: %s (ret: %d)", name, ip, city, city_ret, region, region_ret, country, country_ret);
	
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