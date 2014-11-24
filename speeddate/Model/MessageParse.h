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

@property UIImage *sendImage;

@end
