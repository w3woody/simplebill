//
//  NSDateView.h
//  Billing
//
//  Created by William Woody on 7/23/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSDateView : NSView

- (void)setSelectedDate:(uint32_t)day;
- (uint32_t)selectedDate;

@end
