#import "MessageParse.h"

@implementation MessageParse

@dynamic fromUserParse;
@dynamic toUserParse;
@dynamic toUserParseEmail;
@dynamic fromUserParseEmail;
@dynamic text;
@dynamic image;
@dynamic video;
@dynamic createdAt;
@dynamic read;
@dynamic isRevealed;
@dynamic conversationId;
@synthesize sendImage;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"MessageParse";
}

+ (void)getAllMessagesFromCurrentUser:(UserParseHelper *)currentUser
                           completion:(void(^)(NSArray *messages, NSError * _Nullable error))callback
{
    PFQuery *messageQueryFrom = [MessageParse query];
    [messageQueryFrom whereKey:@"fromUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
    [both orderByDescending:@"createdAt"];
    //[both orderByDescending:@"compatibilityIndex"]; // <-- Won't work for now, need a compatibility attribute on messages somehow
    
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            callback(objects,nil);
        } else {
            // Handle error
        }
    }];
}

+ (void)getMessagesBetween:(UserParseHelper *)currentUser
                  andMatch:(UserParseHelper *)match
                completion:(void(^)(NSArray *conversation, NSError * _Nullable error))callback
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:currentUser];
    [query1 whereKey:@"toUserParse" equalTo:match];
    [query1 whereKey:@"text" notEqualTo:@""];
    
    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:match];
    [query2 whereKey:@"toUserParse" equalTo:currentUser];
    [query2 whereKey:@"text" notEqualTo:@""];
    
    
    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [orQUery orderByAscending:@"createdAt"];
    
    // orQUery.limit = 3;
    // orQUery.skip = 5;
    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects,nil);
        } else {
            // Handle error
        }
    }];
}

+ (void)getNewMessageBetween:(UserParseHelper *)currentUser
                    andMatch:(UserParseHelper *)match
                  completion:(void(^)(NSArray *messages, NSError *error))callback
{
    PFQuery *query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:match];
    [query whereKey:@"toUserParse" equalTo:currentUser];
    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:NO]]; // <-- Key to determine if Message is read - add to TDBadgeCell logic for
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects,nil);
        } else {
            // Handle error
        }
    }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"from:%@\n to:%@\n text:%@\n date:%@\n",self.fromUserParse, self.toUserParse, self.text, self.createdAt];
}

@end
