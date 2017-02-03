//
//  DocumentViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/6.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "DocumentViewController.h"
//#import "EGORefreshTableHeaderView.h"
#import "DocumentDetailViewController.h"
#import "MJRefresh.h"


@interface DocumentTableViewCell : UITableViewCell
@end;

@implementation DocumentTableViewCell

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(15,(CGRectGetHeight(self.bounds) - 40)/2,40, 40)];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.bounds.size.width/2;
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = kALLBUTTON_COLOR.CGColor;
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.imageView.frame)+10;
    self.textLabel.frame = frame;
    
}
@end;

#define kDocumentFirstRequest @"%@/ext/com.cinsea.action.DocumentAction?action=getDocument&pno=1&pageIndex=%@"
#define kDocumentSecondRequest @"%@/ext/com.cinsea.action.DocumentAction?action=getDocumentlist&pno=1&processid=%@&pageIndex=%@"
#define kDocumentThirdRequest @"%@/ext/com.cinsea.action.DocumentAction?action=getformdata&processid=%@&pageIndex=%@"

@interface DocumentViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *_tableView;
    
    NSArray *listArray;//数据
    NSInteger pageNumber;
    
    NSString *requestStr;
    NSInteger flag;

}


@end

@implementation DocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    listArray = [NSMutableArray array];
    pageNumber = 1;
    requestStr = [NSString stringWithFormat:kDocumentFirstRequest,self.serviceIPInfo,@(pageNumber)];
    flag = 1;
    [self initThisView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}
- (void)initThisView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.viewWidth,self.viewHeight) ];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self reloadData];
    
    __weak DocumentViewController *weakSelf = self;
    __weak UITableView *tableView = _tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pageNumber ++;
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
            pageNumber --;
            if (pageNumber < 1) {
                pageNumber = 1;
            }
            [weakSelf requestData];
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];


    [self.scrollView addSubview:_tableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (flag == 2) {
        flag --;
        pageNumber = 1;
        requestStr = [NSString stringWithFormat:kDocumentFirstRequest,self.serviceIPInfo,@(pageNumber)];
    }
    
    if (flag == 3) {
        flag --;
        pageNumber = 1;
    }
    
     [self requestData];
}

- (void)requestData{

#if defined(DEBUG)||defined(_DEBUG)
   
#endif
    
    NSString *urlStr = requestStr;
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
        
        if ([dic[@"success"] integerValue] == kSuccessCode) {
            NSArray *result = dic[@"result"];
            
            listArray = result;
 
            if (result.count ==0 ) {
                [MBProgressHUD showError:@"没有数据" toView:ShareAppDelegate.window];
            }
            [self reloadData];
            
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    //处理失败
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
    }];
    
    [request startAsynchronous];
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
    
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *tableViewIdentifier = @"TableViewCellIdentifier";
    
    DocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[DocumentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *data = listArray[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"img_xiangmuguanli"];
    
    if (flag == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@（%@）",data[@"objname"],data[@"documentSize"]];
    }else{
        cell.textLabel.text = data[@"subject"];
    }
    
    cell.textLabel.font = [UIFont fontWithName:kFontName size:14];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = listArray[indexPath.row];
    if (flag == 2) {
        [self thirdRequestData:data[@"id"]];
        return;
    }
    pageNumber = 1;
    
    requestStr = [NSString stringWithFormat:kDocumentSecondRequest,self.serviceIPInfo,data[@"id"],@(pageNumber)];
    [self requestData];
    flag = flag + 1;
}

- (void)reloadData{
    
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

- (void)reloadDataWithPageNumber:(NSInteger)pageNum{
    [self requestData];
}

- (void)backAction{
    if (flag == 2) {
        [self viewWillAppear:YES];
        return;
    }
    
    [super backAction];
}

- (void)thirdRequestData:(NSString *)processid{
    
    flag = 3;
    
    NSString *urlStr = [NSString stringWithFormat:kDocumentThirdRequest,self.serviceIPInfo,processid,@(pageNumber)];
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
        
        if ([dic[@"success"] integerValue] == kSuccessCode) {
            NSDictionary *result = dic[@"result"];
            NSString *strValue = [NSString stringWithFormat:@"  文档编号：%@\n",result[@"objno"]];
            strValue = [strValue stringByAppendingFormat:@"  标题：%@\n",result[@"title"]];
            strValue = [strValue stringByAppendingFormat:@"  创建人：%@\n",result[@"creator"]];
            strValue = [strValue stringByAppendingFormat:@"  创建时间：%@\n",result[@"createdate"]];
            strValue = [strValue stringByAppendingFormat:@"  内容：%@\n",result[@"doccontent"]?result[@"doccontent"]:@""];
            
            if (result.count ==0) {
                [MBProgressHUD showError:@"没有数据" toView:ShareAppDelegate.window];
                return;
            }
            
            DocumentDetailViewController *documentDetailViewController = DocumentDetailViewController.new;
            documentDetailViewController.valueStr = strValue;
            documentDetailViewController.title = @"文档";
            documentDetailViewController.img = result[@"img"];
            documentDetailViewController.docattach = result[@"docattach"];
            documentDetailViewController.replyList = result[@"replyList"];
            [self.navigationController pushViewController:documentDetailViewController animated:YES];
            
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
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
