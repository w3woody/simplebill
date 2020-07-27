//
//  TableBlock.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ContentBlock.h"

/*
 *	Constructs a table block with separator lines
 */

@interface TableBlock : NSObject <ContentBlock>

- (instancetype)initWithMaximumHeight:(NSInteger)h;

// Returns false if we failed to finish entering and need a new page
- (BOOL)insertRow:(id<ContentBlock>)row;

- (void)showHorizontalRows:(BOOL)flag;

@end


// TODO: Finish me.

// This needs a constructor object to construct these into the page, in order
// to handle page breaks and continuous headers across page breaks.

