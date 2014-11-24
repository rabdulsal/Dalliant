//
//  MyappTableViewCell.m
//  WallpaperzSocial
//
//  Created by studio76 on 14.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "MyappTableViewCell.h"

@implementation MyappTableViewCell
@synthesize iconApp,nameApp,categoryApp,priceApp;

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



@end
