//
//  RevealRequest.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/17/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <Parse/Parse.h>

@interface RevealRequest : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *requestFromUser;
@property (retain) NSString *requestToUser;
@property (retain) NSString *requestReply;

@end
