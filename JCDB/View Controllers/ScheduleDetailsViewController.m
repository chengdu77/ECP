//
//  ScheduleDetailsViewController.m
//  JCDB
//
//  Created by WangJincai on 16/2/14.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ScheduleDetailsViewController.h"

@interface ScheduleDetailsViewController ()

@end

@implementation ScheduleDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程详情";
    
    [self initThisView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)initThisView{
    
    
    CGRect frame = CGRectMake(0,0,self.viewWidth,20);
    
    UILabel *creatorLabel = [[UILabel alloc] initWithFrame:frame];
    creatorLabel.text = [NSString stringWithFormat:@"创建人：%@",self.bean.creator];
    creatorLabel.font = [UIFont fontWithName:kFontName size:14];
    creatorLabel.backgroundColor = RGB(230, 233, 238);
    [self.scrollView addSubview:creatorLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    UILabel *bumenLabel = [[UILabel alloc] initWithFrame:frame];
    bumenLabel.text = [NSString stringWithFormat:@"部门：%@",self.bean.bumen];
    bumenLabel.font = [UIFont fontWithName:kFontName size:14];
    bumenLabel.backgroundColor = RGB(230, 233, 238);
    [self.scrollView addSubview:bumenLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:frame];
    dateLabel.text = [NSString stringWithFormat:@"日期：%@ 到 %@",self.bean.begindate,self.bean.enddate];
    dateLabel.font = [UIFont fontWithName:kFontName size:14];
    dateLabel.backgroundColor = RGB(230, 233, 238);
    [self.scrollView addSubview:dateLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.text = @"标题";
    titleLabel.font = [UIFont fontWithName:kFontName size:14];
    titleLabel.textColor = kALLBUTTON_COLOR;
    titleLabel.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:titleLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    frame.size.height = 40;
    UILabel *titleValueLabel = [[UILabel alloc] initWithFrame:frame];
    titleValueLabel.text = [NSString stringWithFormat:@"   %@",self.bean.title];
    titleValueLabel.font = [UIFont fontWithName:kFontName size:16];
    titleValueLabel.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:titleValueLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    frame.size.height = 1;
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:frame];
    lineLabel.backgroundColor = kALLBUTTON_COLOR;
    [self.scrollView addSubview:lineLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    frame.size.height = 40;
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:frame];
    contentLabel.text = @"内容";
    contentLabel.font = [UIFont fontWithName:kFontName size:14];
    contentLabel.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:contentLabel];
    
    frame.origin.y = CGRectGetMaxY(frame);
    UILabel *contentValueLabel = [self adaptiveLabelWithFrame:frame detail:self.bean.event fontSize:16];
    [self.scrollView addSubview:contentValueLabel];
    
    frame = contentValueLabel.frame;
    
    frame.origin.y = CGRectGetMaxY(frame)+20;
    frame.size.height = 1;
    frame.size.width = self.viewWidth;
    lineLabel = [[UILabel alloc] initWithFrame:frame];
    lineLabel.backgroundColor = RGB(230, 233, 238);
    [self.scrollView addSubview:lineLabel];
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth, CGRectGetMaxY(frame)+5);
    
}

@end
