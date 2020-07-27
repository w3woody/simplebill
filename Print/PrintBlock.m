//
//  PrintBlock.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "PrintBlock.h"

@implementation PrintBlock

- (instancetype)initWithText:(NSString *)text attributes:(NSDictionary *)attr at:(NSRect)r
{
	if (nil != (self = [super init])) {
		/*
		 *	Determine the height of our rectangle
		 */
		
		self.attributes = attr;
		self.text = text;
		
		CGRect s = [text boundingRectWithSize:NSMakeSize(r.size.width,9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr];
		r.size.height = ceil(s.size.height);
		self.location = r;
	}
	return self;
}

- (void)draw
{
	[self.text drawWithRect:self.location options:NSStringDrawingUsesLineFragmentOrigin attributes:self.attributes];
}

@end
