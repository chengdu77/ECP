//
//  SubViewController.m
//  WJcTableView
//
//  Created by wangjc on 15-7-4.
//  Copyright (c) 2015年 wjc. All rights reserved.
//

#import "HireListCell.h"

@implementation HireListCell

@synthesize titleLabel,dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)changeArrowWithUp:(BOOL)up
{
    
}
@end
