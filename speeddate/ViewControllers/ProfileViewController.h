//
//  ProfileViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class GADBannerView;
@class GADRequest;

@interface ProfileViewController : UIViewController <GADBannerViewDelegate>{
    
    UIButton *location;
    UIButton *vipLocation;
}


@property(nonatomic, strong) GADBannerView *adBanner;
@property (nonatomic,retain) IBOutlet UIButton *location;
@property (nonatomic,retain) IBOutlet UIButton *vipLocation;

@end
