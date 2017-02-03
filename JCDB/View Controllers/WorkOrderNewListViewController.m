//
//  WorkOrderNewListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/9/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "WorkOrderNewListViewController.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "WorkOrderDetailsViewController.h"
#import "DeviceViewController.h"

@interface WorkOrderNewListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *tempArray;
    
    NSString *workflowid;
    NSMutableArray *ywflData;
    NSMutableArray *ywflName;
    
    BOOL businessFlag;
    
    NSInteger pageIndex;
}

@end

@implementation WorkOrderNewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageIndex = 1;
    [self initThisView];
}

- (void)initThisView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.scrollView addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    switch (self.index) {
        case 0:
            self.state = @"getwfprocessDBlist";
            break;
        case 1:
            self.state = @"getwfprocesslist";
            break;
        case 2:
            self.state = @"getwfprocessYBlist";
            break;
    }
    
    __weak WorkOrderNewListViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            businessFlag = NO;
            pageIndex ++;
            [weakSelf reloadDataWithTag:self.index flag:YES];
            // 结束刷新
            [tableView.mj_header endRefreshing];
        });
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pageIndex --;
            if (pageIndex < 1) {
                pageIndex = 1;
            }
            [weakSelf reloadDataWithTag:self.index flag:YES];
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
    
    [self reloadDataWithTag:self.index flag:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma -mark 需办,未完成,已办三个子页面数据查询
- (void)reloadDataWithTag:(NSInteger)tag flag:(BOOL)flag{
    
    NSString *serviceStr = nil;
    if (!flag) pageIndex = 1;

    // @"需办",@"未完成",@"已办"
    if ([self.state isEqualToString:@"getwfprocessDBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=%@&pageIndex=%@",self.serviceIPInfo,self.state,@(pageIndex)];
        //项目管理
        if (self.moduleFlag ==1){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessXMlist&pageIndex=%@",self.serviceIPInfo,@(pageIndex)];
        }
        //形象进度
        if (self.moduleFlag ==2){
            serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessXMAction?action=getwfprocessJDlist&pageIndex=%@",self.serviceIPInfo,@(pageIndex)];
        }
    }
    
    if ([self.state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=%@&pageIndex=%@",self.serviceIPInfo,self.state,@(pageIndex)];

        
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }
        
    }
    
    
    if ([self.state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=%@&pageIndex=%@",self.serviceIPInfo,self.state,@(pageIndex)];
        //项目管理或形象进度
        if (self.moduleFlag >0){
            serviceStr = [NSString stringWithFormat:@"%@&requestFlag=%@",serviceStr,@(self.moduleFlag)];
        }
    }
    
    if (workflowid.length >0) {
        serviceStr = [NSString stringWithFormat:@"%@&workflowid=%@",serviceStr,workflowid];
    }
    
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
            
            if (flag) {
                [_tableView.mj_header endRefreshing];
            }
            
            [_tableView reloadData];
            
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

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _tableView.frame = self.scrollView.bounds;
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
    

    UIImage *image;
    switch (self.index) {
        case 0:
            image = [UIImage imageNamed:@"img_daiban"];
            break;
        case 1:
            
            image = [UIImage imageNamed:@"img_yiban"];
            break;
        case 2:
            
            image = [UIImage imageNamed:@"img_wanjie"];
            break;
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderBean *bean = tempArray[indexPath.row];
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = YES;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
        [self reloadDataWithTag:self.index flag:NO];
    }];
    [self.navigationController pushViewController:details animated:YES];
}


- (void)businessWithIndex:(NSString *)workflowid_{
    
    workflowid = workflowid_;
    [self reloadDataWithTag:self.index flag:NO];

}




@end
