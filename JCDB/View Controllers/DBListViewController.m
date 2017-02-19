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
#import "MJRefresh.h"
#import "Constants.h"


@interface DBListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;

    NSMutableArray *tempArray;
    
    NSString *workflowid;
    NSMutableArray *ywflData;
    NSMutableArray *ywflName;
    
    NSInteger pageIndex;
    NSInteger totalPageCount;

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
    
    pageIndex = 1;
    
    __weak DBListViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pageIndex ++;
            if (pageIndex > totalPageCount) {
                pageIndex = totalPageCount;
            }
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
            pageIndex --;
            if (pageIndex < 1) {
                pageIndex = 1;
            }
            [weakSelf requestData];
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];

}

-(NSAttributedString *)attributeStringWithImage:(UIImage *)image andContent:(NSString *)text{
    //创建可变富文本
    NSMutableAttributedString * mAttriStr=[[NSMutableAttributedString alloc] init];
    //创建附件，将图片转换为文本
    NSTextAttachment * attach=[[NSTextAttachment alloc] init];
    attach.image=image;
    attach.bounds = CGRectMake(0, -3, 15, 15);
    
    //创建富文本文件
    NSString * textStr=[NSString stringWithFormat:@"%@",text];
    NSAttributedString * attriText=[[NSAttributedString alloc] initWithString:textStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:RGB(128, 128, 128)}];
    
    NSString * textStr2=[NSString stringWithFormat:@"   "];
    NSAttributedString * attriText2=[[NSAttributedString alloc] initWithString:textStr2 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:RGB(128, 128, 128)}];
    
    [mAttriStr appendAttributedString:attriText];
    [mAttriStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    [mAttriStr appendAttributedString:attriText2];
    
    return mAttriStr;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=%@",self.serviceIPInfo,@(pageIndex)];
    }
    
    if ([self.state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=%@",self.serviceIPInfo,@(pageIndex)];
    }
    
    if ([self.state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=%@",self.serviceIPInfo,@(pageIndex)];
    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        if (!ywflName) {
            ywflName = [NSMutableArray array];
        }else{
            [ywflName removeAllObjects];
        }
        
        if (!ywflData) {
            ywflData = [NSMutableArray array];
        }else{
            [ywflData removeAllObjects];
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
    
    pageIndex = 1;
    
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
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=%@&pageIndex=%@",self.serviceIPInfo,self.state,@(pageIndex)];
    }
    
    if ([self.state isEqualToString:@"getwfprocessYBlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=%@&pageIndex=%@",self.serviceIPInfo,self.state,@(pageIndex)];
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
            
            totalPageCount = [result[@"totalPageCount"] integerValue];
            
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
    details.canEditFlag = ([self.title isEqualToString:@"已办事项"])?NO:YES;
    details.hasFavorite = NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
        //        [self reloadDataWithPageTag:0 withPageNumber:0];
    }];
    [self.navigationController pushViewController:details animated:YES];
    
    
}

@end
