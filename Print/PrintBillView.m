//
//  PrintBillView.m
//  Billing
//
//  Created by William Woody on 7/26/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "PrintBillView.h"
#import "PrintBlock.h"
#import "PrintPageFlow.h"
#import "GregorianDate.h"
#import "FormatUtil.h"
#import "BillData.h"
#import "ProjectData.h"
#import "TimeDataRecord.h"
#import "ProjectPerson.h"

/*
 *	Printer
 */

@interface PrintBillView ()
{
	NSSize paperSize;
	
	NSMutableArray<PrintPageFlow *> *pages;
}
@end

@implementation PrintBillView

- (instancetype)initWithBill:(NSArray<BillData *> *)data
{
	if (nil != (self = [super initWithFrame:CGRectZero])) {
		/*
		 *	Preflight styles
		 */
		 
		NSMutableParagraphStyle *centerPara = [[NSMutableParagraphStyle alloc] init];
		centerPara.alignment = NSTextAlignmentCenter;
		 
		NSMutableParagraphStyle *rightPara = [[NSMutableParagraphStyle alloc] init];
		centerPara.alignment = NSTextAlignmentRight;
		
		NSFont *small = [NSFont fontWithName:@"Helvetica" size:9];
		NSFont *normal = [NSFont fontWithName:@"Helvetica" size:11];
		NSFont *title = [NSFont fontWithName:@"Helvetica" size:22];
		
		NSDictionary *centerSmallAttr;
		NSDictionary *pageNumberAttr;
		NSDictionary *normalTextAttr;
		NSDictionary *titleTextAttr;
		
		centerSmallAttr = @{ NSFontAttributeName: small,
							 NSForegroundColorAttributeName: [NSColor blackColor],
							 NSParagraphStyleAttributeName: centerPara
		};
		pageNumberAttr = @{ NSFontAttributeName: small,
							NSForegroundColorAttributeName: [NSColor blackColor],
							NSParagraphStyleAttributeName: rightPara
		};
		normalTextAttr = @{ NSFontAttributeName: normal,
							NSForegroundColorAttributeName: [NSColor blackColor]
		};
		titleTextAttr = @{ NSFontAttributeName: title,
							NSForegroundColorAttributeName: [NSColor blackColor]
		};
		
		/*
		 *	Get the page size
		 */
		 
		NSPrintInfo *pi = [[NSPrintOperation currentOperation] printInfo];
		if (pi == nil) pi = [NSPrintInfo sharedPrintInfo];
		paperSize = pi.paperSize;
		
		NSEdgeInsets margins = NSEdgeInsetsMake(72, 72, 108, 72);		// 1.5" bottom margin for page number
		
		/*
		 *	Format the pages.
		 */
		 
		pages = [[NSMutableArray alloc] init];
		
		for (BillData *b in data) {
			char buffer[128];
			PrintBlock *block;
			
			/*
			 *	Generate a new page for each, and add the header data.
			 */
			
			NSInteger pageIndex = pages.count;
			PrintPageFlow *p = [[PrintPageFlow alloc] initWithSize:CGRectMake(0, paperSize.height * pageIndex, paperSize.width, paperSize.height) margins:margins];
			
			[pages addObject:p];
			
			/*
			 *	Add a page number. Only done for pages past page 1.
			 */
			
			if (pageIndex > 0) {
				NSString *pageNumber = [NSString stringWithFormat:@"%d",(int)pageIndex];
				
				CGRect r = CGRectMake(paperSize.width - 216, paperSize.height - 108, 144, 36);
				block = [[PrintBlock alloc] initWithText:pageNumber attributes:pageNumberAttr at:r];
				[p insertBlock:block];
			}
			
			/*
			 *	Add bill ID title
			 */
			
			CGRect r = CGRectMake(72, 72, 288, 36);
			NSString *invoice = [NSString stringWithFormat:@"Invoice #%@",b.billID];
			block = [[PrintBlock alloc] initWithText:invoice attributes:titleTextAttr at:r];
			[p insertBlock:block];
			
			/*
			 *	Add the date and from address
			 */
			
			r = CGRectMake(324,0,paperSize.width-324-72,72);
			GregorianLongFormat((uint32_t)b.date, buffer);
			block = [[PrintBlock alloc] initWithText:[NSString stringWithUTF8String:buffer] attributes:normalTextAttr at:r];
			[p insertFlowingBlock:block withMargin:12];
			
			block = [[PrintBlock alloc] initWithText:b.project.fromAddress attributes:normalTextAttr at:r];
			[p insertFlowingBlock:block withMargin:12];
			
			/*
			 *	Add the too address and salutation block
			 */
			
			r = CGRectMake(72,0,paperSize.width - 144,144);
			block = [[PrintBlock alloc] initWithText:b.project.toAddress attributes:normalTextAttr at:r];
			[p insertFlowingBlock:block withMargin:12];
			
			r = CGRectMake(72,0,paperSize.width - 144,144);
			block = [[PrintBlock alloc] initWithText:b.project.salutation attributes:normalTextAttr at:r];
			[p insertFlowingBlock:block withMargin:24];
			
			/*
			 *	 
			 */
		}
		
		/*
		 *	Calculate frame
		 */
		 
		NSInteger numPages = pages.count;
		if (numPages == 0) {
			PrintPageFlow *empty = [[PrintPageFlow alloc] initWithSize:CGRectMake(0, 0, paperSize.width, paperSize.height) margins:margins];
			[pages addObject:empty];
			
			PrintBlock *block = [[PrintBlock alloc] initWithText:@"No bill data was selected." attributes:centerSmallAttr at:CGRectMake(0, 144, paperSize.width, 72)];
			[empty insertBlock:block];
			
			numPages = 1;
		}
		self.frame = CGRectMake(0,0,paperSize.width,paperSize.height * numPages);
	}
	return self;
}

#pragma mark - Print Pagination

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)knowsPageRange:(NSRangePointer)range
{
	range->location = 1;
	range->length = 1;
	return YES;
}

- (NSRect)rectForPage:(NSInteger)page
{
	/* We simply return the page size */
	return CGRectMake(0, paperSize.height * (page - 1), paperSize.width, paperSize.height);
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSInteger page = (int)floor(dirtyRect.origin.y / paperSize.height + 0.5) + 1;
	
	PrintPageFlow *pageFlow = pages[page-1];
	[pageFlow draw];
}

@end
