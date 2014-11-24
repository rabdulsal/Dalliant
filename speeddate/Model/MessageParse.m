#import "MessageParse.h"

@implementation MessageParse

@dynamic fromUserParse;
@dynamic toUserParse;
@dynamic toUserParseEmail;
@dynamic fromUserParseEmail;
@dynamic text;
@dynamic image;
@dynamic createdAt;
@dynamic read;
@synthesize sendImage;

+ (void)load {
    [self registerSubclass];
}



+ (NSString *)parseClassName {
    return @"MessageParse";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"from:%@\n to:%@\n text:%@\n date:%@\n",self.fromUserParse, self.toUserParse, self.text, self.createdAt];
}

@end
