//
//  MainViewController.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "MainViewController.h"
#import "ProjectTableData.h"
#import "EditProjectViewController.h"
#import "Database.h"
#import "ProjectPerson.h"
#import "ProjectTimeData.h"
#import "ProjectBillData.h"
#import "EditTimeViewController.h"
#import "EditBillViewController.h"
#import "PrintBillView.h"

@interface MainViewController ()
@property (weak) Database *database;
@property (strong) IBOutlet ProjectTableData *projectData;
@property (strong) IBOutlet ProjectTimeData *projectTimeData;
@property (strong) IBOutlet ProjectBillData *projectBillData;
@property (weak) IBOutlet NSTabView *tabView;

@property (assign) BOOL createProject;
@property (assign) NSInteger editProject;

@property (assign) BOOL createTimesheet;
@property (assign) NSInteger editTimesheet;
@end

@implementation MainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.database = Database.shared;
	
	__weak MainViewController *pthis = self;
	
	[self.projectData loadData:self.database];
	self.projectData.selectProject = ^(NSInteger index) {
		pthis.editProject = index;
		[pthis.projectTimeData setProject:index];
	};
	self.projectData.editProject = ^(NSInteger index) {
		pthis.createProject = NO;
		pthis.editProject = index;
		if (index >= 0) {
			[pthis performSegueWithIdentifier:@"editProjectSegue" sender:pthis];
		}
	};
	
	[self.projectTimeData loadData:self.database];
	self.projectTimeData.selectTime = ^(NSInteger projID, NSInteger index) {
		// Does this do anything?
	};
	self.projectTimeData.editTime = ^(NSInteger projID, NSInteger index) {
		pthis.createTimesheet = NO;
		pthis.editProject = projID;
		pthis.editTimesheet = index;
		if (index >= 0) {
			[pthis performSegueWithIdentifier:@"editTimeSegue" sender:pthis];
		}
	};
	
	[self.projectBillData loadData:self.database];
}

- (IBAction)doNewProject:(id)sender
{
	self.createProject = YES;
	[self performSegueWithIdentifier:@"editProjectSegue" sender:self];
}

- (IBAction)doNewTimesheet:(id)sender
{
	[self.tabView selectTabViewItemAtIndex:0];
	
	self.createTimesheet = YES;
	[self performSegueWithIdentifier:@"editTimeSegue" sender:self];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"editProjectSegue"]) {
		__weak EditProjectViewController *vc = segue.destinationController;
		
		NSInteger selectedProject = self.editProject;
		if (!self.createProject) {
			vc.editData = [self.database projectAtIndex:selectedProject];
		}
		
		vc.closeCallback = ^(ProjectData *p) {
			/*
			 *	TODO: If p present, add or update.
			 */
			
			if (p != nil) {
				if (self.createProject) {
					[self.database addProject:p];
				} else {
					[self.database setProject:p atIndex:selectedProject];
				}
				[self.projectData refreshData];
			}
			
			[self dismissViewController:vc];
		};
	} else if ([segue.identifier isEqualToString:@"editTimeSegue"]) {
		__weak EditTimeViewController *vc = segue.destinationController;
		
		NSInteger selectedProject = self.editProject;
		NSInteger selectedTime = self.editTimesheet;
		if (!self.createTimesheet) {
			vc.editRecord = [self.database timeRecord:selectedTime inProject:selectedProject];
		}
		
		vc.closeCallback = ^(TimeDataRecord *data) {
			if (data != nil) {
				if (self.createTimesheet) {
					[self.database addTimeRecord:data inProject:selectedProject];
				} else {
					[self.database setTimeRecord:data inProject:selectedProject atIndex:selectedTime];
				}
				[self.projectTimeData refreshData];
			}
			
			[self dismissViewController:vc];
		};
	} else if ([segue.identifier isEqualToString:@"editBillSegue"]) {
		__weak EditBillViewController *vc = segue.destinationController;
		
		vc.database = self.database;
		vc.selectedProject = self.projectData.selectedIndex;
		vc.selectedTimeData = self.projectTimeData.selectedIndexes;
		
		vc.closeCallback = ^(BOOL update) {
			if (update) {
				[self.projectTimeData refreshData];
				[self.projectBillData refreshData];
				
				[self.tabView selectTabViewItemAtIndex:1];
			}
			[self dismissViewController:vc];
		};
	}
}


/*
 *	Generate bill from selected list
 */

- (IBAction)newBill:(id)sender
{
	/*
	 *	New bill only works if we have items selected
	 */
	
	NSTabViewItem *item = self.tabView.selectedTabViewItem;
	if ([self.tabView indexOfTabViewItem:item] != 0) return;
	
	[self performSegueWithIdentifier:@"editBillSegue" sender:self];
}

- (IBAction)doPrint:(id)sender
{
	/*
	 *	If we have any bills selected, print them
	 */
	
	NSTabViewItem *item = self.tabView.selectedTabViewItem;
	if ([self.tabView indexOfTabViewItem:item] != 1) return;
	
	NSIndexSet *set = [self.projectBillData selectedIndexes];
	if ([set count] == 0) return;
	
	NSMutableArray<BillData *> *list = [[NSMutableArray alloc] init];
	[set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		BillData *data = [self.database billAtIndex:idx];
		[list addObject:data];
	}];
	
	PrintBillView *view = [[PrintBillView alloc] initWithBill:list];
	[[NSPrintOperation printOperationWithView:view] runOperation];
}

@end
