//
//  Database.h
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectData;
@class TimeDataRecord;
@class BillData;

@interface Database : NSObject

+ (Database *)shared;
- (BOOL)startup;

/*
 *	Project data
 */

- (NSInteger)numberOfProjects;
- (ProjectData *)projectAtIndex:(NSInteger)index;
- (BOOL)deleteProjectAtIndex:(NSInteger)index;
- (BOOL)addProject:(ProjectData *)data;
- (BOOL)setProject:(ProjectData *)data atIndex:(NSInteger)index;

/*
 *	Billing data
 */

- (NSInteger)numberOfTimeRecordsInProject:(NSInteger)projIndex;
- (TimeDataRecord *)timeRecord:(NSInteger)index inProject:(NSInteger)projIndex;
- (BOOL)deleteTimeRecord:(NSInteger)index inProject:(NSInteger)projIndex;
- (BOOL)addTimeRecord:(TimeDataRecord *)r inProject:(NSInteger)projIndex;
- (BOOL)setTimeRecord:(TimeDataRecord *)r inProject:(NSInteger)projIndex  atIndex:(NSInteger)index;

/*
 *	Generate billing
 */

- (NSString *)nextBillForProject:(NSInteger)projIndex;
- (BillData *)generateBillForProject:(NSInteger)projIndex withTimeRecords:(NSIndexSet *)sel onDate:(uint32_t)date comments:(NSString *)note;

- (NSInteger)numberOfBills;
- (BillData *)billAtIndex:(NSInteger)index;

- (BOOL)updateNote:(NSString *)note forBillAtIndex:(NSInteger)index;
- (BOOL)setIsPaid:(BOOL)paid forBillAtIndex:(NSInteger)index;

@end
