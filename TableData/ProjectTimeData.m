//
//  ProjectTimeData.m
//  Billing
//
//  Created by William Woody on 7/22/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectTimeData.h"
#import "Database.h"
#import "ProjectTimeData.h"
#import "TimeDataRecord.h"
#import "FormatUtil.h"
#import "GregorianDate.h"

@interface ProjectTimeData ()
@property (weak, nonatomic) IBOutlet NSTableView *tableView;

@property (weak) Database *database;
@property (assign) NSInteger projectIndex;
@end

@implementation ProjectTimeData

- (instancetype)init
{
	if (nil != (self = [super init])) {
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 *	Load the data into our table
 */

- (void)loadData:(Database *)database
{
	self.database = database;
}

- (void)setProject:(NSInteger)projectIndex;
{
	self.projectIndex = projectIndex;
	[self refreshData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.database numberOfTimeRecordsInProject:self.projectIndex];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	char buffer[32];
	TimeDataRecord *tdata = [self.database timeRecord:row inProject:self.projectIndex];
	
	if ([tableColumn.identifier isEqualToString:@"billed"]) {
		// Should be handled with more finesse.
		if (tdata.billID == 0) return @"";
		return [NSString stringWithFormat:@"%d",(int)tdata.billID];
	} else if ([tableColumn.identifier isEqualToString:@"date"]) {
		GregorianFormat(tdata.dayCount,buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"hours"]) {
		FormatHour(tdata.hours, buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"description"]) {
		return tdata.itemDesc;
	} else {
		return @"";
	}
}

- (void)refreshData
{
	[self.tableView reloadData];
}

- (NSInteger)selectedIndex
{
	return [self.tableView selectedRow];
}

- (NSIndexSet *)selectedIndexes
{
	return [self.tableView selectedRowIndexes];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if (self.selectTime) {
		self.selectTime(self.projectIndex, self.selectedIndex);
	}
}

- (IBAction)doDoubleClick:(id)sender
{
	if (self.editTime) {
		self.editTime(self.projectIndex, self.selectedIndex);
	}
}

@end
