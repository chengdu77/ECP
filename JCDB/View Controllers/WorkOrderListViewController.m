//
//  WorkOrderListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/4.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "WorkOrderListViewController.h"
#import "WorkOrderDetailsViewController.h"
#import "LeaveSlideView.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "DeviceViewController.h"

#import "SelectionModuleViewController.h"


@interface WorkOrderListViewController ()<LeaveSlideViewDelegate>{
    NSMutableArray *tempArray;
    UIImage *image;
    
    NSInteger defaultTag;//默认选择按钮标识
    
    NSString *workflowid;
    NSMutableArray *ywflData;
    NSMutableArray *ywflName;
}

@property(nonatomic,strong)UILabel *markLabel;
@property (strong, nonatomic) LeaveSlideView *slideView;

@end

@implementation WorkOrderListViewController

- (void)viewDidLoad {
    
    if (!self.state){
        self.flag = YES;
        self.state = @"getwfprocessDBlist";
    }
    [super viewDidLoad];
    
    self.markLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 40)];
    self.markLabel.text=@"正在加载数据";
    self.markLabel.textAlignment=NSTextAlignmentCenter;
    self.markLabel.font=[UIFont systemFontOfSize:15.0];
    self.markLabel.hidden=YES;
    [self.scrollView addSubview:self.markLabel];
    
    UIBarButtonItem *businessButton = [[UIBarButtonItem alloc] initWithTitle:@"业务分类"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(businessAction:)];
  
    self.navigationItem.rightBarButtonItem = businessButton;
    
//    业务分类
    [self getYWFLData:self.state];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self queryWithState:self.state withPage:defaultTag];
}

