//
//  EndMatterNewListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/9/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "EndMatterNewListViewController.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "WorkOrderDetailsViewController.h"

@interface EndMatterNewListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *tempArray;
    UIImage *image;
    
    NSInteger pageIndex;
}


@property (nonatomic,strong) NSString *serviceIPInfo;

@end

@implementation EndMatterNewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageIndex = 1;
    
    self.serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width,self.view.bounds.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];

    
    __weak EndMatterNewListViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    
  [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
   [self.tabBarController.tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    _tableView.frame = self.view.bounds;
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
    cell.createdateLabel.text = bean.createdate;
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = image;
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderBean *bean = tempArray[indexPath.row];
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
        [self reloadDataWithTag:self.index flag:YES];
    }];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)reloadDataWithTag:(NSUInteger)tag flag:(BOOL)flag{
    
    if (!flag) {
        pageIndex = 1;
    }
    
    NSString *state=nil;
    switch (tag) {
        case 0:
            state = @"getwfprocessWJlist";
            image = [UIImage imageNamed:@"img_daiban"];
            break;
        case 1:
            state = @"getwfprocesslist";
            image = [UIImage imageNamed:@"img_daiban"];
            break;
    }
    
    NSString *serviceStr = nil;
    // @"办结事宜",@"完结事宜"
    if ([state isEqualToString:@"getwfprocessWJlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessWJAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageIndex)];
    }
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessywcAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageIndex)];
    }
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
//    [self setCookie:url];
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
          
                [tempArray addObject:bean];
                
            }
            
            [_tableView.mj_header endRefreshing];
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

- (void)roundImageView:(UIImageView *)imageView withColor:(UIColor *)color{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
    imageView.layer.borderWidth = 2.0;
    if (!color) {
        color = [UIColor whiteColor];
    }
    imageView.layer.borderColor = color.CGColor;
}


@end
