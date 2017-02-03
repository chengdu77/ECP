//
//  EndMatterListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/30.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "EndMatterListViewController.h"
#import "WorkOrderDetailsViewController.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"

@interface EndMatterListViewController ()<LeaveSlideViewDelegate>{
    NSMutableArray *tempArray;
    UIImage *image;
    
    NSInteger defaultTag;//默认选择按钮标识
}

@property(nonatomic,strong)UILabel *markLabel;
@property (strong, nonatomic) LeaveSlideView *slideView;

@end

@implementation EndMatterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事项列表";
    
    self.markLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 40)];
    self.markLabel.text=@"正在加载数据";
    self.markLabel.textAlignment=NSTextAlignmentCenter;
    self.markLabel.font=[UIFont systemFontOfSize:15.0];
    self.markLabel.hidden=YES;
    [self.scrollView addSubview:self.markLabel];
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self queryWithState:self.state withPage:0];
}

-(void) initSlideView{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    //    screenBound.origin.y = 60;
    
    NSArray *array=[NSArray arrayWithObjects:@"办结事宜",@"完结事宜",nil];
    _slideView = [[LeaveSlideView alloc] initWithFrame:screenBound withTitles:array slideColor:kALLBUTTON_COLOR withObjects:tempArray cellName:@"WorkOrderCell"];
    _slideView.cellName=@"WorkOrderCell";
    _slideView.cellHeight=56.0;
    _slideView.delegate=self;
    [self.scrollView addSubview:_slideView];
    
    [_slideView defaultAction:defaultTag];
}
- (void)queryWithState:(NSString *)state withPage:(NSInteger)pageNum{
    
    NSString *serviceStr = nil;
    defaultTag=0;
    // @"办结事宜",@"完结事宜"
    if ([state isEqualToString:@"getwfprocessWJlist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessWJAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageNum)];
        image = [UIImage imageNamed:@"img_daiban"];
    }
    
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessywcAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageNum)];
        defaultTag = 1;
        image = [UIImage imageNamed:@"img_daiban"];
    }
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    self.markLabel.hidden=NO;
    
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
        if ([dic[@"success"] integerValue] ==1){
            NSDictionary *result = dic[@"result"];
//            NSLog(@"result:%@",result);
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
            
            if (pageNum ==1) {
                [self performSelector:@selector(initSlideView) withObject:nil afterDelay:0.4f];
            }

        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        self.markLabel.hidden=YES;
        
        if (pageNum ==1) {
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
    
    cell.titleLabel.text = bean.title;
    cell.createdateLabel.text = bean.createdate;
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = image;
    
    return cell;
}

- (void)openInfoViewWith:(id)object withPageTag:(NSInteger)page{
    
    WorkOrderBean *bean = object;
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
        [self reloadDataWithPageTag:0 withPageNumber:1];
    }];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)reloadDataWithPageTag:(NSInteger)page withPageNumber:(NSInteger)pageNum{
    
    NSString *state=nil;
    switch (page) {
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
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessWJAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageNum)];
    }
    
    if ([state isEqualToString:@"getwfprocesslist"]) {
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessywcAction?action=%@&pageIndex=%@",self.serviceIPInfo,state,@(pageNum)];
    }

    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    self.markLabel.hidden=NO;
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
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
            [_slideView.dataSource setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)page]];
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
