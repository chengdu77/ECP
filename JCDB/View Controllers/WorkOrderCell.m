//
//  WorkOrderCell.m
//  JCDB
//
//  Created by WangJincai on 16/1/4.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "WorkOrderCell.h"

@implementation WorkOrderCell

- (void)awakeFromNib {
     self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
