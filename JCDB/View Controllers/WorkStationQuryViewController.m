//
//  WorkStationQuryViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/8.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "WorkStationQuryViewController.h"
#import "WorkOrderDetailsViewController.h"
#import "MJRefresh.h"

@interface WorkStationQuryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}

@property (nonatomic,strong) NSArray *listData;

@end

@implementation WorkStationQuryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self initThisView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)requestData{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSString *serviceStr = self.queryConditions;
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            
            NSArray *result = dic[@"result"];

            _listData = [NSArray arrayWithArray:result];
            
            if (result.count >0) {
                [_tableView.mj_header endRefreshing];
                [_tableView reloadData];
            }else {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    }];
    
    [request startAsynchronous];
    
}

- (void)initThisView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.viewWidth,self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.scrollView addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    
    
    [self requestData];

    __weak WorkStationQuryViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestData];
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
            [weakSelf requestData];
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.listData.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *tableViewIdentifier = @"TableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *info = self.listData[indexPath.row];
    cell.textLabel.text = info[@"objname"];
    cell.textLabel.font = [UIFont fontWithName:kFontName size:14];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *info = self.listData[indexPath.row];

    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.title = @"详情";
    details.canEditFlag = YES;
    details.processid = info[@"ID"];
    details.currentnode = info[@"ID"];
    details.hasFavorite = YES;
    details.type = 1;
    
    [details setSuccessRefreshViewBlock:^{
        [self requestData];
    }];
 
    [self.navigationController pushViewController:details animated:YES];
}

@end
