//
//  ChatMessageViewController.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 2/16/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "JSQMessagesViewController/JSQMessages.h"
#import "PossibleMatchHelper.h"
#import "UserParseHelper.h"
#import "MessageParse.h"
#import "MatchViewController.h"
#import "ImageVC.h"
#import "Report.h"
#import "RevealRequest.h"
#import <AMPopTip.h>
#import <SCLAlertView.h>
#import "RedeemViewController.h"

@interface ChatMessageViewController : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property UserParseHelper *toUserParse;
@property UserParseHelper *curUser;
@property PossibleMatchHelper *matchedUsers;
@property BOOL fromConversation;

/* Convenience Initializer with ConversationID
 
- (id)initWithName:(NSString *)aName
       description:(NSString *)aDescription;
*/

@end
