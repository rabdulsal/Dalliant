//
//  UserTableViewCell.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserTableViewCell.h"

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
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}

- (void)configureCellForUserInfo:(NSMutableDictionary *)userInfo
{
    
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
