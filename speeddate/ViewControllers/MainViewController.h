//
//  MainViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class GADBannerView;
@class GADRequest;

@interface MainViewController : UIViewController<GADBannerViewDelegate>{
    
    
}

@property(nonatomic, strong) GADBannerView *adBanner;

@end
