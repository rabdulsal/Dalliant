//
//  UserTableViewCell.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserTableViewCell.h"
#import "RevealRequest.h"
#import "speeddate-Swift.h"
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"
#import "MessageParse.h"

#define SECONDS_DAY 24*60*60

@interface UserTableViewCell ()
@property (nonatomic) UserParseHelper *matchUser;
@property (nonatomic) MessageParse *message;
@property (nonatomic) NSInteger shareRelation;
@property (nonatomic) RevealRequest *outgoingRequest;
@property (nonatomic) RevealRequest *incomingRequest;
@property (nonatomic) PossibleMatchHelper *connection;
@property (nonatomic) UIVisualEffectView *visualEffectView;
@end

@implementation UserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    UIView *bgColorView = [[UIView alloc] init];
    //bgColorView.backgroundColor = RED_COLOR;
    bgColorView.backgroundColor = WHITE_COLOR;
    [self setSelectedBackgroundView:bgColorView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.indicatorLabel.hidden = YES;
    self.indicatorLabel.layer.cornerRadius = self.indicatorLabel.frame.size.width/2;
    self.indicatorLabel.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.indicatorLabel.hidden = YES;
    self.indicatorLabel.layer.cornerRadius = self.indicatorLabel.frame.size.width/2;
    self.indicatorLabel.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2;
    self.userImageView.layer.masksToBounds = YES;
    UIImageView *accesory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accesory"]];
    accesory.frame = CGRectMake(15, 0, 15, 15);
    accesory.contentMode = UIViewContentModeScaleAspectFit;
    self.accessoryView = accesory;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithUserCache:(NSMutableDictionary *)userCache
{
    [self setVarsFromCache:userCache];
    [self concealMatch];
    [self configDateFormatter];
    [self configureMessageUI];
    [self setNotificationIndicators];
}

- (void)setVarsFromCache:(NSMutableDictionary *)userCache
{
    /* userCache keys:
     *
     * @"matchConnection"
     * @"shareRelation"
     * @"outgoingRequest"
     * @"incomingRequest"
     *
     */
    
    _matchUser       = [userCache objectForKey:@"matchUser"];
    _message         = [userCache objectForKey:@"message"];
    _shareRelation   = [[userCache objectForKey:@"shareState"] intValue];
    _connection      = [userCache objectForKey:@"matchConnection"];
    _outgoingRequest = [userCache objectForKey:@"outgoingRequest"];
    _incomingRequest = [userCache objectForKey:@"incomingRequest"];
}

- (void)configDateFormatter
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[_message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:[_message createdAt]];
}

- (void)configureMessageUI
{
    self.lastMessageLabel.text = _message.text;
    if (!_message.text && _message.image) {
        self.lastMessageLabel.text = @"Image";
    }
    if (!_message.read && [_message.toUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
        self.nameTextLabel.textColor = RED_LIGHT;
        [self.lastMessageLabel setFont:[UIFont boldSystemFontOfSize:13]];
        self.lastMessageLabel.textColor = RED_LIGHT;
        self.dateLabel.textColor = RED_LIGHT;
    } else {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        self.nameTextLabel.textColor = [UIColor lightGrayColor];
        self.lastMessageLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)configureRadialViewForFrame:(CGRect)frame
{
    [_connection configureRadialViewForView:self.contentView withFrame:frame];
}

- (void)concealMatch
{
    [_matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        self.userImageView.image = [UIImage imageWithData:data];
        if (_visualEffectView == nil && _shareRelation != ShareStateSharing) [self blurImages:self.userImageView];
        
        if (_shareRelation != ShareStateSharing) {
            NSString *matchGender = [_matchUser.isMale isEqualToString:@"true"] ? @"Male" : @"Female";
            self.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, _matchUser.age];
        } else {
            self.nameTextLabel.text = _matchUser.nickname;
            [_visualEffectView removeFromSuperview];
        }
    }];
}

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = imageView.bounds;
    [imageView addSubview:_visualEffectView];
}

- (void)setNotificationIndicators
{
    if (_incomingRequest && !_incomingRequest.requestReply) {
        self.indicatorLabel.hidden = NO;
        self.indicatorLabel.backgroundColor = [UIColor purpleColor];
    }

    if (_outgoingRequest && _outgoingRequest.requestReply != nil && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        self.indicatorLabel.hidden = NO;
        self.indicatorLabel.backgroundColor = RED_LIGHT;
    }
}

- (void)setInterests:(NSArray *)userInterests
{
    NSString *interest;
    for (int i = 0; i < [userInterests count]; i++) {
        interest = [userInterests objectAtIndex:i];
        NSLog(@"Interest count: %lu", (unsigned long)[userInterests count]);
        switch (i) {
            case 0:
                self.image1.image = [UIImage imageNamed:interest];
                NSLog(@"Interest1: %@", interest);
                break;
            case 1:
                self.image2.image = [UIImage imageNamed:interest];
                NSLog(@"Interest2: %@", interest);
                break;
            case 2:
                self.image3.image = [UIImage imageNamed:interest];
                NSLog(@"Interest3: %@", interest);
                break;
            case 3:
                self.image4.image = [UIImage imageNamed:interest];
                NSLog(@"Interest4: %@", interest);
                break;
            case 4:
                self.image5.image = [UIImage imageNamed:interest];
                NSLog(@"Interest5: %@", interest);
                break;
        }
    
    }
}

@end
