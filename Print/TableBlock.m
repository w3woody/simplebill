//
//  TableBlock.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "TableBlock.h"
#import "ContentOffsetBlock.h"

#define MAXROWS			32

@interface TableBlock ()
{
	NSMutableArray<NSNumber *> *rows;
		
	BOOL horizontal;
	
	NSInteger maxHeight;	/* Maximum desired height */
	NSSize size;
}
@property (strong) NSMutableArray<ContentOffsetBlock *> *blocks;
@end

@implementation TableBlock

- (instancetype)initWithMaximumHeight:(NSInteger)h
{
	if (nil != (self = [super init])) {
		self.blocks = [[NSMutableArray alloc] init];
		size.width = 0;
		size.height = 0;
		maxHeight = h;
		
		rows = [[NSMutableArray alloc] init];
		
		[rows addObject:@0];				/* The top is always zero */
	}
	return self;
}

- (BOOL)insertRow:(id<ContentBlock>)block
{
	/*
	 *	Determine if this fits. If not, bail. Note we include both the
	 *	top and bottom margins, so the hairlines (if present) will fit on
	 *	the page.
	 */

	NSSize bsize = block.blockSize;
	CGPoint pos = CGPointMake(0, size.height);
	if (pos.y + bsize.height > maxHeight) return NO;
	
	/*
	 *	Update size based on the block. We assume block stack horizontally
	 *	by their given size, but push the bottom
	 */
	
	size.height += bsize.height;
	if (size.width < bsize.width) size.width = bsize.width;
	
	ContentOffsetBlock *b = [[ContentOffsetBlock alloc] init];
	b.offset = pos;
	b.block = block;
	[self.blocks addObject:b];
		
	/*
	 *	Insert the position at the bottom below this bar
	 */
	
	[rows addObject:@( size.height )];

	return YES;
}

- (void)showHorizontalRows:(BOOL)flag
{
	horizontal = flag;
}

- (NSSize)blockSize
{
	return size;
}

- (void)drawAtOffset:(NSPoint)offset
{
	for (ContentOffsetBlock *b in self.blocks) {
		NSPoint accum = b.offset;
		accum.x += offset.x;
		accum.y += offset.y;
		[b.block drawAtOffset:accum];
	}
	
	/*
	 *	Draw horizontal lines if specified.
	 */
	 
	[NSColor.blackColor setFill];
	if (horizontal) {
		/*
		 *	First line is at 0; the rest are at the bottom position of our
		 *	various blocks
		 */
		 
		for (NSNumber *n in rows) {
			CGRect r = CGRectMake(offset.x, offset.y + n.integerValue, size.width, 0.25);
			NSRectFill(r);
		}
	}
}

@end
