//
//  ProjectPerson.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "ProjectPerson.h"

@implementation ProjectPerson

- (instancetype)init
{
	if (nil != (self = [super init])) {
		self.username = @"";
		self.email = @"";
		self.comment = @"";
	}
	return self;
}

- (instancetype)initWithJSON:(NSDictionary *)json
{
	if (nil != (self = [super init])) {
		self.username = (NSString *)json[@"username"];
		self.email = (NSString *)json[@"email"];
		self.comment = (NSString *)json[@"comment"];
	}
	return self;
}

- (NSDictionary *)asJson
{
	return @{ @"username": self.username,
			  @"email": self.email,
			  @"comment": self.comment };
}

@end
