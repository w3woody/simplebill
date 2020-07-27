//
//  PrintPageFlow.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "PrintPageFlow.h"
#import "PrintBlock.h"

@interface PrintPageFlow ()
{
	NSRect size;
	NSEdgeInsets margins;

	NSInteger pagePos;
	NSInteger visibleHeight;
	NSInteger prevMargin;
}
@end


@implementation PrintPageFlow

- (instancetype)initWithSize:(NSRect)s margins:(NSEdgeInsets)m
{
	if (nil != (self = [super init])) {
		pagePos = 0;
		size = s;
		margins = m;
		pagePos = 0;
		prevMargin = 0;
		
		visibleHeight = floor(s.size.height - m.bottom - m.top);
		
		self.blocks = [[NSMutableArray alloc] init];
	}
	return self;
}

/*
 *	Note: we move the block to fit our page. That is, the block should be
 *	positioned relative to paper margins.
 */
- (void)insertBlock:(PrintBlock *)block
{
	CGRect r = block.location;
	r.origin.x += size.origin.x;
	r.origin.y += size.origin.y;
	block.location = r;

	[self.blocks addObject:block];
}

/*
 *	This will return NO if this doesn't fit. If that's the case, create a new
 *	page.
 */
- (BOOL)insertFlowingBlock:(PrintBlock *)block withMargin:(NSInteger)margin
{
	NSInteger ypos;
	
	if (pagePos != 0) {
		/*
		 *	Bigger of the two margins.
		 */
		
		NSInteger bump = margin;
		if (bump < prevMargin) bump = prevMargin;
		ypos = pagePos + bump;
	} else {
		ypos = 0;
	}
	
	CGRect blockPos = block.location;
	NSInteger bottom = ypos + (int)ceil(blockPos.size.height);
	if (bottom > visibleHeight) {
		return NO;
	}
	
	blockPos.origin.x += size.origin.x;
	blockPos.origin.y = ypos + margins.top + size.origin.y;		/* Position object on our page */
	block.location = blockPos;
	[self.blocks addObject:block];
	
	pagePos = bottom;
	prevMargin = margin;
	
	return YES;
}

/*
 *	Draw the blocks
 */

- (void)draw
{
	for (PrintBlock *block in self.blocks) {
		[block draw];
	}
}

@end
