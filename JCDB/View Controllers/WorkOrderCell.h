//
//  WorkOrderCell.h
//  JCDB
//
//  Created by WangJincai on 16/1/4.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkOrderCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *createdateLabel;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic,strong) IBOutlet UIImageView *flagImageView;
@end
