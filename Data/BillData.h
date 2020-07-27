//
//  BillData.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeDataRecord;
@class ProjectData;

@interface BillData : NSObject

@property (assign) NSInteger sqliteID;
@property (assign) NSInteger projetID;
@property (assign) NSInteger billIndex;
@property (assign) NSInteger date;
@property (assign) NSInteger rate;		/* Rate in cents */
@property (assign) BOOL paid;			/* Is this a paid bill? */
@property (copy) NSString *notes;		/* Private notes about bill */

/*
 *	Synthesized values
 */

@property (copy) NSString *billID;			/* String ID shown for this bill */
@property (strong) ProjectData *project;	/* Project data object */
@property (strong) NSMutableArray<TimeDataRecord *> *timeData;

@property (assign) NSInteger totalHours;	/* Total hours (minutes) in time data table */
@property (assign) NSInteger totalBill;		/* Amount of the bill (rate * hours) */

@end
