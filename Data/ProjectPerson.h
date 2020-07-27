//
//  ProjectPerson.h
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectPerson : NSObject

@property (copy) NSString *username;
@property (copy) NSString *email;
@property (copy) NSString *comment;

- (instancetype)init;
- (instancetype)initWithJSON:(NSDictionary *)json;
- (NSDictionary *)asJson;

@end
