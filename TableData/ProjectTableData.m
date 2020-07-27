//
//  ProjectTableData.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectTableData.h"
#import "ProjectTableCell.h"
#import "Database.h"
#import "Constants.h"

@interface ProjectTableData ()
@property (weak, nonatomic) IBOutlet NSTableView *tableView;

@property (weak) Database *database;
@end

@implementation ProjectTableData

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
	
	NSInteger len = [self.database numberOfProjects];
	if (len > 0) {
		NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:len-1];
		[self.tableView selectRowIndexes:set byExtendingSelection:NO];
	}
}

/*
 *	Load the data into our table
 */

- (void)loadData:(Database *)database
{
	self.database = database;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.database.numberOfProjects;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	ProjectTableCell *c = (ProjectTableCell *)[tableView makeViewWithIdentifier:@"projectView" owner:self];
	
	ProjectData *data = [self.database projectAtIndex:row];
	[c setProjectData:data];
	
	return c;
}

- (void)refreshData
{
	[self.tableView reloadData];
}

- (NSInteger)selectedIndex
{
	return [self.tableView selectedRow];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if (self.selectProject) {
		self.selectProject(self.selectedIndex);
	}
}

- (IBAction)doDoubleClick:(id)sender
{
	if (self.editProject) {
		self.editProject(self.selectedIndex);
	}
}

@end
