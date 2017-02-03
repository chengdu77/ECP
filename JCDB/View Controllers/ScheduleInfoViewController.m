//
//  ScheduleInfoViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/31.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ScheduleInfoViewController.h"
#import "ScheduleDetailsViewController.h"
#import "WHUCalendarView.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "NSString+URL.h"
#import "ScheduleQueryViewController.h"

static NSString *LeaveTableIdentifier = @"WorkOrderCell";

@interface ScheduleInfoViewController ()<UITableViewDataSource,UITableViewDelegate>{
    WHUCalendarView *calendarView;
    UIImage *image;
    NSArray *tempArray;
    
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *allArray;

@end

@implementation ScheduleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日程表";
    image = [UIImage imageNamed:@"img_daiban"];
    self.allArray = [NSMutableArray array];
    
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"查询"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(queryAction)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:refreshButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    [self initUI];
    [self initData:[NSDate date]];
}

- (NSString *)dateToString:(NSDate *)date format:(NSString *)format{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df stringFromDate:date];
}

- (void)initUI{
    
    calendarView = [WHUCalendarView new];
    calendarView.frame = CGRectMake(5, 5, self.viewWidth -10, 315);
    [self.scrollView addSubview:calendarView];
    
    calendarView.layer.shadowColor=[UIColor blackColor].CGColor;
    calendarView.layer.shadowOffset=CGSizeMake(1, 1);
    calendarView.layer.shadowOpacity=0.5;
    calendarView.layer.shadowRadius=1;
   
    __weak ScheduleInfoViewController *this=self;
    calendarView.onDateSelectBlk=^(NSDate* date){
        
        NSString *selectedDate = [this dateToString:date format:@"yyyy-MM-dd"];
        
        NSMutableArray *todayArray = [NSMutableArray array];
        NSMutableArray *currentMonthArray = [NSMutableArray array];
        
        for (ScheduleBean *bean in this.allArray){
            
            if ([bean.begindate isEqualToString:selectedDate] && [bean.begindate isEqualToString:selectedDate]) {
                [todayArray addObject:bean];
            }else{
                [currentMonthArray addObject:bean];
            }
        }
        tempArray = @[todayArray,currentMonthArray];
        [this.tableView reloadData];
    };
    
    calendarView.onMonthDateSelectBlock=^(NSString *date){
     
        date = [date stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
        date = [date stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        date = [NSString stringWithFormat:@"%@01",date];
        NSDateFormatter *format=[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSDate *newDate=[format dateFromString:date];
      
        [this initData:newDate];
    };
    
    CGRect rect = calendarView.frame;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(rect)+5, self.viewWidth -10, self.scrollView.frame.size.height - CGRectGetHeight(rect)-5)];
    [self.scrollView addSubview:_tableView];
    _tableView.layer.shadowColor=[UIColor blackColor].CGColor;
    _tableView.layer.shadowOffset=CGSizeMake(1, 1);
    _tableView.layer.shadowOpacity=0.5;
    _tableView.layer.shadowRadius=1;
//    _tableView.backgroundColor = RGB(230, 233, 238);
    
    UINib *nib=[UINib nibWithNibName:LeaveTableIdentifier bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:LeaveTableIdentifier];
    
    rect = _tableView.frame;
    rect.size.height = CGRectGetMaxY(rect)+5;
    [self.scrollView setContentSize:rect.size];

}

- (NSString *)getMonthBeginAndEndWith:(NSString *)dateStr{
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *newDate=[format dateFromString:dateStr];
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
    NSString *s = [NSString stringWithFormat:@"startDate=%@&endDate=%@",beginString,endString];
    return s;
}

- (void)initData:(NSDate *)date{
    
    NSString *valueDate = [self dateToString:date format:@"yyyy-MM-dd"];
    valueDate = [self getMonthBeginAndEndWith:valueDate];
    
  //  valueDate = [valueDate URLEncodedString];
    
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.NineAction?action=getqueryschedulelist&%@",self.serviceIPInfo,valueDate];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        NSMutableArray *todayArray = [NSMutableArray array];
        NSMutableArray *currentMonthArray = [NSMutableArray array];
        
        [self.allArray removeAllObjects];
        
        NSString *today = [self dateToString:[NSDate date] format:@"yyyy-MM-dd"];
        
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
                if ([bean.begindate isEqualToString:today] && [bean.begindate isEqualToString:today]) {
                    [todayArray addObject:bean];
                }else{
                    [currentMonthArray addObject:bean];
                }
                
                [self.allArray addObject:bean];
            }
        }
        tempArray = @[todayArray,currentMonthArray];

        _tableView.delegate=self;
        _tableView.dataSource=self;
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
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return tempArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *sectionArray = tempArray[section];
    
    return sectionArray.count;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.bounds),30)];
    NSString *titleStr = @"当天%@安排";
    if (section == 1) {
        titleStr = @"本月%@安排";
    }
    
    NSArray *sectionArray = tempArray[section];
    titleStr = [NSString stringWithFormat:titleStr,sectionArray.count>0?@"":@"无"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    titleLabel.text = titleStr;
    titleLabel.font = [UIFont fontWithName:kFontName size:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = RGB(230, 233, 238);
    
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    NSArray *sectionArray = tempArray[section];
    if (sectionArray.count >0) {
        return nil;
    }else{
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.bounds),5)];
        footerView.backgroundColor = [UIColor whiteColor];
        return footerView;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderCell *cell = (WorkOrderCell *)[tableView dequeueReusableCellWithIdentifier:LeaveTableIdentifier];
    if (!cell) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeaveTableIdentifier];
    }
    
    ScheduleBean *bean = tempArray[indexPath.section][indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"开始%@ 结束%@",bean.begindate,bean.enddate];
    cell.createdateLabel.text = [NSString stringWithFormat:@"内容：%@",bean.event];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = image;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ScheduleBean *bean = tempArray[indexPath.section][indexPath.row];
    
    ScheduleDetailsViewController *scheduleDetailsViewController = [ScheduleDetailsViewController new];
    scheduleDetailsViewController.bean = bean;
    [self.navigationController pushViewController:scheduleDetailsViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

- (void)queryAction{
    
    ScheduleQueryViewController *scheduleQueryViewController = ScheduleQueryViewController.new;
    scheduleQueryViewController.title = @"日程查询";
    [self.navigationController pushViewController:scheduleQueryViewController animated:YES];

}

@end
