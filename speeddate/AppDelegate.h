//
//  AppDelegate.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "UserParseHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    NSArray *allproduct;
    int count;
    SKProduct *findProduct;
    UserParseHelper *userStart;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong)  UserParseHelper *userStart;

@end
