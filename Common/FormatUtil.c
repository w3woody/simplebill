//
//  FormatUtil.c
//  Billing
//
//  Created by William Woody on 7/25/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#include "FormatUtil.h"
#include <stdbool.h>
#include <ctype.h>

/*
 *	Format hour
 */
void FormatHour(uint32_t minuteCount, char *dest)
{
	uint32_t h = minuteCount / 60;
	uint32_t m = minuteCount % 60;
	
	if (m == 0) {
		sprintf(dest, "%d",(int)h);
	} else {
		sprintf(dest, "%d:%02d",(int)h,(int)m);
	}
}


extern uint32_t ParseHour(const char *src)
{
	char c;
	uint32_t h;
	uint32_t m;
	bool fract = false;
	
	/*
	 *	Parse whole digits
	 */
	
	h = 0;
	while (0 != (c = *src++)) {
		if (isdigit(c)) {
			h = 10 * h + (c - '0');
		} else if ((c == ':') || (c == '.')) break;
	}
	
	if (c == 0) {
		return h * 60;
	} else if (c == '.') {
		fract = true;
	}
	
	m = 0;
	uint32_t f = 1;
	while (0 != (c = *src++)) {
		if (isdigit(c)) {
			m = 10 * m + (c - '0');
			f *= 10;
		}
	}
	
	if (fract) {
		h = h * 60 + (60 * m)/f;
	} else {
		h = h * 60 + m;
	}
	
	return h;
}

void FormatAmount(uint32_t pennies, char *dest)
{
	uint32_t dollars = pennies / 100;
	uint32_t cents = pennies % 100;
	
	/*
	 *	Comma separate as needed
	 */
	 
	if (dollars > 1000) {
		printf("###");
	}
	
	*dest++ = '$';
	uint8_t pos = 1;
	uint32_t f = 10;
	while (f < dollars) {
		f *= 10;
		pos++;
	}
	f /= 10;
	while (pos-- > 0) {
		uint8_t c = dollars / f;
		dollars %= f;
		
		*dest++ = '0' + c;
		
		if ((pos > 0) && ((pos % 3) == 0)) *dest++ = ',';
		f /= 10;
	}
	
	*dest++ = '.';
	*dest++ = '0' + (cents / 10);
	*dest++ = '0' + (cents % 10);
	*dest++ = 0;
}

uint32_t ParseAmount(const char *value)
{
	uint32_t dollars;
	uint32_t cents;
	uint32_t fract;
	char c;
	
	dollars = 0;
	cents = 0;
	while (0 != (c = *value++)) {
		if (c == '.') break;
		if (isdigit(c)) {
			dollars = 10 * dollars + (c - '0');
		}
	}
	if (c == 0) return dollars * 100;
	
	fract = 1;
	cents = 0;
	while (0 != (c = *value++)) {
		if (isdigit(c)) {
			fract *= 10;
			cents = 10 * cents + (c - '0');
		}
	}
	return dollars * 100 + (cents * 100)/fract;
}
