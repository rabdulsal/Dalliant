//
//  IdentityRevealDelegate.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 9/23/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IdentityRevealDelegate <NSObject>

- (void)shareRequestSent;
- (void)shareRequestAccepted;
- (void)shareRequestRejected;
- (void)acceptedShareRequest;

@end
