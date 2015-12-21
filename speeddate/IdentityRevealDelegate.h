//
//  IdentityRevealDelegate.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 9/23/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IdentityRevealDelegate <NSObject>

- (void)shareRequestSentFromUser:(UserParseHelper *)currentUser toMatch:(UserParseHelper *)match; //Outgoing
- (void)shareRequestFromMatch:(UserParseHelper *)match acceptedByUser:(UserParseHelper *)currentUser; //Incoming
- (void)shareRequestFromMatch:(UserParseHelper *)match rejectedByUser:(UserParseHelper *)currentUser; //Incoming
- (void)shareRequestFromUser:(UserParseHelper *)currentUser acceptedByMatch:(UserParseHelper *)match; //Outgoing

@end
