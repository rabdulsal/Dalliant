//
//  Report.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "Report.h"

@implementation Report
@dynamic user;
@dynamic report;

+ (void)load {
    [self registerSubclass];

}

+ (NSString *)parseClassName {
    return @"Report";
}

@end
