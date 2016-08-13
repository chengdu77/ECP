//
//  ProcessStatusCell.h
//  JCDB
//
//  Created by WangJincai on 16/7/1.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessStatusCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *statusLabel;
@property (nonatomic,strong) IBOutlet UILabel *acceptTimeLabel;
@property (nonatomic,strong) IBOutlet UILabel *operateTimeLabel;
@property (nonatomic,strong) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) IBOutlet UIImageView *txImageView;

@property (nonatomic,strong) IBOutlet UILabel *lineLabel;


@end
