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
@property UserParseHelper *reportingUser;
@property UserParseHelper *reportedUser;
@property NSNumber *report;
@property PFFile *reportedImage;
@property NSString *reportDescription;

- (PFFile *)convertImageToFile:(UIImage *)image;
- (void)reportMatch:(UserParseHelper *)match byUser:(UserParseHelper *)user because:(NSString *)description inView:(UIViewController *)view;

@end
