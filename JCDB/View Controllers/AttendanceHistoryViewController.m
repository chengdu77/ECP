//
//  AttendanceHistoryViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/12.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "AttendanceHistoryViewController.h"
#import "NSDate+Helper.h"
#import "DXPopover.h"

@implementation AttendanceHistoryBean
@end

@interface AttendanceHistoryViewController (){
    CGFloat _popoverWidth;

}

@property (nonatomic, strong) UIView *popTimeView;
@property (nonatomic, strong) DXPopover *popover;
@end

@implementation AttendanceHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _popover = [DXPopover new];
    _popover.cornerRadius = 0;
    _popover.arrowSize = CGSizeMake(26, 12);
    _popoverWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self initPopTimeView];
    
    UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"时间"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showPopoverViewAction:)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:commitButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    NSString *dates = [self getMonthBeginAndEndWith:[NSDate date]];
    NSArray *dateArray = [dates componentsSeparatedByString:@","];
    [self requestData:dateArray[0] endDate:dateArray[1]];

}

- (NSString *)getMonthBeginAndEndWith:(NSDate *)newDate{
    
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    NSString *s = [NSString stringWithFormat:@"%@,%@",beginString,endString];
    return s;
}

- (void)showPopoverViewAction:(UIButton *)btn{
    
    
    CGPoint startPoint = CGPointMake(_popoverWidth-20,64);
    
    [_popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:_popTimeView inView:self.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)requestData:(NSString *)startDate endDate:(NSString *)endDate{
    
    #if defined(DEBUG)||defined(_DEBUG)
    startDate = @"2015-06-17";
    endDate = @"2015-06-26";
#endif
    
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.ProcessAction?action=querysigned&startDate=%@&endDate=%@&pageIndex=1",serviceIPInfo,startDate,endDate];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        NSArray *data = dic[@"result"];
        if ([dic[@"success"] integerValue] ==1 && data.count >0){
            NSMutableArray *listArray = [NSMutableArray array];
            for (NSDictionary *info in data) {
                AttendanceHistoryBean *bean = AttendanceHistoryBean.new;
                bean.date = info[@"date"];
                bean.day = info[@"day"];
                bean.deptid = info[@"deptid"];
                bean.deptname = info[@"deptname"];
                bean.Id = info[@"id"];
                bean.jingweidu = info[@"jingweidu"];
                bean.space = info[@"space"];
                bean.time = info[@"time"];
                bean.userid = info[@"userid"];
                bean.username = info[@"username"];
                bean.week = info[@"week"];
                [listArray addObject:bean];
            }
            self.listArray = [NSArray arrayWithArray:listArray];
            [self initThisView];
            
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:ShareAppDelegate.window];
        
    }];
    
    [request startAsynchronous];

}

- (void)initThisView{
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect frame = CGRectMake(0, 0, self.viewWidth,100);
    for (int i = 0; i < self.listArray.count;i++) {
        AttendanceHistoryBean *bean = self.listArray[i];
        UIView *view = [self addListViewWithFrame:frame bean:bean];
        frame = view.frame;
        [self.scrollView addSubview:view];
        if (i < self.listArray.count-1)
            frame = CGRectMake(0, CGRectGetMaxY(frame),self.viewWidth,100);
    }
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(frame)+5);
    
}

- (UIView *)addListViewWithFrame:(CGRect)frame bean:(AttendanceHistoryBean *)bean{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.viewWidth-10, 30)];
    titleLabel.backgroundColor = kBackgroundColor;
    titleLabel.font = [UIFont fontWithName:kFontName size:14];
    titleLabel.text = [NSString stringWithFormat:@" %@(%@)",bean.date,bean.week];
    [view addSubview:titleLabel];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(titleLabel.frame), self.viewWidth-60, 20)];
    label1.font = [UIFont fontWithName:kFontName size:14];
    label1.textColor = kFontColor_Contacts;
    label1.text = [NSString stringWithFormat:@"姓名：%@ 部门：%@",bean.username,bean.deptname];
    [view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(label1.frame), self.viewWidth-60, 20)];
    label2.font = [UIFont fontWithName:kFontName size:14];
    label2.textColor = kFontColor_Contacts;
    label2.text = [NSString stringWithFormat:@"签到时间：%@",bean.time];
    [view addSubview:label2];
    
    UILabel *label3 = [self adaptiveLabelWithFrame:CGRectMake(30,CGRectGetMaxY(label2.frame), self.viewWidth-35, 30) detail:[NSString stringWithFormat:@"签到地点：%@",bean.space] fontSize:14];
    [view addSubview:label3];
    
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(label1.frame)-5,14,20)];
    label4.font = [UIFont fontWithName:kFontName size:12];
    label4.textColor = kBackgroundColor;
    label4.text = bean.day;
    [view addSubview:label4];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4.center.x,CGRectGetMaxY(titleLabel.frame),1,CGRectGetMinY(label4.frame) - CGRectGetMaxY(titleLabel.frame))];
    lineLabel.backgroundColor = kBackgroundColor;
    [view addSubview:lineLabel];
    
    frame.size.height = CGRectGetMaxY(label2.frame)+ CGRectGetHeight(label3.frame) +2;
    view.frame = frame;
    
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(label4.center.x,CGRectGetMaxY(label4.frame),1,CGRectGetHeight(frame) - CGRectGetMaxY(label4.frame))];
    lineLabel2.backgroundColor = kBackgroundColor;
    [view addSubview:lineLabel2];
    
    return view;
}

