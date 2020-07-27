//
//  PrintBillView.h
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BillData;

@interface PrintBillView : NSView

- (instancetype)initWithBill:(NSArray<BillData *> *)data;

@end
