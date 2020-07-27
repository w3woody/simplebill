//
//  ProjectBillData.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Database;

@interface ProjectBillData : NSObject <NSTableViewDelegate, NSTableViewDataSource>

- (void)loadData:(Database *)database;
- (void)refreshData;
- (NSIndexSet *)selectedIndexes;

@end
