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

@interface ChatMessageViewController : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property UserParseHelper *toUserParse;
@property UserParseHelper *curUser;
@property PossibleMatchHelper *matchedUsers;
@property BOOL fromConversation;

@end
