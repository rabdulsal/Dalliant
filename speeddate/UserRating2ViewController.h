//
//  UserRating2ViewController.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/21/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"

@interface UserRating2ViewController : UIViewController

@property UserParseHelper *matchUser;
@property UserParseHelper *user;
@property PossibleMatchHelper *relationship;
@property UIImage *matchUserImage;

@end
