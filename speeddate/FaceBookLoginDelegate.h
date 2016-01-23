//
//  FaceBookLoginDelegate.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 1/15/16.
//  Copyright © 2016 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FaceBookLoginDelegate <NSObject>

- (void)newUserLoggedIn:(PFUser *)user;
- (void)oldUserLoggedIn:(PFUser *)user;

@end
