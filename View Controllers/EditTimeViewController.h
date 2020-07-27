//
//  EditTimeViewController.h
//  Billing
//
//  Created by William Woody on 7/23/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TimeDataRecord;

@interface EditTimeViewController : NSViewController

@property (strong) TimeDataRecord *editRecord;

@property (copy) void (^closeCallback)(TimeDataRecord *data);

@end
