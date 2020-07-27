//
//  ProjectTableCell.h
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectData;

@interface ProjectTableCell : NSTableCellView

- (void)setProjectData:(ProjectData *)data;

@end
