//
//  EditBillViewController.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Database;

@interface EditBillViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) Database *database;
@property (assign) NSInteger selectedProject;
@property (strong) NSIndexSet *selectedTimeData;

@property (copy) void (^closeCallback)(BOOL update);

@end
