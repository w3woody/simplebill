//
//  FormatUtil.h
//  Billing
//
//  Created by William Woody on 7/25/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#ifndef FormatUtil_h
#define FormatUtil_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************/
/*																			*/
/*	Functions																*/
/*																			*/
/****************************************************************************/

extern void FormatHour(uint32_t minuteCount, char *dest);
extern uint32_t ParseHour(const char *src);

extern void FormatAmount(uint32_t pennies, char *dest);
extern uint32_t ParseAmount(const char *src);

#ifdef __cplusplus
}
#endif

#endif /* FormatUtil_h */
