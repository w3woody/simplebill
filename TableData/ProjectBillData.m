//
//  ProjectBillData.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectBillData.h"
#import "BillData.h"
#import "Database.h"
#import "Constants.h"
#import "ProjectData.h"
#import "FormatUtil.h"
#import "GregorianDate.h"

@interface ProjectBillData ()
@property (weak, nonatomic) IBOutlet NSTableView *tableView;

@property (weak) Database *database;
@end

@implementation ProjectBillData

- (instancetype)init
{
	if (nil != (self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStart:) name:NOTIFICATION_DATABASESTARTED object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didStart:(NSNotification *)n
{
	[self.tableView reloadData];
}

/*
 *	Load the data into our table
 */

- (void)loadData:(Database *)database
{
	self.database = database;
	[self.tableView reloadData];
}

- (void)refreshData
{
	[self.tableView reloadData];
}

- (NSIndexSet *)selectedIndexes
{
	return [self.tableView selectedRowIndexes];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.database numberOfBills];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	char buffer[32];
	
	BillData *bdata = [self.database billAtIndex:row];
	
	if ([tableColumn.identifier isEqualToString:@"project"]) {
		return bdata.project.name;
	} else if ([tableColumn.identifier isEqualToString:@"paid"]) {
		return @( bdata.paid );
	} else if ([tableColumn.identifier isEqualToString:@"billid"]) {
		return bdata.billID;
	} else if ([tableColumn.identifier isEqualToString:@"date"]) {
		GregorianFormat((uint32_t)bdata.date,buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"amount"]) {
		FormatAmount((uint32_t)bdata.rate,buffer);
		return [NSString stringWithUTF8String:buffer];
	} else if ([tableColumn.identifier isEqualToString:@"notes"]) {
		return bdata.notes;
	} else {
		return @"";
	}
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier isEqualToString:@"paid"]) {
		[self.database setIsPaid:[object boolValue] forBillAtIndex:row];
	} else if ([tableColumn.identifier isEqualToString:@"notes"]) {
		[self.database updateNote:(NSString *)object forBillAtIndex:row];
	}
}

@end
