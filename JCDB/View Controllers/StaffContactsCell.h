//
//  StaffContactsCell.h
//  JCDB
//
//  Created by WangJincai on 16/1/2.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface  SLButton:UIButton
@property (nonatomic) NSUInteger section;
@end

@interface StaffContactsCell : UITableViewCell

@property (nonatomic,strong) IBOutlet SLButton *telButton;
@property (nonatomic,strong) IBOutlet SLButton *smsButton;
@property (nonatomic,strong) IBOutlet UILabel *dutyLabel;
@property (nonatomic,strong) IBOutlet UILabel *emailLabel;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *genderLabel;
@property (nonatomic,strong) IBOutlet UILabel *idLabel;
@property (nonatomic,strong) IBOutlet UILabel *orgLabel;
@property (nonatomic,strong) IBOutlet UIImageView *photoImageView;



@end

