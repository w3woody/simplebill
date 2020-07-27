//
//  ContentBlock.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <AppKit/AppKit.h>

/*
 *	Our printing system is fundamentally a collection of blocks of area which
 *	may contain other blocks which are printed on a page. This is the abstraction
 *	of that block and the required interfaces to handle positioning and
 *	flowing those blocks both vertically and horizontally.
 */

@protocol ContentBlock <NSObject>

- (NSSize)blockSize;		/* The block's desired size for placement */

- (void)drawAtOffset:(NSPoint)offset;

@end
