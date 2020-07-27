//
//  ProjectTimeData.h
//  Billing
//
//  Created by William Woody on 7/22/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Database;
@class ProjectData;

@interface ProjectTimeData : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (copy) void (^selectTime)(NSInteger projID, NSInteger index);
@property (copy) void (^editTime)(NSInteger projID, NSInteger index);

- (void)loadData:(Database *)database;
- (void)setProject:(NSInteger)projectIndex;

- (void)refreshData;
- (NSInteger)selectedIndex;
- (NSIndexSet *)selectedIndexes;

@end
