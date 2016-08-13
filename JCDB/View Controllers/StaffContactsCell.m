//
//  StaffContactsCell.m
//  JCDB
//
//  Created by WangJincai on 16/1/2.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "StaffContactsCell.h"

@implementation SLButton
@end

@implementation StaffContactsCell

- (void)awakeFromNib {
    
    _dutyLabel.font = [UIFont fontWithName:kFontName size:14];
    _emailLabel.font = [UIFont fontWithName:kFontName size:14];
    _nameLabel.font = [UIFont fontWithName:kFontName size:14];
    _genderLabel.font = [UIFont fontWithName:kFontName size:14];
    _idLabel.font = [UIFont fontWithName:kFontName size:14];
    _orgLabel.font = [UIFont fontWithName:kFontName size:14];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
