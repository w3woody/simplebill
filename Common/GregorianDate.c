//
//  GregorianDate.c
//  Billing
//
//  Created by William Woody on 7/22/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "GregorianDate.h"

#include <stdbool.h>
#include <stdio.h>
#include <time.h>

/****************************************************************************/
/*																			*/
/*	Constants																*/
/*																			*/
/****************************************************************************/

#define EPOCH			1

static const char *GMonths[] = {
	"",
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
};

static const char *GWeek[] = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
};

/****************************************************************************/
/*																			*/
/*	Internal Functions														*/
/*																			*/
/****************************************************************************/

/*	IsLeapYear
 *
 *		Is this a leap year?
 */

static bool IsLeapYear(uint16_t year)
{
	if (0 != (year % 4)) return false;
	if (0 != (year % 100)) return true;
	if (0 != (year % 400)) return false;
	return true;
}

/*	GregorianYear
 *
 *		Calculate the gregorian year given the day count
 */

static uint16_t GregorianYear(uint32_t dcount)
{
	uint32_t d = dcount - EPOCH;
	uint32_t n400 = d / 146097;
	
	d = d % 146097;
	uint32_t n100 = d / 36524;
	
	d = d % 36524;
	uint32_t n4 = d / 1461;
	
	d = d % 1461;
	uint32_t n1 = d / 365;
	
	uint32_t year = 400 * n400 + 100 * n100 + 4 * n4 + n1;
	if ((n100 == 4) || (n1 == 4)) {
		return (uint16_t)year;
	} else {
		return (uint16_t)year + 1;
	}
}

/*	GregorianDayCount
 *
 *		Calculate the day count from the date
 */

uint32_t GregorianDayCount(CalendarDate date)
{
	return GregorianCount(date.day, date.month, date.year);
}

/*	GregorianCount
 *
 *		Calculate the day count from the expanded date
 */
 
uint32_t GregorianCount(uint8_t day, uint8_t month, uint16_t year)
{
	uint32_t y1 = year - 1;
	
	uint32_t tmp = 365 * y1 + y1/4 - y1/100 + y1/400 + (367 * month - 362)/12;
	if (month > 2) {
		tmp = tmp - (IsLeapYear(year) ? 1 : 2);
	}
	return tmp + day - EPOCH + 1;
}

/*	GregorianCalendar
 *
 *		Convert day count to date
 */

CalendarDate GregorianCalendar(uint32_t dcount)
{
	uint16_t year = GregorianYear(dcount);
	uint16_t priorDays = (uint16_t)(dcount - GregorianCount(1,1,year));
	uint32_t march = GregorianCount(1,3,year);
	
	uint8_t correction;
	if (dcount < march) {
		correction = 0;
	} else if (IsLeapYear(year)) {
		correction = 1;
	} else {
		correction = 2;
	}
	
	uint8_t month = (uint8_t)((12 * (priorDays + correction) + 373)/367);
	uint8_t day = dcount - GregorianCount(1,month,year) + 1;
	
	return (CalendarDate){ day, month, year };
}

/*	GregorianDayOfWeek
 *
 *		Get the day of the week
 */

uint8_t GregorianDayOfWeek(uint32_t dcount)
{
	return dcount % 7;
}

/*	GregorianDaysInMonth
 *
 *		Get the number of days in the month
 */

uint8_t GregorianDaysInMonth(uint8_t month, uint16_t year)
{
	switch (month) {
		case 4:
		case 6:
		case 9:
		case 11:
			return 30;
		case 2:
			return IsLeapYear(year) ? 29 : 28;
		default:
			return 31;
	}
}

void GregorianFormat(uint32_t count, char *date)
{
	CalendarDate d = GregorianCalendar(count);
	uint8_t dow = GregorianDayOfWeek(count);
	
	sprintf(date,"%.3s %.3s %d, %d",GWeek[dow],GMonths[d.month],d.day,d.year);
}

void GregorianShortFormat(uint32_t count, char *date)
{
	CalendarDate d = GregorianCalendar(count);
	uint8_t dow = GregorianDayOfWeek(count);
	
	sprintf(date,"%.3s %d/%d",GWeek[dow],d.month,d.day);
}

void GregorianLongFormat(uint32_t count, char *date)
{
	CalendarDate d = GregorianCalendar(count);
	
	sprintf(date,"%s %d, %d",GMonths[d.month],d.day,d.year);
}

uint32_t GregorianCurrentDate(void)
{
	time_t t = time(NULL);
	struct tm *tm = localtime(&t);
	
	return GregorianCount(tm->tm_mday, tm->tm_mon+1, tm->tm_year + 1900);
}

const char *GregorianMonthName(uint8_t month)
{
	return GMonths[month];
}
