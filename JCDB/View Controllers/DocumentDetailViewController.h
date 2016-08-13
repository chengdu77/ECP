//
//  DocumentDetailViewController.h
//  JCDB
//
//  Created by WangJincai on 16/7/6.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"

@interface DocumentDetailViewController : HeadViewController

@property (nonatomic,strong) NSString *valueStr;
@property (nonatomic,strong) NSArray *docattach;
@property (nonatomic,strong) NSArray *img;
@property (nonatomic,strong) NSArray *replyList;

@end
