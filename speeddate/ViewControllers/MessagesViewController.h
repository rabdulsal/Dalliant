//
//  MessagesViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
#import "GADInterstitial.h"
#import "GADAdNetworkExtras.h"
#import "config.h"
#import "User.h"
#import "UserParseHelper.h"

@class GADBannerView;
@class GADRequest;

@interface MessagesViewController : UIViewController<GADBannerViewDelegate,GADAdNetworkExtras,GADInterstitialDelegate>{
    
    GADBannerView *adBanner;
    int frameSize;
    User *mainUser;
    
}

@property NSMutableArray *usersArray;

@property(nonatomic, strong)  GADBannerView *adBanner;
@property NSNumber *prefCounter;
@property NSNumber *totalPrefs;

@end
