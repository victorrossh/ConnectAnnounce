#include <amxmodx>
#include <geoip>
#include <cromchat2>

#define PLUGIN "Connect Announce"
#define VERSION "1.0"
#define AUTHOR "ftl~"
#define TASK_CHECK_CONNECT 1000

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_cfg() {
	register_dictionary("connect_announce.txt");
}

public client_putinserver(id) { 
	set_task(5.0, "CheckPlayerConnect", id + TASK_CHECK_CONNECT);
}

public CheckPlayerConnect(id) {
	id -= TASK_CHECK_CONNECT;
	
	if (!is_user_connected(id) || is_user_bot(id)) {
		remove_task(id+TASK_CHECK_CONNECT)
		return;
	}
	
	new name[32], country[8], tag[16];
	get_user_name(id, name, charsmax(name));
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);
	geoip_country_ex(ip, country, charsmax(country));
	
	if (country[0] == EOS) {
		copy(country, charsmax(country), "Unknow");
	} else {
		new len = strlen(country);
		if (len > 2) {
			country[2] = EOS;
		}
		strtoupper(country);
	}
	
	formatex(tag, charsmax(tag), "&x04[%s]", country);
	
	if (get_user_flags(id) & ADMIN_BAN) {
		CC_SendMessage(0, "%l", "PLAYER_JOIN_ADMIN", tag, name);
	} else {
		CC_SendMessage(0, "%l", "PLAYER_JOIN", tag, name);
	}
}

public client_disconnected(id) {   
	if (is_user_bot(id) || (task_exists(id + TASK_CHECK_CONNECT) && remove_task(id + TASK_CHECK_CONNECT))) {
		return;
	}
	
	new name[32], country[8], tag[16];
	get_user_name(id, name, charsmax(name));
	
	new ip[32];
	get_user_ip(id, ip, charsmax(ip), 1);
	geoip_country_ex(ip, country, charsmax(country));
	
	if (country[0] == EOS) {
		copy(country, charsmax(country), "Unknow");
	} else {
		new len = strlen(country);
		if (len > 2) {
			country[2] = EOS;
		}
		strtoupper(country);
	}
	
	formatex(tag, charsmax(tag), "&x04[%s]", country);
	CC_SendMessage(0, "%l", "PLAYER_LEAVE", tag, name);
}