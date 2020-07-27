//
//  EditProjectViewController.m
//  Billing
//
//  Created by William Woody on 7/20/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "EditProjectViewController.h"
#import "ProjectData.h"
#import "ProjectPerson.h"
#import "FormatUtil.h"

@interface EditProjectViewController ()
@property (weak) IBOutlet NSTableView *contactTableView;
@property (weak) IBOutlet NSButton *createButton;
@property (weak) IBOutlet NSTextField *projectNameField;
@property (weak) IBOutlet NSTextField *hourlyRateField;
@property (weak) IBOutlet NSTextField *billingPrefixField;
@property (weak) IBOutlet NSTextField *billingStartIndexField;
@property (weak) IBOutlet NSTextView *fromAddressField;
@property (weak) IBOutlet NSTextView *toAddressField;
@property (weak) IBOutlet NSTextView *salutationField;
@property (weak) IBOutlet NSTextField *einField;

@property (strong) NSMutableArray<ProjectPerson *> *contacts;

@end

@implementation EditProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.editData == nil) {
		/*
		 *	Create new record
		 */
		self.editData = [[ProjectData alloc] init];
		self.contacts = [[NSMutableArray alloc] init];
		self.hourlyRateField.stringValue = @"$90.00";
		self.billingPrefixField.stringValue = @"B";
		self.billingStartIndexField.stringValue = @"1";
		
    } else {
		/*
		 *	Edit existing record by unboxing into our fields
		 */
		
		self.projectNameField.stringValue = self.editData.name;
		
		char buffer[32];
		FormatAmount((uint32_t)self.editData.billingRate,buffer);
		self.hourlyRateField.stringValue = [NSString stringWithUTF8String:buffer];
		
		NSString *f = [NSString stringWithFormat:@"%d",(int)self.editData.billingStartIndex];
		self.billingStartIndexField.stringValue = f;
		
		self.billingPrefixField.stringValue = self.editData.billingPrefix;
		
		self.contacts = [[NSMutableArray alloc] initWithArray:self.editData.persons];
		
		self.fromAddressField.string = self.editData.fromAddress;
		self.toAddressField.string = self.editData.toAddress;
		self.salutationField.string = self.editData.salutation;
		self.einField.stringValue = self.editData.einValue;
				
		[self.createButton setTitle:@"Update"];
	}
}

- (IBAction)doCancel:(id)sender
{
	if (self.closeCallback) self.closeCallback(nil);
}

- (IBAction)doCreate:(id)sender
{
	/*
	 *	Box the values and return
	 */
	
	ProjectData *data = [[ProjectData alloc] init];
	
	data.name = self.projectNameField.stringValue;
	data.billingRate = ParseAmount(self.hourlyRateField.stringValue.UTF8String);
	data.persons = self.contacts;
	data.billingPrefix = self.billingPrefixField.stringValue;
	data.billingStartIndex = [self.billingStartIndexField integerValue];
	
	data.fromAddress = self.fromAddressField.string;
	data.toAddress = self.toAddressField.string;
	data.salutation = self.salutationField.string;
	data.einValue = self.einField.stringValue;
	
	if (self.closeCallback) self.closeCallback(data);
}


/*
 *	Table cell management
 */

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.contacts.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	ProjectPerson *p = self.contacts[row];
	
	if ([tableColumn.identifier isEqualToString:@"name"]) {
		return p.username;
	} else if ([tableColumn.identifier isEqualToString:@"email"]) {
		return p.email;
	} else {
		return @"";
	}
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *value = object;
	ProjectPerson *p = self.contacts[row];
	
	if ([tableColumn.identifier isEqualToString:@"name"]) {
		p.username = value;
	} else if ([tableColumn.identifier isEqualToString:@"email"]) {
		p.email = value;
	}
}

- (IBAction)addPerson:(id)sender
{
	ProjectPerson *p = [[ProjectPerson alloc] init];
	p.username = @"name";
	p.email = @"email";
	[self.contacts addObject:p];
	
	[self.contactTableView reloadData];
}

- (IBAction)deletePerson:(id)sender
{
	NSInteger sel = self.contactTableView.selectedRow;
	if (sel >= 0) {
		NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:sel];
		[self.contactTableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideUp];
	}
}


@end
