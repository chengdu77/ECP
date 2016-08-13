//
//  DeviceViewController.m
//  xsgj
//
//  Created by 卿 明 on 15/11/3.
//  Copyright (c) 2015年 Shenlan. All rights reserved.
//

#import "DeviceViewController.h"


@interface DeviceViewController (){
    CGFloat _width;
    CGFloat height;
    NSInteger col;
}

@property(nonatomic,strong)UILabel* markLabel;
@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    height = 45.0;//高度
    col = 3;//列数
    [self drawUI:self.infos];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawUI:(NSArray *)arr {
    
    NSInteger row = ceil(arr.count/3.0);
    CGFloat width = (self.viewWidth - 30) / 3.0;
    
    self.scrollView.frame = CGRectMake(0, 0, _width, 10+row*height+35);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = self.scrollView.frame.size;
   
    
    NSInteger i=0;
    NSInteger k=0;
    for ( NSInteger j = 0;j < arr.count;j++){
        NSString *title =  arr[j];
        i = j % col;
        k = floorl(j / col);
        UIButton *button = [self buttonForTitle:title action:@selector(typeButtonAction:)];
        button.frame = CGRectMake(i*(width+5)+10, 10+k*(height+5), width, height);
        button.titleLabel.lineBreakMode = 0 ;
        button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
        button.tag = j;
        [self.scrollView  addSubview:button];
    }
    
}

- (void)typeButtonAction:(UIButton *)sender {
    
    NSString *title = self.infos[sender.tag];
    self.block(sender.tag,title);
    
    [self backAction];
}

-(void)setDeviceTypeBlock:(DeviceTypeBlock) block {
    self.block = block;
}

@end
