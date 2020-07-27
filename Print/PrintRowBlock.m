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
	NSSize size;
}
@property (strong) NSMutableArray<ContentOffsetBlock *> *blocks;
@end

@implementation PrintRowBlock

- (instancetype)init
{
	if (nil != (self = [super init])) {
		self.blocks = [[NSMutableArray alloc] init];
		size = CGSizeZero;
	}
	return self;
}

- (void)insertColumn:(id<ContentBlock>)block
{
	NSSize bsize = block.blockSize;
	CGPoint pos = CGPointMake(0, size.width);
	
	/*
	 *	Update size based on the block. We assume block stack horizontally
	 *	by their given size, but push the bottom
	 */
	
	size.width += bsize.width;
	if (size.height < bsize.height) size.height = bsize.height;
	
	ContentOffsetBlock *b = [[ContentOffsetBlock alloc] init];
	b.offset = pos;
	b.block = block;
	[self.blocks addObject:b];
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
		[b.block drawAtOffset:b.offset];
	}
}

@end
