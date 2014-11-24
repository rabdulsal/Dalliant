//
//  MatchViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "UserParseHelper.h"

@interface MatchViewController : UIViewController
@property UIImage *userImage;
@property UIImage *matchImage;
@property UserParseHelper *user;
@property UserParseHelper *matchUser;
@end
