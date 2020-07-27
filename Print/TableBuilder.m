//
//  TableBuilder.m
//  Billing
//
//  Created by William Woody on 7/27/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "TableBuilder.h"
#import "PrintBlock.h"
#import "TableBlock.h"
#import "PrintPageFlow.h"
#import "PrintRowBlock.h"

@interface TableBuilder ()
{
	NSInteger horizontalMargin;
	NSInteger verticalMargin;
	
	NSInteger hpos;
	NSInteger tpos;
	NSInteger prow;
}
@property (strong) NSMutableArray<id<ContentBlock>> *header;
@property (strong) NSMutableArray<NSMutableArray<id<ContentBlock>> *> *blocks;
@property (strong) NSArray<NSNumber *> *widths;
@property (strong) NSDictionary *headerAttribute;
@property (strong) NSColor *headerBackground;
@property (strong) NSDictionary *textAttribute;
@end

@implementation TableBuilder

- (instancetype)initWithHorizontalMargin:(NSInteger)hmar verticalMargin:(NSInteger)vmar
{
	if (nil != (self = [super init])) {
		horizontalMargin = hmar;
		verticalMargin = vmar;
		
		self.header = [[NSMutableArray alloc] init];
		self.blocks = [[NSMutableArray alloc] init];
		
		self.widths = @[];
		
		self.headerAttribute = @{};
		self.headerBackground = nil;
		self.textAttribute = @{};
		
		hpos = 0;
		tpos = 0;
		prow = 0;
	}
	return self;
}

- (void)setHeaderAttributes:(NSDictionary *)hattr backgroundColor:(NSColor *)color
{
	self.headerAttribute = hattr;
	self.headerBackground = color;
}

- (void)setTextAttributes:(NSDictionary *)tattr
{
	self.textAttribute = tattr;
}

- (void)setRowWidths:(NSArray<NSNumber *> *)widths
{
	self.widths = widths;
}

/*
 *	Insert contents
 */
 
- (void)addHeader:(NSString *)data colSpan:(NSInteger)span
{
	if ((hpos + span) > self.widths.count) return;		// Don't insert if we're out of space
	
	NSInteger width = self.widths[hpos].integerValue;
	for (NSInteger i = 1; i < span; ++i) {
		width += self.widths[hpos+i].integerValue + horizontalMargin * 2;
	}
	
	NSRect r = NSMakeRect(0, 0, width, 1);	/* height is reset */
	PrintBlock *block = [[PrintBlock alloc] initWithText:data attributes:self.headerAttribute at:r];
	
	[self.header addObject:block];
	
	hpos += span;
}

- (void)addCell:(NSString *)cell widthSpan:(NSInteger)span attributes:(NSDictionary *)attr
{
	NSMutableArray<id<ContentBlock>> *cur;
	
	if (self.blocks.count == 0) {
		cur = [[NSMutableArray alloc] init];
		[self.blocks addObject:cur];
		tpos = 0;
	} else {
		cur = self.blocks.lastObject;
	}
	
	if ((tpos + span) > self.widths.count) return;
	
	NSInteger width = self.widths[tpos].integerValue;
	for (NSInteger i = 1; i < span; ++i) {
		width += self.widths[tpos+i].integerValue + horizontalMargin * 2;
	}
	
	NSRect r = NSMakeRect(0, 0, width, 1);
	PrintBlock *block = [[PrintBlock alloc] initWithText:cell attributes:attr at:r];
	
	[cur addObject:block];
	tpos += span;
}

- (void)addCell:(NSString *)cell widthSpan:(NSInteger)span
{
	[self addCell:cell widthSpan:span attributes:self.textAttribute];
}

- (void)nextRow
{
	tpos = 0;
	[self.blocks addObject:[[NSMutableArray alloc] init]];
}

/*
 *	Construction of the table views
 */
 
- (BOOL)populatePageFlow:(PrintPageFlow *)pageFlow
{
	BOOL first = YES;
	
	/*
	 *	We make the assumption that there is enough space in this page to
	 *	insert at least the header and one row.
	 */
	
	NSInteger height = [pageFlow bottomSpaceWithMargin:12];
	TableBlock *tableBlock = [[TableBlock alloc] initWithMaximumHeight:height];
	[tableBlock showHorizontalRows:YES];
	
	/*
	 *	Build header
	 */
	
	PrintRowBlock *row = [[PrintRowBlock alloc] initWithBackground:self.headerBackground padding:verticalMargin];
	[row showVerticalColumns:YES];
	for (id<ContentBlock> block in self.header) {
		[row insertColumn:block withMargin:horizontalMargin];
	}
	if (![tableBlock insertRow:row]) {
		return NO;
	}
	
	/*
	 *	Start building until we run out
	 */
	 
	while (prow < self.blocks.count) {
		row = [[PrintRowBlock alloc] initWithBackground:nil padding:verticalMargin];
		[row showVerticalColumns:YES];
		for (id<ContentBlock> block in self.blocks[prow]) {
			[row insertColumn:block withMargin:horizontalMargin];
		}
		if (![tableBlock insertRow:row]) {
			if (!first) {
				[pageFlow insertFlowingBlock:tableBlock withMargin:verticalMargin];
			}
			return NO;
		}
		first = NO;
	
		++prow;
	}

	[pageFlow insertFlowingBlock:tableBlock withMargin:verticalMargin];
	return YES;
}

@end

