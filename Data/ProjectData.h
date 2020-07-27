//
//  ProjectData.h
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectPerson;

@interface ProjectData : NSObject

@property (assign) NSInteger sqliteID;
@property (copy) NSString *name;
@property (assign) NSInteger billingRate;	/* Hourly billing rate (in pennies) */
@property (strong) NSMutableArray<ProjectPerson *> *persons;

@property (strong) NSString *billingPrefix;
@property (assign) NSInteger billingStartIndex;

@property (copy) NSString *fromAddress;
@property (copy) NSString *toAddress;
@property (copy) NSString *salutation;
@property (copy) NSString *einValue;

- (instancetype)init;
- (instancetype)initWithJSON:(NSDictionary *)json;
- (NSDictionary *)asJson;

@end
