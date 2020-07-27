//
//  EditTimeViewController.m
//  Billing
//
//  Created by William Woody on 7/23/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "EditTimeViewController.h"
#import "NSDateView.h"
#import "TimeDataRecord.h"
#import "FormatUtil.h"

@interface EditTimeViewController ()
@property (weak) IBOutlet NSTextField *descriptionField;
@property (weak) IBOutlet NSDateView *dateView;
@property (weak) IBOutlet NSTextField *hoursField;
@property (weak) IBOutlet NSButton *createButton;
@end

@implementation EditTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.editRecord == nil) {
		self.hoursField.stringValue = @"8";
		
    } else {
		char buffer[64];
		
		FormatHour(self.editRecord.hours, buffer);
		
		self.descriptionField.stringValue = self.editRecord.itemDesc;
		self.hoursField.stringValue = [NSString stringWithUTF8String:buffer];
		self.dateView.selectedDate = self.editRecord.dayCount;
				
		[self.createButton setTitle:@"Update"];
	}
}


- (IBAction)doCancel:(id)sender
{
	if (self.closeCallback) self.closeCallback(nil);
}

- (IBAction)doCreate:(id)sender
{
	TimeDataRecord *tr = [[TimeDataRecord alloc] init];
	
	tr.itemDesc = self.descriptionField.stringValue;
	tr.dayCount = self.dateView.selectedDate;

	const char *buf = self.hoursField.stringValue.UTF8String;
	tr.hours = ParseHour(buf);

	if (self.closeCallback) self.closeCallback(tr);
}

@end
