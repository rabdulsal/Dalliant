//
//  PossibleMatchHelper.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"

@interface PossibleMatchHelper : PFObject <PFSubclassing>
@property (nonatomic, strong) UserParseHelper* fromUser;
@property (nonatomic, strong) UserParseHelper* toUser;
@property NSString* fromUserEmail;
@property NSString* toUserEmail;
@property NSString* toUserApproved;
@property NSString* match;
@end
