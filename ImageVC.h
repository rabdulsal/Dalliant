//
//  ImageVC.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 3/9/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserParseHelper.h"
#import "FLAnimatedImage.h"

@interface ImageVC : UIViewController

@property NSURL *gifURL;
@property UIImage *image;
@property UserParseHelper *user;
@property UserParseHelper *matchUser;

@end
