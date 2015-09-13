//
//  ReportViewController.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/19/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserParseHelper.h"

@interface ReportViewController : UIViewController

@property UserParseHelper *user;
@property UserParseHelper *matchUser;
@property (weak, nonatomic) IBOutlet UILabel *reportedUser;
@property UIImage *reportedImage;

@end
