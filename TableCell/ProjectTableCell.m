//
//  ProjectTableCell.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectTableCell.h"
#import "ProjectData.h"

@interface ProjectTableCell ()
@property (weak) IBOutlet NSTextField *labelView;
@end

@implementation ProjectTableCell

- (void)setProjectData:(ProjectData *)data
{
	self.labelView.stringValue = data.name;
}

@end
