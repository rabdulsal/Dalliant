//
//  IdentityRevealProtocol.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 9/20/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#ifndef speeddate_IdentityRevealProtocol_h
#define speeddate_IdentityRevealProtocol_h

@protocol IdentityRevealDelegate <NSObject>

- (void)revealRequestSent;
- (void)revealRequestAccepted;
- (void)revealRequestRejected;

@end

#endif
