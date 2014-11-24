//
//  User.m
//  Firechat
//
//  Created by Rashad Abdul-Salaam on 9/6/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "User.h"

@implementation User

+(User *)singleObj{
    static User * single=nil;
    
    @synchronized(self)
    {
        if (!single) {
            single = [[User alloc] init];
        }
    }
    return single;
}

- (id)init {
    self = [self initWithName:@"no first name"
                     lastName:@"no last name"
                       gender:@"no gender"];
    return self;
}

- (id)initWithName:(NSString *)aFirstName
          lastName:(NSString *)aLastName
            gender:(NSString *)aGender{
    self = [super init];
    if (self) {
        self.firstName = aFirstName;
        self.lastName = aLastName;
        self.gender = aGender;
    }
    return self;
}

@end
