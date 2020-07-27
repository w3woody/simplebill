//
//  PrintPageFlow.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "PrintPageFlow.h"
#import "ContentOffsetBlock.h"

@interface PrintPageFlow ()
{
	NSRect size;
	NSEdgeInsets margins;

	NSInteger pagePos;
	NSInteger visibleHeight;
	NSInteger prevMargin;
}

@property (strong) NSMutableArray<ContentOffsetBlock *> *blocks;

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
- (void)insertBlock:(id<ContentBlock>)block
{
	ContentOffsetBlock *b = [[ContentOffsetBlock alloc] init];
	b.offset = size.origin;
	b.block = block;

	[self.blocks addObject:b];
}

/*
 *	This will return NO if this doesn't fit. If that's the case, create a new
 *	page. Note this is placed relative to the margins.
 */
- (BOOL)insertFlowingBlock:(id<ContentBlock>)block withMargin:(NSInteger)margin
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
	
	NSInteger bottom = ceil(ypos + block.blockSize.height);
	if (bottom > visibleHeight) {
		return NO;
	}
	
	NSPoint pos;
	pos.x = size.origin.x + margins.left;
	pos.y = ypos + margins.top + size.origin.y;
	
	ContentOffsetBlock *b = [[ContentOffsetBlock alloc] init];
	b.offset = pos;
	b.block = block;
	[self.blocks addObject:b];
	
	pagePos = bottom;
	prevMargin = margin;
	
	return YES;
}

/**
 *	Returns the number of points between the current position and the bottom
 *	given the specified top margin. This is used by the table builder to
 *	properly break the table into table blocks.
 */
- (NSInteger)bottomSpaceWithMargin:(NSInteger)margin
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
	
	return visibleHeight - ypos;
}

/*
 *	Draw the blocks
 */

- (void)draw
{
	for (ContentOffsetBlock *b in self.blocks) {
		[b.block drawAtOffset:b.offset];
	}
}

@end
