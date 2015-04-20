//
//  Report.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "Report.h"

@implementation Report
@dynamic reportingUser;
@dynamic reportedUser;
@dynamic report;
@dynamic reportedImage;
@dynamic reportDescription;

+ (void)load {
    [self registerSubclass];

}

+ (NSString *)parseClassName {
    return @"Report";
}

- (PFFile *)convertImageToFile:(UIImage *)image
{
    return nil;
    
}

- (void)reportMatch:(UserParseHelper *)match byUser:(UserParseHelper *)user because:(NSString *)description inView:(UIViewController *)view
{
    self.reportingUser     = user;
    self.reportedUser      = match;
    self.reportDescription = description;
    //report.reportedImage     = [report convertImageToFile:_reportedUserImage.image];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [view dismissViewControllerAnimated:NO completion:nil];
        }
        
    }];
}

@end
