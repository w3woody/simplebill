//
//  PrintRowBlock.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "PrintRowBlock.h"
#import "ContentOffsetBlock.h"

@interface PrintRowBlock ()
{
	NSMutableArray<NSNumber *> *bars;
	BOOL vertical;
	NSInteger padding;
	
	NSColor *background;	/* Background color; nil if none set */
	NSSize size;
}
@property (strong) NSMutableArray<ContentOffsetBlock *> *blocks;
@end

@implementation PrintRowBlock

- (instancetype)initWithBackground:(NSColor *)backgroundColor padding:(NSInteger)p
{
	if (nil != (self = [super init])) {
		self.blocks = [[NSMutableArray alloc] init];

		background = backgroundColor;
		size.width = 0;
		size.height = 0;
		padding = p;
		vertical = NO;
		
		bars = [[NSMutableArray alloc] init];
		[bars addObject:@0];
	}
	return self;
}

- (NSInteger)insertColumn:(id<ContentBlock>)block withMargin:(NSInteger)m
{
	NSSize bsize = block.blockSize;
	CGPoint pos = CGPointMake(size.width + m, padding);
	
	/*
	 *	Note that the margin supplied frames both left and right of the object.
	 *	This is done on the assumption the border hairline will be drawn inbetween
	 */
	
	NSInteger height = padding * 2 + bsize.height;
	size.width += bsize.width + m * 2;
	if (size.height < height) size.height = height;
	
	ContentOffsetBlock *b = [[ContentOffsetBlock alloc] init];
	b.offset = pos;
	b.block = block;
	[self.blocks addObject:b];
	
	[bars addObject:@( size.width )];
	
	return size.width;				/* Return position of right border of block with margin */
}

- (void)showVerticalColumns:(BOOL)flag
{
	vertical = flag;
}

- (NSSize)blockSize
{
	return size;
}

- (void)drawAtOffset:(NSPoint)offset
{
	/*
	 *	Draw the background color if set
	 */

	if (background) {
		CGRect r = CGRectMake(offset.x, offset.y, size.width, size.height);
		[background setFill];
		NSRectFill(r);
	}
	
	for (ContentOffsetBlock *b in self.blocks) {
		NSPoint accum = b.offset;
		accum.x += offset.x;
		accum.y += offset.y;
		[b.block drawAtOffset:accum];
	}
	
	[NSColor.blackColor setFill];
	if (vertical) {
		for (NSNumber *n in bars) {
			CGRect r = CGRectMake(offset.x + n.integerValue, offset.y, 0.25, size.height);
			NSRectFill(r);
		}
	}
}

@end
