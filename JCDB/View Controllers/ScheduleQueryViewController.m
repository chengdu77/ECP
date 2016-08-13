//
//  ScheduleQueryViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/26.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ScheduleQueryViewController.h"
#import "WorkOrderBean.h"
#import "WorkOrderCell.h"
#import "ScheduleDetailsViewController.h"
#import "NSDate+Helper.h"
#import "DXPopover.h"

@interface ScheduleQueryViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *tempArray;
    
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UIView *popTimeView;
@property (nonatomic, strong) DXPopover *popover;

@end

@implementation ScheduleQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _popover = [DXPopover new];
    _popover.cornerRadius = 0;
    _popover.arrowSize = CGSizeMake(26, 12);
    [self initPopTimeView];
    
    UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"时间"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showPopoverViewAction:)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:commitButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    NSString *dates = [self getMonthBeginAndEndWith:[NSDate date]];
    NSArray *dateArray = [dates componentsSeparatedByString:@","];
   

    CGRect rect = CGRectZero;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 64, self.viewWidth -10, self.scrollView.frame.size.height - CGRectGetHeight(rect)-5)];
    [self.view addSubview:_tableView];
    _tableView.layer.shadowColor=[UIColor blackColor].CGColor;
    _tableView.layer.shadowOffset=CGSizeMake(1, 1);
    _tableView.layer.shadowOpacity=0.5;
    _tableView.layer.shadowRadius=1;
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //    _tableView.backgroundColor = RGB(230, 233, 238);
    
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
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
    
    
    CGPoint startPoint = CGPointMake(self.viewWidth -20,64);
    
    [_popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:_popTimeView inView:self.view];
    
}

- (void)initPopTimeView {
    
    _popTimeView = [[UIView alloc] init];
    _popTimeView.frame = CGRectMake(0, 0, self.viewWidth, 150);
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
    button.frame = CGRectMake((self.viewWidth -w)/2, CGRectGetMaxY(endLabel.frame)+10, w, 40);
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)requestData:(NSString *)startDate endDate:(NSString *)endDate{
    
  
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.NineAction?action=getqueryschedulelist&&startDate=%@&endDate=%@",self.serviceIPInfo,startDate,endDate];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
       
        if (!tempArray) {
            tempArray = [NSMutableArray array];
        }else{
            [tempArray removeAllObjects];
        }
        
        if ([dic[@"success"] integerValue] ==1){
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result) {
                ScheduleBean *bean = [ScheduleBean new];
                bean.Customer = info[@"Customer"]?info[@"Customer"]:@"";
                bean.begindate = info[@"begindate"]?info[@"begindate"]:@"";
                bean.begintime = info[@"begintime"]?info[@"begintime"]:@"";
                bean.event = info[@"event"]?info[@"event"]:@"";
                bean.enddate = info[@"enddate"]?info[@"enddate"]:@"";
                bean.endtime = info[@"endtime"]?info[@"endtime"]:@"";
                bean.processid = info[@"processid"]?info[@"processid"]:@"";
                bean.creator = info[@"creator"]?info[@"creator"]:@"";
                bean.title = info[@"title"]?info[@"title"]:@"";
                bean.bumen = info[@"bumen"]?info[@"bumen"]:@"";
                
                [tempArray addObject:bean];
            }
        }
       
        [_tableView reloadData];
        
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        
    }];
    
    [request startAsynchronous];
    
}

#pragma mark -- talbeView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return tempArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderCell *cell = (WorkOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"WorkOrderCell"];
    if (!cell) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkOrderCell"];
    }
    
    ScheduleBean *bean = tempArray[indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"开始%@ 结束%@",bean.begindate,bean.enddate];
    cell.createdateLabel.text = [NSString stringWithFormat:@"内容：%@",bean.event];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = [UIImage imageNamed:@"img_daiban"];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ScheduleBean *bean = tempArray[indexPath.row];
    
    ScheduleDetailsViewController *scheduleDetailsViewController = [ScheduleDetailsViewController new];
    scheduleDetailsViewController.bean = bean;
    [self.navigationController pushViewController:scheduleDetailsViewController animated:YES];
}

@end