- (void)initPopTimeView {
    
    _popTimeView = [[UIView alloc] init];
    _popTimeView.frame = CGRectMake(0, 0, _popoverWidth, 150);
    _popTimeView.backgroundColor = [UIColor whiteColor];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 75, 40)];
    startLabel.text = @"开始时间:";
    startLabel.textColor = [UIColor blackColor];
    startLabel.textAlignment = NSTextAlignmentCenter;
    [_popTimeView addSubview:startLabel];
    
    CGRect rect1 = CGRectOffset(startLabel.frame,75+2,2);
    rect1.size = CGSizeMake([UIScreen mainScreen].bounds.size.width-150, 34);
    UILabel *timeSLbael = [[UILabel alloc] initWithFrame:rect1];
    timeSLbael.tag = 201;
    timeSLbael.backgroundColor = RGB(230, 233, 238);
    timeSLbael.textAlignment = NSTextAlignmentCenter;
    timeSLbael.text = @"请点击选择时间";
    
    //设置圆角
    timeSLbael.layer.cornerRadius = 6;
    [[timeSLbael layer] setMasksToBounds:YES];
    //增加点击事件
    timeSLbael.userInteractionEnabled = YES;
    UITapGestureRecognizer *timeStapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTime:)];
    [timeSLbael addGestureRecognizer:timeStapGesture];
    
    [_popTimeView addSubview:timeSLbael];
    
    CGRect rect2 = CGRectOffset(startLabel.frame,0,CGRectGetMinX(startLabel.frame)+5);
    UILabel *endLabel = [[UILabel alloc] initWithFrame:rect2];
    endLabel.text = @"结束时间:";
    endLabel.textColor = [UIColor blackColor];
    endLabel.textAlignment = NSTextAlignmentCenter;
    [_popTimeView addSubview:endLabel];
    
    rect1 = CGRectOffset(rect1,0,CGRectGetMaxY(rect1));
    UILabel *timeELbael = [[UILabel alloc] initWithFrame:rect1];
    timeELbael.tag = 202;
    timeELbael.backgroundColor = RGB(230, 233, 238);
    timeELbael.text = @"请点击选择时间";
    timeELbael.textAlignment = NSTextAlignmentCenter;
    
    //设置圆角
    timeELbael.layer.cornerRadius = 6;
    [[timeELbael layer] setMasksToBounds:YES];
    //增加点击事件
    timeELbael.userInteractionEnabled = YES;
    timeStapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTime:)];
    [timeELbael addGestureRecognizer:timeStapGesture];
    
    [_popTimeView addSubview:timeELbael];
    
    
    UIButton *button = [self buttonForTitle:@"查询" action:@selector(timeButtonAction:)];
    CGFloat w = endLabel.frame.size.width +2 + timeELbael.frame.size.width;
    button.frame = CGRectMake((_popoverWidth -w)/2, CGRectGetMaxY(endLabel.frame)+10, w, 40);
    [self selectButton:button];
    
    [_popTimeView addSubview:button];
    
}

#pragma mark - 选择开始时间
- (void)selectTime:(UITapGestureRecognizer*)sender {
    
    UIDatePicker *picer = [[UIDatePicker alloc] init];
    picer.datePickerMode = UIDatePickerModeDate;
    if (IOS8_OR_LATER) {
        picer.frame = CGRectMake(-20, 40, 320, 200);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSDate *date = picer.date;
            UILabel *timeLabel = (UILabel *)sender.view;
            timeLabel.text = [date stringWithFormat:@"yyyy-MM-dd"];
        }];
        [alertController.view addSubview:picer];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (UIButton *)buttonForTitle:(NSString *)title action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:title forState:UIControlStateNormal];
    
    UIImage *normalImage = [UIImage imageNamed:@"button-default"];
    UIImage *highlightedImage = [UIImage imageNamed:@"button-default-d"];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    CGFloat hInset = floorf(normalImage.size.width / 2);
    CGFloat vInset = floorf(normalImage.size.height / 2);
    UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    normalImage = [normalImage resizableImageWithCapInsets:insets];
    highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    if (action) {
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    return button;
}

- (void)selectButton:(UIButton *)button{
    UIImage *image = [UIImage imageNamed:@"button-seelect"];
    CGFloat hInset = floorf(image.size.width / 2);
    CGFloat vInset = floorf(image.size.height / 2);
    UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    image = [image resizableImageWithCapInsets:insets];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)timeButtonAction:(UIButton *)button {
    
    NSString *startDate = [(UILabel *)[_popTimeView viewWithTag:201] text];
    if ([startDate isEqualToString:@"请点击选择时间"]) {
        [MBProgressHUD showError:@"请点击选择时间" toView:self.view.window];
        return;
    }
    NSString *endDate = [(UILabel *)[_popTimeView viewWithTag:202] text];
    if ([endDate isEqualToString:@"请点击选择时间"]) {
        [MBProgressHUD showError:@"请点击选择时间" toView:self.view.window];
        return;
    }
    
    NSDate *beginTime = [NSDate dateFromString:startDate withFormat:@"yyyy-MM-dd"];
    NSDate *endTime = [NSDate dateFromString:endDate withFormat:@"yyyy-MM-dd"];
    
    if ([beginTime compare:[NSDate date]] == NSOrderedDescending || [endTime compare:[NSDate date]] == NSOrderedDescending) {
        [MBProgressHUD showError:@"选择时间不能大于当前时间" toView:self.view.window];
        return;
    }
    
    if ([beginTime compare:endTime] == NSOrderedDescending) {
        [MBProgressHUD showError:@"开始时间不能大于结束时间" toView:self.view.window];
        return;
    }
    
    [self.popover dismiss];
    
    [self requestData:startDate endDate:endDate];
}



@end
