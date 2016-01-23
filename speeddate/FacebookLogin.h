//
//  FacebookLogin.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 1/15/16.
//  Copyright © 2016 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceBookLoginDelegate.h"

@interface FacebookLogin : NSObject

- (id)initWithDelegate:(id)delegate;
- (void)loginUser;
@end
