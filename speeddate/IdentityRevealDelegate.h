//
//  IdentityRevealDelegate.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 9/23/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IdentityRevealDelegate <NSObject>

//Outgoing Actions
- (void)shareRequestSentFromUser:(UserParseHelper *)currentUser toMatch:(UserParseHelper *)match; // Requested
- (void)shareRequestFromMatch:(UserParseHelper *)match acceptedByUser:(UserParseHelper *)currentUser; // Sharing

//Incoming notifications
- (void)currentUserShareRequest:(UserParseHelper *)currentUser rejectedByMatch:(UserParseHelper *)match; // Sharing
- (void)currentUserShareRequest:(UserParseHelper *)currentUser acceptedByMatch:(UserParseHelper *)match; // Rejected

@end
