//
//  MessageViewController.m
//  JCDB
//
//  Created by WangJincai on 16/6/30.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "MessageViewController.h"
#import "WorkOrderDetailsViewController.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"
#import "MJRefresh.h"

@interface MessageViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *_tableView;
    
    NSMutableArray *listArray;//数据
    NSInteger pageIndex;
}

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息列表";
    if (self.listFlag.length>0)
        self.title = @"查询结果";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    pageIndex = 1;
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initThisView{
    
    if (_tableView) {
        [_tableView removeFromSuperview];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.viewWidth,self.viewHeight)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self reloadData];
    
    [self.scrollView addSubview:_tableView];
    
    __weak MessageViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pageIndex ++;
            [weakSelf reloadData];
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
            [weakSelf reloadData];
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
    
}

#pragma mark -- talbeView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkOrderCell"];
    if (cell == nil) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkOrderCell"];
    }
    
    WorkOrderBean *bean = listArray[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = bean.title;
    cell.titleLabel.font = [UIFont fontWithName:kFontName size:14.0];
    cell.createdateLabel.text = bean.createdate;
    cell.createdateLabel.font = [UIFont fontWithName:kFontName size:12.0];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = [UIImage imageNamed:@"img_daiban"];
    
    
    if ([bean.iconnew isEqualToString:@"1"]) {
        cell.flagImageView.image = [UIImage imageNamed:@"icon_new.png"];
    }else if ([bean.iconnew isEqualToString:@"2"]){
        
        cell.flagImageView.image = [UIImage imageNamed:@"icon_new_2.png"];
    }else{
        cell.flagImageView.image = nil;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderBean *bean = listArray[indexPath.row];
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = YES;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    details.hasFavorite = YES;
    [details setSuccessRefreshViewBlock:^{
        [self reloadDataWithPageNumber:pageIndex];
    }];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)reloadData{
    
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
 
}

- (void)reloadDataWithPageNumber:(NSInteger)pageNum{
    
    [self reloadData];
    
}


- (void)requestData{
    
    NSString *urlStr = [NSString stringWithFormat:kURL_NotifyAction,self.serviceIPInfo,@(pageIndex)];
    
    if (self.listFlag.length >0)//搜索
        urlStr = [NSString stringWithFormat:kURL_FoundAction,self.serviceIPInfo,self.foundValue,@(pageIndex)];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err = nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if (!listArray) {
            listArray = [NSMutableArray array];
        }else{
            [listArray removeAllObjects];
        }
        
        id obj = dic[@"result"];
        if ([dic[@"success"] integerValue] == kSuccessCode && obj && [obj isKindOfClass:[NSArray class]]) {
            NSArray *result = obj;
            for (NSDictionary *info in result) {
                
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
                [listArray addObject:bean];
            }
            if (listArray.count >0) {
                [self performSelector:@selector(initThisView) withObject:nil afterDelay:0.0f];
            }else{
                [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:@"没有数据" toView:ShareAppDelegate.window];
        }
    }];
    
    //处理失败
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
    }];
    
    [request startAsynchronous];
}



@end
