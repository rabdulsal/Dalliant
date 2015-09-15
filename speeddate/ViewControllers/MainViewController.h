//
//  MainViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "PreferencesTableViewController.h"

@class GADBannerView;
@class GADRequest;

@interface MainViewController : UIViewController<GADBannerViewDelegate>{
    
    
}

@property(nonatomic, strong) GADBannerView *adBanner;
@property (assign, nonatomic) BOOL *matched;

@end
