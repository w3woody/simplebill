//
//  GregorianDate.h
//  Billing
//
//  Created by William Woody on 7/22/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************/
/*																			*/
/*	Structures																*/
/*																			*/
/****************************************************************************/

/*	CalendarDate
 *
 *		Calendar date record
 */

typedef struct CalendarDate
{
	uint8_t day;		/* day == 1..31 */
	uint8_t month;		/* month == 1..12 */
	uint16_t year;		/* year == four digit year */
} CalendarDate;

/****************************************************************************/
/*																			*/
/*	Functions																*/
/*																			*/
/****************************************************************************/

extern uint32_t GregorianDayCount(CalendarDate date);
extern uint32_t GregorianCount(uint8_t day, uint8_t month, uint16_t year);
extern CalendarDate GregorianCalendar(uint32_t dayCount);

extern uint8_t GregorianDaysInMonth(uint8_t month, uint16_t year);
extern uint8_t GregorianDayOfWeek(uint32_t count);

extern void GregorianFormat(uint32_t count, char *date);
extern void GregorianShortFormat(uint32_t count, char *date);
extern void GregorianNumberFormat(uint32_t count, char *date);
extern void GregorianLongFormat(uint32_t count, char *date);
extern const char *GregorianMonthName(uint8_t month);

extern uint32_t GregorianCurrentDate(void);


#ifdef __cplusplus
}
#endif