#pragma mark 业务分类
- (void)getYWFLData:(NSString *)state{
    
    NSString *serviceStr = nil;
    // @"需办",@"未完成",@"已办"
    if ([state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    if ([state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    if (ywflData.count >0) {
        [ywflData removeAllObjects];
    }else {
        ywflData = [NSMutableArray array];
    }
    if (ywflName.count >0) {
        [ywflName removeAllObjects];
    }else {
        ywflName = [NSMutableArray array];
    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result){
                NSString *objname = info[@"objname"];
                NSInteger wfnum = [info[@"wfnum"] integerValue];
                NSString *workflowid_ = info[@"workflowid"];
                NSString *key = [NSString stringWithFormat:@"%@(%ld)",objname,(long)wfnum];
                [ywflName addObject:key];
                [ywflData addObject:workflowid_];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    
    [request startAsynchronous];
    
}

#pragma -mark 增加按钮点击事件
- (void)addAction:(id)sender{
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_SelectionModule,self.serviceIPInfo];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
    
        if ([dic[@"success"] integerValue] == kSuccessCode){
        
            NSMutableArray *array = [NSMutableArray array];
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result) {
                SelectionModuleBean *bean = [SelectionModuleBean new];
                bean.cnum = info[@"cnum"];
                bean.objid = info[@"id"];
                bean.objname = info[@"objname"];
                [array addObject:bean];
            }
            
            if (array.count >0) {
                SelectionModuleViewController *selectionModuleViewController = [SelectionModuleViewController new];
                selectionModuleViewController.title = @"选择模块";
                selectionModuleViewController.listData = array;
                [self.navigationController pushViewController:selectionModuleViewController animated:YES];
            }else {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
        
    }];
     
     [request startAsynchronous];
    
}

#pragma -mark 业务分类按钮点击事件
- (void)businessAction:(id)sender{
    
    if (ywflName.count ==0) {
        [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
        return;
    }
    
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] init];
    deviceViewController.infos = ywflName;
    deviceViewController.title = @"业务分类";
    [self.navigationController pushViewController:deviceViewController animated:YES];
    
    [deviceViewController setDeviceTypeBlock:^(NSInteger deviceId, NSString *deviceName) {
        
        if (![workflowid isEqualToString:deviceName]) {
            if ([deviceName hasPrefix:@"全部"]) {
                workflowid = @"";
            }else{
                
                workflowid = ywflData[deviceId];
            }
        }
        
        [self getYWFLData:self.state];
        [self queryWithState:self.state withPage:defaultTag];
      
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
#pragma -mark 需办,未完成,已办三个子页面初始化
- (void)initSlideView{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    screenBound.origin.y = 64;
    
    NSArray *array=[NSArray arrayWithObjects:@"需办",@"未完成",@"已办",nil];
    if (_slideView) {
        [_slideView removeFromSuperview];
    }
    _slideView = [[LeaveSlideView alloc] initWithFrame:screenBound withTitles:array slideColor:kALLBUTTON_COLOR withObjects:tempArray cellName:@"WorkOrderCell"];
    _slideView.cellName=@"WorkOrderCell";
    _slideView.cellHeight = kCellHeight;
    _slideView.delegate=self;
    
    [self.view addSubview:_slideView];
    
    [self.scrollView setContentSize:CGSizeMake(self.viewWidth,CGRectGetHeight(_slideView.frame)+50)];
    
    [_slideView defaultAction:defaultTag];
}

#pragma -mark 需办,未完成,已办三个子页面数据查询
- (void)queryWithState:(NSString *)state withPage:(NSInteger)pageNum{
    
    NSString *serviceStr = nil;
    defaultTag=0;
   // @"需办",@"未完成",@"已办"
    if ([state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        image = [UIImage imageNamed:@"img_daiban"];
        //项目管理
        if (self.moduleFlag ==1){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessXMlist&pageIndex=1",self.serviceIPInfo];
        }
        //形象进度
        if (self.moduleFlag ==2){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessJDlist&pageIndex=1",self.serviceIPInfo];
        }
    }
    
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        defaultTag = 1;
        
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }

    }
    
   
    if ([state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        defaultTag = 2;
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }
    }
    
    if (workflowid.length >0) {
        serviceStr = [NSString stringWithFormat:@"%@&workflowid=%@",serviceStr,workflowid];
    }
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    self.markLabel.hidden=NO;
    
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
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSDictionary *result = dic[@"result"];
            
            NSArray *wflist = result[@"wflist"];
            for (NSDictionary *info in wflist) {
                
                WorkOrderBean *bean = [WorkOrderBean new];
                bean.createdate = info[@"createdate"];
                bean.creator = info[@"creator"];
                bean.dowid = info[@"dowid"];
                bean.downame = info[@"downame"];
                bean._id = info[@"id"];
                bean.processid = info[@"processid"];
                bean.status = info[@"status"];
                bean.title = info[@"title"];
                bean.iconnew = info[@"iconnew"];
                
                if (info[@"currentnode"]) {
                    bean.currentnode = info[@"currentnode"];
                }
                if (info[@"lastcreatedate"]) {
                    bean.lastcreatedate = info[@"lastcreatedate"];
                }
                if (info[@"lastcreator"]) {
                    bean.lastcreator = info[@"lastcreator"];
                }
                [tempArray addObject:bean];
            }
            if (pageNum ==0) {
                [self performSelector:@selector(initSlideView) withObject:nil afterDelay:0.0f];
            }else{
                
                [_slideView.dataSource setObject:tempArray forKey:[NSString stringWithFormat:@"%ld",(long)pageNum]];
                
                [_slideView getDataOver];
            }
            
            if (tempArray.count == 0){
                self.markLabel.text = @"没有数据";
            }else{
                self.markLabel.hidden=YES;
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        self.markLabel.hidden=YES;
        
        if (pageNum ==0) {
            [self performSelector:@selector(initSlideView) withObject:nil afterDelay:0.4f];
        }
    }];

    [request startAsynchronous];
    
}

- (UITableViewCell *)fillCellDataTableView:(UITableView *)tableView withObject:(id)object withPageTag:(NSInteger)page {
    
    static NSString *LeaveTableIdentifier = @"WorkOrderCell";
    
    WorkOrderCell *cell = (WorkOrderCell *)[tableView dequeueReusableCellWithIdentifier:LeaveTableIdentifier];
    if (!cell) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeaveTableIdentifier];
    }
    
    WorkOrderBean *bean = object;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = bean.title;
    cell.titleLabel.font = [UIFont fontWithName:kFontName size:14.0];
    cell.createdateLabel.text = bean.createdate;
    cell.createdateLabel.font = [UIFont fontWithName:kFontName size:12.0];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = image;
    
 
    if ([bean.iconnew isEqualToString:@"1"]) {
        cell.flagImageView.image = [UIImage imageNamed:@"icon_new.png"];
    }else if ([bean.iconnew isEqualToString:@"2"]){

        cell.flagImageView.image = [UIImage imageNamed:@"icon_new_2.png"];
    }else{
        cell.flagImageView.image = nil;
    }
 
    return cell;
}

- (void)openInfoViewWith:(id)object withPageTag:(NSInteger)page{
    
    WorkOrderBean *bean = object;
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = ([self.state isEqualToString:@"getwfprocessDBlist"] && page ==0)?YES:NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    details.hasFavorite = YES;
    [details setSuccessRefreshViewBlock:^{
        [self reloadDataWithPageTag:0 withPageNumber:0];
    }];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)reloadDataWithPageTag:(NSInteger)page withPageNumber:(NSInteger)pageNum{
    
    NSString *state=nil;
    defaultTag = page;
    switch (page) {
        case 0:
            state = @"getwfprocessDBlist";
            image = [UIImage imageNamed:@"img_daiban"];
            break;
        case 1:
            state = @"getwfprocesslist";
            image = [UIImage imageNamed:@"img_yiban"];
            break;
        case 2:
            state = @"getwfprocessYBlist";
            image = [UIImage imageNamed:@"img_wanjie"];
            break;
    }
    
    if (pageNum == 1) {
        workflowid = @"";
    }
    
    self.state = state;
    [self getYWFLData:state];
    
    
    NSString *serviceStr = nil;
    // @"需办",@"未完成",@"已办"
    if ([state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        
        //项目管理
        if (self.moduleFlag ==1){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessXMlist&pageIndex=1",self.serviceIPInfo];
        }
        //形象进度
        if (self.moduleFlag ==2){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessJDlist&pageIndex=1",self.serviceIPInfo];
        }
    }
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }
    }
    
    if ([state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=%@&pageIndex=1",self.serviceIPInfo,state];
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }
    }
    
    if (pageNum > 1) {
        serviceStr = [NSString stringWithFormat:@"%@&workflowid=%@",serviceStr,workflowid];
    }
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    self.markLabel.hidden=NO;
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        NSMutableArray *array = [NSMutableArray array];
       
        if ([dic[@"success"] integerValue] ==1){
            NSDictionary *result = dic[@"result"];
            NSArray *wflist = result[@"wflist"];
           
            for (NSDictionary *info in wflist) {
            
                WorkOrderBean *bean = [WorkOrderBean new];
                bean.createdate = info[@"createdate"];
                bean.creator = info[@"creator"];
                bean.dowid = info[@"dowid"];
                bean.downame = info[@"downame"];
                bean._id = info[@"id"];
                bean.processid = info[@"processid"];
                bean.status = info[@"status"];
                bean.title = info[@"title"];
                bean.iconnew = info[@"iconnew"];
                if (info[@"currentnode"]) {
                    bean.currentnode = info[@"currentnode"];
                }
                if (info[@"lastcreatedate"]) {
                    bean.lastcreatedate = info[@"lastcreatedate"];
                }
                if (info[@"lastcreator"]) {
                    bean.lastcreator = info[@"lastcreator"];
                }
                if ([array indexOfObject:bean] ==NSNotFound) {
                    [array addObject:bean];
                }
            }
            if (array.count == 0){
                self.markLabel.text = @"没有数据";
            }else{
                self.markLabel.hidden=YES;
                [_slideView.dataSource setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)page]];
            }
            
            [_slideView getDataOver];

        }else{
           [MBProgressHUD showError:dic[@"msg"] toView:self.view.window]; 
        }
    
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        self.markLabel.hidden=YES;

    }];
    
    [request startAsynchronous];

}

@end
