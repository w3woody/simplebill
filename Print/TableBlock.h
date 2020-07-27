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

- (instancetype)init;

- (void)insertRow:(id<ContentBlock>)row;


@end


// TODO: Finish me.

// This needs a constructor object to construct these into the page, in order
// to handle page breaks and continuous headers across page breaks.

