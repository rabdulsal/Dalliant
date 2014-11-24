//
//  UserProfileViewController.h
//  speeddate
//
//  Created by studio76 on 20.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "UserParseHelper.h"

@interface UserProfileViewController : UIViewController<UIScrollViewDelegate>{
    
    UserParseHelper* mainUser;
    UIImageView *profileImage;
    NSMutableArray *photoUserArray;
    UILabel *nameUser;
    UILabel *ageUser;
    UILabel *descriptionUser;
    UIActivityIndicatorView *loadImageView;
}

@property (retain, nonatomic)UserParseHelper* mainUser;
@property (copy,nonatomic) NSString *userId;
@property (copy,nonatomic) NSString *status;
@property (copy,nonatomic) NSMutableArray *getPhotoArray;
@property (nonatomic,retain) IBOutlet  UIImageView *profileImage;
@property (nonatomic,retain) NSMutableArray *photoUserArray;
@property (nonatomic,retain) IBOutlet UILabel *nameUser;
@property (nonatomic,retain) IBOutlet  UILabel *ageUser;
@property (nonatomic,retain) IBOutlet UILabel *descriptionUser;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loadImageView;

-(IBAction)chat:(id)sender;

@end
