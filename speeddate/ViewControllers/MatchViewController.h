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
@property UIImage *matchImage1;
@property UIImage *matchImage2;
@property UIImage *matchImage3;
@property UserParseHelper *user;
@property UserParseHelper *matchUser;
@property (nonatomic) NSMutableArray *getPhotoArray;
@end
