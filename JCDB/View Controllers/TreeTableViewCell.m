//
//  TreeTableViewCell.m
//  JCDB
//
//  Created by WangJincai on 16/1/1.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "TreeTableViewCell.h"

@implementation TreeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.checkButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.checkButton setImage:[UIImage imageNamed:@"CheckBox1_unSelected"]forState:UIControlStateNormal];
        [self addSubview:self.checkButton];
        
//        self.guideImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 24)];
//        self.guideImgView.image = [UIImage imageNamed:@"树状图-虚线"];
//        self.guideImgView.hidden = YES;
//        [self addSubview:self.guideImgView];
 
        self.backgroundColor = [UIColor whiteColor];
//        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        self.textLabel.numberOfLines = 1;
        self.textLabel.minimumScaleFactor = 11;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.moreDeptImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.moreDeptImageView.image = [UIImage imageNamed:@"icon_moreDept"];
        self.moreDeptImageView.hidden = YES;
        [self addSubview:self.moreDeptImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectOffset(self.imageView.frame, 6, 0);
    self.textLabel.frame = CGRectOffset(self.textLabel.frame, 6, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
