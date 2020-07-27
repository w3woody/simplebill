//
//  TimeDataRecord.h
//  Billing
//
//  Created by William Woody on 7/22/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeDataRecord : NSObject

@property (assign) NSInteger sqliteID;	// Field ID
@property (assign) NSInteger projectID;	// Project ID
@property (assign) uint32_t dayCount;	// Date of record
@property (assign) uint16_t hours;		// Hours (actually minutes from 0 to 1440)

@property (assign) uint16_t billID;		// Billing record ID
@property (assign) uint16_t billHours;	// Hours billed on bill

@property (copy) NSString *itemDesc;	// Item description

@end
