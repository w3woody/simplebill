//
//  PrintPageFlow.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentBlock.h"

/*
 *	This represents a page. Contents are assumed to "flow" from the top to
 *	the bottom (with the specified insets and heights). Note that blocks
 *	can also be inserted without 'flowing', and if a 'flow' block does not
 *	fit on the page, an error is returned, which indicates a new page flow
 *	object should be generated
 */
 
@class PrintBlock;

@interface PrintPageFlow : NSObject

- (instancetype)initWithSize:(NSRect)size margins:(NSEdgeInsets)margins;

- (void)insertBlock:(id<ContentBlock>)block;
- (BOOL)insertFlowingBlock:(id<ContentBlock>)block withMargin:(NSInteger)margin;	/* Return NO if doesn't fit */

- (NSInteger)bottomSpaceWithMargin:(NSInteger)margin;			/* Space at the bottom available for content */

- (void)draw;

@end
