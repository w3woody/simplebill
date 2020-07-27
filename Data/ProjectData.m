//
//  ProjectData.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectData.h"
#import "ProjectPerson.h"

@implementation ProjectData

- (instancetype)init
{
	if (nil != (self = [super init])) {
		self.name = @"";
		self.persons = [[NSMutableArray alloc] init];
		self.billingPrefix = @"B";
		self.billingStartIndex = 1;
	}
	return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json
{
	if (nil != (self = [super init])) {
		self.name = (NSString *)json[@"name"];
		self.billingRate = [json[@"billingRate"] integerValue];
		self.billingPrefix = (NSString *)json[@"billingPrefix"];
		self.billingStartIndex = [json[@"billingStartIndex"] integerValue];

		self.fromAddress = (NSString *)json[@"fromAddress"];
		self.toAddress = (NSString *)json[@"toAddress"];
		self.salutation = (NSString *)json[@"salutation"];
		self.einValue = (NSString *)json[@"einValue"];

		self.persons = [[NSMutableArray alloc] init];
		NSArray *array = (NSArray *)json[@"persons"];
		for (NSDictionary *item in array) {
			[self.persons addObject:[[ProjectPerson alloc] initWithJSON:item]];
		}
	}
	return self;
}

- (NSDictionary *)asJson
{
	NSMutableArray<NSDictionary *> *list = [[NSMutableArray alloc] init];
	
	for (ProjectPerson *item in self.persons) {
		[list addObject:[item asJson]];
	}
	return @{ @"name": self.name,
			  @"billingRate": @( self.billingRate ),
			  @"billingPrefix": self.billingPrefix,
			  @"billingStartIndex": @( self.billingStartIndex ),
			  @"fromAddress": self.fromAddress,
			  @"toAddress": self.toAddress,
			  @"salutation": self.salutation,
			  @"einValue": self.einValue,
			  @"persons": list
	};
}

@end
