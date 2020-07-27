//
//  NSDateView.m
//  Billing
//
//  Created by William Woody on 7/23/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "NSDateView.h"
#import "GregorianDate.h"

#define CAL_BUTTONWIDTH			22
#define CAL_MONTHBORDER			22
#define CAL_TOPBORDER			38

static const char *GWeek[] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };

@interface NSDateView ()
{
	uint32_t today;
	uint32_t selected;
	
	uint8_t firstDOW;
	uint8_t mheight;
	uint8_t mlength;
	uint8_t month;
	uint16_t year;
}
@end

@implementation NSDateView

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if (nil != (self = [super initWithCoder:coder])) {
		[self internalInit];
	}
	return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (nil != (self = [super initWithFrame:frameRect])) {
		[self internalInit];
	}
	return self;
}

- (void)internalInit
{
	today = GregorianCurrentDate();
	[self setSelectedDate:today];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setSelectedDate:(uint32_t)day
{
	selected = day;
	
	/*
	 *	Set month, year
	 */
	 
	CalendarDate d = GregorianCalendar(day);
	month = d.month;
	year = d.year;
	
	[self reload];
}

- (uint32_t)selectedDate
{
	return selected;
}

- (void)reload
{
	/*
	 *	Find the first of the month
	 */
	 
	uint32_t dfirst = GregorianCount(1, month, year);
	firstDOW = GregorianDayOfWeek(dfirst);
	
	mlength = GregorianDaysInMonth(month, year);
	mheight = (firstDOW + mlength + 6)/7;
	
	[self setNeedsDisplay:TRUE];
}

- (NSRect)calcLeft
{
	return NSMakeRect(0, 0, CAL_BUTTONWIDTH, CAL_MONTHBORDER);
}

- (NSRect)calcRight
{
	NSRect size = self.bounds;
	
	return NSMakeRect(size.size.width - CAL_BUTTONWIDTH, 0, CAL_BUTTONWIDTH, CAL_MONTHBORDER);
}

- (NSRect)calcMonth
{
	NSRect size = self.bounds;
	
	return NSMakeRect(CAL_BUTTONWIDTH,0,size.size.width - 2 * CAL_BUTTONWIDTH, CAL_MONTHBORDER);
}

- (NSRect)calcWeekCell:(NSInteger)index
{
	NSRect size = self.bounds;
	
	NSInteger width = (NSInteger)size.size.width;
	NSInteger left = (width * index) / 7;
	NSInteger right = (width * (index + 1))/7;
	
	size.origin.x = left;
	size.origin.y = CAL_MONTHBORDER;
	size.size.width = right - left;
	size.size.height = CAL_TOPBORDER - CAL_MONTHBORDER;
	
	return size;
}

- (NSRect)calcDayCell:(NSInteger)index height:(NSInteger)rows
{
	NSRect size = self.bounds;
	NSInteger xpos = index % 7;
	NSInteger ypos = index / 7;
	
	NSInteger width = (NSInteger)size.size.width;
	NSInteger left = (width * xpos) / 7;
	NSInteger right = (width * (xpos + 1))/7;
	
	NSInteger height = (NSInteger)(size.size.height - CAL_TOPBORDER);
	NSInteger top = CAL_TOPBORDER + (height * ypos)/rows;
	NSInteger bottom = CAL_TOPBORDER + (height * (ypos + 1))/rows;
	
	size.origin.x = left;
	size.origin.y = top;
	size.size.width = right - left;
	size.size.height = bottom - top;
	
	return size;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    /*
     *	Draw month header
	 */
	
	NSRect r = [self calcLeft];
	NSImage *image = [NSImage imageNamed:@"Left"];
	r.origin.x += (r.size.width - 16)/2;
	r.origin.y += (r.size.height - 16)/2;
	r.size.width = 16;
	r.size.height = 16;
	[image drawInRect:r];
	
	r = [self calcRight];
	image = [NSImage imageNamed:@"Right"];
	r.origin.x += (r.size.width - 16)/2;
	r.origin.y += (r.size.height - 16)/2;
	r.size.width = 16;
	r.size.height = 16;
	[image drawInRect:r];

	/*
	 *	Draw the month
	 */

	NSString *str = [NSString stringWithFormat:@"%s %d",GregorianMonthName(month),year];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.alignment = NSTextAlignmentCenter;
    NSDictionary *d = @{ NSFontAttributeName: [NSFont systemFontOfSize: NSFont.labelFontSize],
						 NSForegroundColorAttributeName: NSColor.blackColor,
						 NSParagraphStyleAttributeName: style };
    NSDictionary *td = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:NSFont.labelFontSize],
						 NSForegroundColorAttributeName: NSColor.blackColor,
						 NSParagraphStyleAttributeName: style };
						 
	r = [self calcMonth];
    CGFloat textHeight = [str boundingRectWithSize: r.size options: NSStringDrawingUsesLineFragmentOrigin attributes: d].size.height;
    
    r.origin.y += (r.size.height - textHeight)/2;

	[str drawInRect:r withAttributes:d];
	
	/*
	 *	Draw the weeks
	 */
	 
	for (uint8_t i = 0; i < 7; ++i) {
		r = [self calcWeekCell:i];
		r.origin.y += (r.size.height - textHeight)/2;
		
		[[NSString stringWithUTF8String:GWeek[i]] drawInRect:r withAttributes:d];
	}
	
	/*
	 *	Draw the days
	 */
	 
	uint32_t dstart = GregorianCount(1, month, year);
	for (uint8_t i = 1; i <= mlength; ++i) {
		uint8_t dpos = i + firstDOW - 1;
		NSRect r = [self calcDayCell:dpos height:mheight];
		NSRect rc = CGRectInset(r, -2, -2);
		
		if (rc.size.width > rc.size.height) {
			rc.origin.x += (rc.size.width - rc.size.height)/2;
			rc.size.width = rc.size.height;
		} else {
			rc.origin.y += (rc.size.height - rc.size.width)/2;
			rc.size.height = rc.size.width;
		}

		r.origin.y += (r.size.height - textHeight)/2;
		if (dstart == selected) {
			NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rc];
			[NSColor.grayColor setStroke];
			path.lineWidth = 1;
			[path stroke];
		}
		
		[[NSString stringWithFormat:@"%d",(int)i] drawInRect:r withAttributes:(dstart == today) ? td : d];

		++dstart;
	}
}

- (void)mouseUp:(NSEvent *)event
{
	CGPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (CGRectContainsPoint([self calcLeft], pt)) {
		--month;
		if (month < 1) {
			--year;
			month = 12;
		}
		[self reload];
	} else if (CGRectContainsPoint([self calcRight], pt)) {
		++month;
		if (month > 12) {
			++year;
			month = 1;
		}
		[self reload];
	} else {
		/*
		 *	Run through the days
		 */
		 
		uint32_t dstart = GregorianCount(1, month, year);
		for (uint8_t i = 1; i <= mlength; ++i) {
			uint8_t dpos = i + firstDOW - 1;
			NSRect r = [self calcDayCell:dpos height:mheight];
			
			if (CGRectContainsPoint(r, pt)) {
				/*
				 *	Select
				 */
				
				[self setSelectedDate:dstart];
				return;
			}
			++dstart;
		}
	}
}

- (void)mouseDown:(NSEvent *)event
{
}

- (void)mouseMoved:(NSEvent *)event
{
}

- (void)mouseDragged:(NSEvent *)event
{
}

@end
