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
#import "PullingRefreshTableView.h"

@interface MessageViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>{
    
    PullingRefreshTableView *_tableView;
    
    NSMutableArray *listArray;//数据
    NSInteger pageNumber;
}


@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息列表";
    
     pageNumber = 1;
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initThisView{
    
    if (_tableView) {
        [_tableView removeFromSuperview];
    }
    
    _tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0,0,self.viewWidth,self.viewHeight) pullingDelegate:self];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self reloadData];
    
    [self.scrollView addSubview:_tableView];
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
        [self reloadDataWithPageNumber:pageNumber];
    }];
    [self.navigationController pushViewController:details animated:YES];
}



#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    pageNumber++;
    [self reloadDataWithPageNumber:pageNumber];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *currentDateStr = [df stringFromDate:[NSDate date]];
    NSDate *date = [df dateFromString:currentDateStr];
    return date;
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *currentDateStr = [df stringFromDate:[NSDate date]];
    NSDate *date = [df dateFromString:currentDateStr];
    return date;
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    pageNumber++;
    [self reloadDataWithPageNumber:pageNumber];
}

- (void)reloadData{
    
    [_tableView reloadData];
    [_tableView tableViewDidFinishedLoading];
    _tableView.reachedTheEnd = NO;
    
}

- (void)reloadDataWithPageNumber:(NSInteger)pageNum{
    
    [self reloadData];
    
}


//拖拽后调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_tableView tableViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_tableView tableViewDidScroll:scrollView];
}

- (void)requestData{

    NSString *urlStr = [NSString stringWithFormat:kURL_NotifyAction,self.serviceIPInfo];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
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
