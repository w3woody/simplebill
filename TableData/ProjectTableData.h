//
//  ProjectTableData.h
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Database;
@class ProjectData;

@interface ProjectTableData : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) void (^selectProject)(NSInteger index);
@property (copy) void (^editProject)(NSInteger index);

- (void)loadData:(Database *)database;

- (void)refreshData;
- (NSInteger)selectedIndex;

@end
