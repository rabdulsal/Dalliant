//
//  UserRating.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/19/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"

@interface UserRating : PFObject <PFSubclassing>

@property UserParseHelper *toUser;
@property UserParseHelper *fromUser;
@property NSString *ratingType;
@property NSString *badRatingDescription;

@end
