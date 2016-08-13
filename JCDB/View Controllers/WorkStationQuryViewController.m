//
//  WorkStationQuryViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/8.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "WorkStationQuryViewController.h"
#import "WorkOrderDetailsViewController.h"

@interface WorkStationQuryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}

@property (nonatomic,strong) NSArray *listData;

@end

@implementation WorkStationQuryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestData];
    
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
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            
            NSArray *result = dic[@"result"];

            _listData = [NSArray arrayWithArray:result];
            
            if (result.count >0) {
                [self initThisView];
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
    
    if (_tableView) {
        [_tableView removeFromSuperview];
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.scrollView addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(_tableView.frame) +10);
    
    [_tableView reloadData];
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
