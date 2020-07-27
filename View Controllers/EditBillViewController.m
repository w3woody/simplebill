//
//  EditBillViewController.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "EditBillViewController.h"
#import "TimeDataRecord.h"
#import "ProjectData.h"
#import "BillData.h"
#import "Database.h"
#import "GregorianDate.h"
#import "FormatUtil.h"
#import "PrintBillView.h"

@interface EditBillViewController () 
@property (weak) IBOutlet NSTableView *tableView;
@property (strong) NSMutableArray<TimeDataRecord *> *timeData;
@property (weak) IBOutlet NSTextField *billIDLabel;
@property (weak) IBOutlet NSTextField *hoursLabel;
@property (weak) IBOutlet NSTextField *rateLabel;
@property (weak) IBOutlet NSTextField *amountLabel;
@property (weak) IBOutlet NSTextField *noteField;
@end

@implementation EditBillViewController

- (void)viewDidLoad
{
	char buffer[32];
	
    [super viewDidLoad];
    
    ProjectData *data = [self.database projectAtIndex:self.selectedProject];
    
    /*
     *	Set up the label, timesheet data, billing data.
	 */
	 
	self.timeData = [[NSMutableArray alloc] init];
	[self.selectedTimeData enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		TimeDataRecord *tdr = [self.database timeRecord:idx inProject:self.selectedProject];
		if (tdr.billID == 0) {
			[self.timeData addObject:tdr];
		}
	}];
	
	NSInteger hourTotal = 0;
	for (TimeDataRecord *tdr in self.timeData) {
		hourTotal += tdr.hours;
	}
	
	self.billIDLabel.stringValue = [self.database nextBillForProject:self.selectedProject];
	
	FormatHour((uint32_t)hourTotal, buffer);
	self.hoursLabel.stringValue = [NSString stringWithUTF8String:buffer];
	
	FormatAmount((uint32_t)data.billingRate, buffer);
	self.rateLabel.stringValue = [NSString stringWithUTF8String:buffer];
	
	uint32_t total = (uint32_t)((data.billingRate * hourTotal)/60);
	FormatAmount((uint32_t)total, buffer);
	self.amountLabel.stringValue = [NSString stringWithUTF8String:buffer];
	
	[self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.timeData count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	char buffer[32];
	
	TimeDataRecord *tr = self.timeData[row];
	
	if ([tableColumn.identifier isEqualToString:@"date"]) {
		GregorianShortFormat(tr.dayCount, buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"hours"]) {
		FormatHour(tr.hours, buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"description"]) {
		return tr.itemDesc;
	} else {
		return @"";
	}
}


- (IBAction)doCancel:(id)sender
{
	if (self.closeCallback) self.closeCallback(NO);
}

- (IBAction)doPrint:(id)sender
{
	/*
	 *	Actually generate our bill, and set up to print.
	 */
	 
	uint32_t today = GregorianCurrentDate();
	BillData *data = [self.database generateBillForProject:self.selectedProject withTimeRecords:self.selectedTimeData onDate:today comments:self.noteField.stringValue];
	
	PrintBillView *v = [[PrintBillView alloc] initWithBill:@[ data ]];
	[[NSPrintOperation printOperationWithView:v] runOperation];
	 
	if (self.closeCallback) self.closeCallback(YES);
}

@end
