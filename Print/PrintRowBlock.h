//
//  PrintRowBlock.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentBlock.h"

/*
 *	This represents a row of print blocks, and is used for constructing a table.
 */

@interface PrintRowBlock : NSObject <ContentBlock>

- (instancetype)init;

- (void)insertColumn:(id<ContentBlock>)block;

@end
