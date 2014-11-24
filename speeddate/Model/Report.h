//
//  Report.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"


@interface Report : PFObject <PFSubclassing>
@property (nonatomic, strong) UserParseHelper *user;
@property NSNumber *report;
@end
