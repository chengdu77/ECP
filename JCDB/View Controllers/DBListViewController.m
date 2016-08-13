//
//  DBListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/25.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "DBListViewController.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "WorkOrderDetailsViewController.h"
#import "DeviceViewController.h"

@interface DBListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;

    NSMutableArray *tempArray;
    
    NSString *workflowid;
    NSMutableArray *ywflData;
    NSMutableArray *ywflName;

}

@end

@implementation DBListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    UIBarButtonItem *businessButton = [[UIBarButtonItem alloc] initWithTitle:@"业务分类"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(businessAction:)];
    
    self.navigationItem.rightBarButtonItem = businessButton;
    
    //    业务分类
    [self getYWFLData];
    
    
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 业务分类
- (void)getYWFLData{
    
    NSString *serviceStr = nil;
    // @"需办",@"未完成",@"已办"
    if ([self.state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    if ([self.state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    if ([self.state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",self.serviceIPInfo];
    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        if (!ywflName) {
            ywflName = [NSMutableArray array];
        }
        
        if (!ywflData) {
            ywflData = [NSMutableArray array];
        }
        
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

        [self requestData];
        
    }];
}

#pragma mark 业务分类
- (void)requestData{
        
    NSString *serviceStr = nil;
    
    // @"需办",@"未完成",@"已办"
    if ([self.state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=%@&pageIndex=1",self.serviceIPInfo,self.state];
    }
    
    if ([self.state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=%@&pageIndex=1",self.serviceIPInfo,self.state];
    }
    
    if (workflowid.length >0) {
        serviceStr = [NSString stringWithFormat:@"%@&workflowid=%@",serviceStr,workflowid];
    }
    
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
            
            
            [_tableView reloadData];
            [self.scrollView setContentSize:CGSizeMake(self.viewWidth,CGRectGetHeight(_tableView.frame)+50)];
            
            if (tempArray.count == 0){
                [MBProgressHUD showError:@"没有数据" toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
    }];
    
    [request startAsynchronous];

}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tempArray.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *tableViewIdentifier = @"WorkOrderCell";
    
    WorkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    WorkOrderBean *bean = tempArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.titleLabel.text = bean.title;
    cell.titleLabel.font = [UIFont fontWithName:kFontName size:14.0];
    cell.createdateLabel.text = bean.createdate;
    cell.createdateLabel.font = [UIFont fontWithName:kFontName size:12.0];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    
    UIImage *image = [UIImage imageNamed:@"img_daiban"];
    if ([self.state isEqualToString:@"getwfprocessYBlist"]){
        image = [UIImage imageNamed:@"img_yiban"];
    }
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderBean *bean = tempArray[indexPath.row];
    
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = YES;
    details.hasFavorite = NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
        //        [self reloadDataWithPageTag:0 withPageNumber:0];
    }];
    [self.navigationController pushViewController:details animated:YES];
    
    
}


@end
