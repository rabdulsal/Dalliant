#import <Parse/Parse.h>
#import "UserParseHelper.h"

@interface MessageParse : PFObject <PFSubclassing>

@property (nonatomic, strong) UserParseHelper *fromUserParse;
@property (nonatomic, strong) UserParseHelper *toUserParse;
@property NSString* fromUserParseEmail;
@property NSString* toUserParseEmail;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) BOOL read;
@property (nonatomic) BOOL isRevealed;
@property NSString *conversationId;

@property UIImage *sendImage;

+ (void)getAllMessagesFromCurrentUser:(UserParseHelper *)currentUser
                           completion:(void(^)(NSArray *messages, NSError *error))callback;
+ (void)getMessagesBetween:(UserParseHelper *)currentUser
                  andMatch:(UserParseHelper *)match
                completion:(void(^)(NSArray *conversation, NSError *error))callback;
+ (void)getNewMessageBetween:(UserParseHelper *)currentUser
                    andMatch:(UserParseHelper *)match
                  completion:(void(^)(NSArray *messages, NSError *error))callback;

@end
