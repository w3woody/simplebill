//
//  PrintBlock.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <AppKit/AppKit.h>

/*
 *	This represents a block of text within a page. This assumes the block
 *	is entirely contained on the page and doesn't break.
 */

@interface PrintBlock : NSObject
@property (strong) NSDictionary *attributes;
@property (copy) NSString *text;
@property (assign) NSRect location;

- (instancetype)initWithText:(NSString *)text attributes:(NSDictionary *)attr at:(NSRect)r;

- (void)draw;

@end
