//
//  TableBuilder.h
//  Billing
//
//  Created by William Woody on 7/27/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ContentBlock.h"

@class PrintPageFlow;

/*
 *	Table builder helps build tables which may break across page breaks. This
 *	is how we build the timesheet summary
 */

@interface TableBuilder : NSObject

- (instancetype)initWithHorizontalMargin:(NSInteger)hmar verticalMargin:(NSInteger)vmar;

- (void)setHeaderAttributes:(NSDictionary *)hattr backgroundColor:(NSColor *)color;
- (void)setTextAttributes:(NSDictionary *)tattr;
- (void)setRowWidths:(NSArray<NSNumber *> *)widths;

- (void)addHeader:(NSString *)data colSpan:(NSInteger)span;
- (void)addCell:(NSString *)cell widthSpan:(NSInteger)span attributes:(NSDictionary *)attr;
- (void)addCell:(NSString *)cell widthSpan:(NSInteger)span;
- (void)nextRow;

- (BOOL)populatePageFlow:(PrintPageFlow *)pageFlow;

@end
