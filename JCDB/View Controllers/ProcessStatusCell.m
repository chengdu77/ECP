//
//  ProcessStatusCell.m
//  JCDB
//
//  Created by WangJincai on 16/7/1.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ProcessStatusCell.h"
#import "Constants.h"

@implementation ProcessStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineLabel.backgroundColor = kBackgroundColor;
    CGRect frame = self.lineLabel.frame;
    frame.size.height = 0.5;
    self.lineLabel.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
