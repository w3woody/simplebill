//
//  NSColorView.m
//  Billing
//
//  Created by William Woody on 7/23/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "NSColorView.h"

@implementation NSColorView

- (void)drawRect:(NSRect)dirtyRect
{
	NSColor *color = [NSColor colorNamed:@"BackgroundColor"];
	[color setFill];
	NSRectFill(dirtyRect);
}

@end
