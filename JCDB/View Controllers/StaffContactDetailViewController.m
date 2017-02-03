//
//  StaffContactDetailViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/2.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "StaffContactDetailViewController.h"

@interface StaffContactDetailViewController (){
    NSArray *optionArray;
    NSArray *contentArray;
}

@end

@implementation StaffContactDetailViewController

- (UIView *)addViewFrame:(CGRect)frame titles:(NSArray *)titles values:(NSArray *)values {
    
    frame.size.height = (titles.count +1)*5+titles.count*21 +5;
    UIView *view = [[UIView alloc] init];
    view.frame = frame;
    
    for (int i =0;i<titles.count;i++) {
        frame=CGRectMake(8,7+(5+21)*i,149,21);
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.font = [UIFont fontWithName:kFontName size:14];
        aLabel.frame = frame;
        aLabel.text = titles[i];
        [view addSubview:aLabel];
        
        if (values.count >0) {
            frame=CGRectMake(100,7+(5+21)*i,self.viewWidth -120,21);
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.font = [UIFont fontWithName:kFontName size:14];
            bLabel.frame = frame;
            bLabel.text = values[i];
            [view addSubview:bLabel];
        }
    }
    
    view.backgroundColor = RGB(230, 233, 238);

    view.layer.shadowColor=[UIColor blackColor].CGColor;
    view.layer.shadowOffset=CGSizeMake(1, 1);
    view.layer.shadowOpacity=0.5;
    view.layer.shadowRadius=1;
    
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *phone=@[@"照片:"];
    optionArray=@[@"姓名：",@"性别：",@"电话号码：",@"部门：",@"邮箱："];
    
    optionArray=@[phone,optionArray];
    
    [self drawUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)drawUI{
    
    CGRect frame=CGRectMake(5, 5, self.viewWidth-10, [UIScreen mainScreen].bounds.size.height-80);
    
    frame.size.height = 100;
    UIView *viewImage = [[UIView alloc] init];
    viewImage.frame = frame;

    viewImage.backgroundColor = RGB(230, 233, 238);
    viewImage.layer.shadowColor=[UIColor blackColor].CGColor;
    viewImage.layer.shadowOffset=CGSizeMake(1, 1);
    viewImage.layer.shadowOpacity=0.5;
    viewImage.layer.shadowRadius=1;
    
    [self.scrollView addSubview:viewImage];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake((self.viewWidth-90)/2.0, 10, 80, 80);
    NSString *urlStr = contentArray[0][0];

    NSString *serviceUrl = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",self.serviceIPInfo,urlStr];
    [imageView sd_setImageWithURL:[NSURL URLWithString:serviceUrl] placeholderImage:[UIImage imageNamed:@"img_user_default"]];
    
    [self roundImageView:imageView withColor:kALLBUTTON_COLOR];
    
    [viewImage addSubview:imageView];
    
    frame.origin.y = CGRectGetMaxY(frame)+5;
    
    NSArray *arr = optionArray[1];
    UIView *view = [self addViewFrame:frame titles:arr values:contentArray[1]];
    [self.scrollView addSubview:view];
    frame = view.frame;
    frame.origin.y = CGRectGetMaxY(frame)+5;
    
    frame.size.height =CGRectGetMaxY(frame)+5;
    [self.scrollView setContentSize:frame.size];
}

- (void)setBeanInfo:(StaffContactBean *)bean {
    
    if (!bean.photoId) {
        bean.photoId=@"";
    }
    if (!bean._id) {
        bean._id=@"";
    }
    
    if (!bean.name) {
        bean.name=@"";
    }
    if (!bean.gender) {
        bean.gender=@"";
    }
    
    if (!bean.tel) {
        bean.tel=@"";
    }
    if (!bean.org) {
        bean.org=@"";
    }
    
    if (!bean.duty) {
        bean.duty=@"";
    }
    if (!bean.email) {
        bean.email=@"";
    }
    
    NSArray *phone=@[bean.photoId];
    NSArray *values=@[bean.name,bean.gender,bean.tel,bean.org,bean.duty,bean.email];
    contentArray=@[phone,values];
    
    self.title = bean.name;
    
}


@end
