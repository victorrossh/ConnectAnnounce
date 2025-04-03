stock build_location(city[], region[], country[], city_cvar, region_cvar, country_cvar, location[], maxlen) {
	new parts[3][32], part_count = 0;
	
	if (get_pcvar_num(city_cvar)) {
		copy(parts[part_count++], charsmax(parts[]), city);
	}
	if (get_pcvar_num(region_cvar)) {
		copy(parts[part_count++], charsmax(parts[]), region);
	}
	if (get_pcvar_num(country_cvar)) {
		copy(parts[part_count++], charsmax(parts[]), country);
	}
	
	location[0] = EOS;
	for (new i = 0; i < part_count; i++) {
		if (i > 0) {
			add(location, maxlen, ", ");
		}
		add(location, maxlen, parts[i]);
	}
}