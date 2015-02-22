//
//  PossibleMatch.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "PossibleMatchHelper.h"
#import <MDRadialProgressLabel.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressView.h>

@implementation PossibleMatchHelper
@dynamic fromUser;
@dynamic toUser;
@dynamic fromUserEmail;
@dynamic toUserEmail;
@dynamic toUserApproved;
@dynamic match;
@dynamic prefCounter;
@dynamic totalPrefs;
@dynamic compatibilityIndex;
@dynamic usersRevealed;
@dynamic matches;

+ (void)load {
    [self registerSubclass];
}



+ (NSString *)parseClassName {
    return @"PossibleMatch";
}

- (void)calculateCompatibility:(double)prefCounter with:(double)totalPreferences
{
    //NSNumber *indexCalculation = @20.1;
    
    double indexCalculation = (prefCounter / totalPreferences)*100;
    self.compatibilityIndex = [NSNumber numberWithDouble:(indexCalculation)];
    //return *(self.compatibilityIndex);
}

- (void)setHighCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = RED_DEEP;
    newTheme.incompletedColor   = RED_LIGHT;
    newTheme.centerColor        = RED_OMNY;
}

- (void)setMedCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = [UIColor colorWithRed:0.8 green:0.8 blue:0 alpha:1.0];
    newTheme.incompletedColor   = [UIColor colorWithRed:0.9 green:0.9 blue:0 alpha:1.0];
    //newTheme.centerColor        = YELLOW_COLOR;
    newTheme.centerColor        = [UIColor colorWithRed:1 green:1 blue:0.6 alpha:1];
}

- (void)setLowCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = [UIColor darkGrayColor];
    newTheme.incompletedColor   = [UIColor lightGrayColor];
    newTheme.centerColor        = GRAY_COLOR;
}

- (void)configureRadialViewForView:(UIView *)view withFrame:(CGRect)frame
{
    MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
    //newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
    
    //newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
    newTheme.centerColor = [UIColor clearColor];
    //[self setHighCompatibilityColor:newTheme];
    NSInteger compatibility = [self.compatibilityIndex integerValue];
    // Compatibility conditional
    if (compatibility > 66) {
        [self setHighCompatibilityColor:newTheme];
    } else if (compatibility < 66 && compatibility > 33) {
        [self setMedCompatibilityColor:newTheme];
    } else [self setLowCompatibilityColor:newTheme];
    
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor blackColor];
    newTheme.labelShadowColor = [UIColor whiteColor];
    
    
    MDRadialProgressView *radialView7 = [[MDRadialProgressView alloc] initWithFrame:frame andTheme:newTheme];
    radialView7.progressTotal   = [self.totalPrefs integerValue];
    radialView7.progressCounter = [self.prefCounter integerValue];
    //[self.view addSubview:radialView7];
    [view addSubview:radialView7];
}

@end
