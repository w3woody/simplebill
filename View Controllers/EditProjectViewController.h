//
//  EditProjectViewController.h
//  Billing
//
//  Created by William Woody on 7/20/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectData;

@interface EditProjectViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) ProjectData *editData;

@property (copy) void (^closeCallback)(ProjectData *data);

@end
