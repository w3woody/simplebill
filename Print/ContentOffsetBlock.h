//
//  ContentOffsetBlock.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ContentBlock.h"

@interface ContentOffsetBlock : NSObject

@property (assign) NSPoint offset;
@property (strong) id<ContentBlock> block;

@end
