//
//  RedeemViewController.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 5/5/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PossibleMatchHelper.h"

@interface RedeemViewController : UIViewController

@property NSString *prizeID;
@property PossibleMatchHelper *matchRedmption;
@property UserParseHelper *currentUser;

@end
