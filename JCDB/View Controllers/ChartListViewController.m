//
//  ChartListViewController.m
//  JCDB
//
//  Created by WangJincai on 16/3/30.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ChartListViewController.h"
#import "TOWebViewController.h"
#import "WorkOrderCell.h"

//{"bblx":"饼图","bbmc":"已办流程","biaoti":"饼图示例22221","id":"297e9e7951f6dc9801522024cf4219e2","sfsjxs":"是","zhixingsql":"select * from v_zyb"}

@interface ChartListBean : NSObject

@property (nonatomic,strong) NSString *bblx;
@property (nonatomic,strong) NSString *bbmc;
@property (nonatomic,strong) NSString *biaoti;
@property (nonatomic,strong) NSString *objid;
@property (nonatomic,strong) NSString *sfsjxs;
@property (nonatomic,strong) NSString *zhixingsql;

@end

@implementation ChartListBean

@end


@interface ChartListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSArray *listData;
}

@end

@implementation ChartListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.scrollView addSubview:_tableView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(_tableView.frame) +10);
    
    [self requestChartListData];
    
    _tableView.backgroundColor = kBackgroundColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)requestChartListData{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_ChartList,self.serviceIPInfo];
    
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
            
            NSMutableArray *array = [NSMutableArray array];
            NSArray *result = dic[@"return"];
            for (NSDictionary *info in result) {
                ChartListBean *bean = [ChartListBean new];
                bean.bblx = info[@"bblx"];
                bean.objid = info[@"id"];
                bean.bbmc = info[@"bbmc"];
                bean.biaoti = info[@"biaoti"];
                bean.sfsjxs = info[@"sfsjxs"];
                bean.zhixingsql = info[@"zhixingsql"];
                [array addObject:bean];
            }
            
            if (array.count >0) {
                listData = [NSArray arrayWithArray:array];
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return listData.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *LeaveTableIdentifier = @"WorkOrderCell";
    
    WorkOrderCell *cell = (WorkOrderCell *)[tableView dequeueReusableCellWithIdentifier:LeaveTableIdentifier];
    if (!cell) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeaveTableIdentifier];
    }
    
    ChartListBean *bean = listData[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = bean.biaoti;
    cell.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    cell.createdateLabel.text = bean.bbmc;
    cell.createdateLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    
    UIImage *image = [UIImage imageNamed:@"img_chart"];
//    CGSize size = {50,50};
//    image = [self scaleToSize:image size:size];
    //[self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChartListBean *bean = listData[indexPath.row];

    NSString *serviceStr = [NSString stringWithFormat:kURL_ChartDeatails,self.serviceIPInfo,bean.objid];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    webViewController.hidesBottomBarWhenPushed=YES;
    webViewController.title = bean.biaoti;
    webViewController.view.backgroundColor = kBackgroundColor;
    [self.navigationController pushViewController:webViewController animated:YES];

}

@end
