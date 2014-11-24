//
//  WhoSeeMeHelper.h
//  speeddate
//
//  Created by studio76 on 21.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UserParseHelper.h"

@interface WhoSeeMeHelper : PFObject <PFSubclassing>

@property (nonatomic,strong) UserParseHelper *WhoSeeUser;
@property (nonatomic,strong) UserParseHelper *WhomSeeUser;

@property NSString *userSee;
@property NSString *seeUser;





@end
