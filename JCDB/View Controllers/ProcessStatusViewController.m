//
//  ProcessStatusViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/1.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "ProcessStatusViewController.h"
#import "ProcessStatusHeadView.h"
#import "ProcessStatusCell.h"

@interface ProcessStatusViewController ()<UITableViewDataSource,UITableViewDelegate,ProcessStatusHeadViewDelegate>{
    UITableView* _tableView;
    NSInteger _currentSection;
    NSInteger _currentRow;
    
    NSDictionary *wfoperatetype;
    NSArray *jsonList;
    
}
@property(nonatomic, strong) NSMutableArray* headViewArray;

@end

@implementation ProcessStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)requestData{
    
    NSString *test = @"%@/ext/com.cinsea.action.WfprocessgraphAction?action=getWfprocessgraph&workflowid=%@&processid=%@";
    
    NSString *urlStr = [NSString stringWithFormat:test,self.serviceIPInfo,self.workflowid,self.processid];
    
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
            wfoperatetype = result[@"wfoperatetype"];
            jsonList = result[@"jsonList"];
    

            if (result.count ==0 || wfoperatetype.count == 0 || jsonList.count ==0) {
                [MBProgressHUD showError:@"没有数据" toView:ShareAppDelegate.window];
            }else{
        
                [self initThisView];
            }
            
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

- (void)initThisView{
    
    [self loadModel];
    
    NSString *nosubmit = [NSString stringWithFormat:@"未提交\n%@",wfoperatetype[@"nosubmit"]];
    NSString *noview = [NSString stringWithFormat:@"未查看\n%@",wfoperatetype[@"noview"]];
    NSString *submit = [NSString stringWithFormat:@"已提交\n%@",wfoperatetype[@"submit"]];
    NSString *view = [NSString stringWithFormat:@"已查看\n%@",wfoperatetype[@"view"]];
    NSArray *titleArray = @[nosubmit,noview,submit,view];
    CGFloat width = self.viewWidth /4.0;
    CGRect frame = CGRectMake(0,0,width,40);
    for(NSString *title in titleArray){
        UIView *view = [self addTitleViewWithFrame:frame title:title];
        [self.scrollView addSubview:view];
        frame.origin.x += width;
    }
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(frame),self.viewWidth,self.viewHeight -40) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollView addSubview:_tableView];
    
    UINib *nib = [UINib nibWithNibName:@"ProcessStatusCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"ProcessStatusCell"];
    
    [_tableView reloadData];
    
}

- (UIView*)addTitleViewWithFrame:(CGRect)frame title:(NSString *)title{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame))];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:kFontName size:14];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    
     UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(frame)-1,CGRectGetWidth(frame),1)];
    lineLabel.backgroundColor = kRandomColor;
    
    [view addSubview:lineLabel];

    return view;
}

- (void)loadModel{
    _currentRow = -1;
    _headViewArray = [[NSMutableArray alloc] init];
    for(int i = 0;i< jsonList.count ;i++){
        ProcessStatusHeadView* headview = [[ProcessStatusHeadView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 40)];
        headview.delegate = self;
        headview.section = i;
        headview.open = YES;
        headview.titleLabel.text = jsonList[i][@"nodeName"];
        headview.statusListCount = [jsonList[i][@"wfstatusList"] count];
        [self.headViewArray addObject:headview];
    }
}

#pragma mark - TableViewdelegate&&TableViewdataSource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProcessStatusHeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
    
    return headView.open?90:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self.headViewArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ProcessStatusHeadView* headView = [self.headViewArray objectAtIndex:section];
    return headView.open?headView.statusListCount:0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.headViewArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"ProcessStatusCell";
    ProcessStatusCell *cell = (ProcessStatusCell *)[tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[ProcessStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
   
    NSDictionary *data = jsonList[indexPath.section][@"wfstatusList"][indexPath.row];
    NSString *operator = data[@"operator"];
    if (operator == nil) {
        operator = @"";
    }
    NSString *receivetime = data[@"receivetime"];
    if (receivetime == nil) {
        receivetime = @"";
    }
    NSString *datetime = data[@"datetime"];
    if (datetime == nil) {
        datetime = @"";
    }
    NSString *elapsedtime = data[@"elapsedtime"];
    if (elapsedtime == nil) {
        elapsedtime = @"";
    }
    cell.nameLabel.text = operator;
    cell.acceptTimeLabel.text = [NSString stringWithFormat:@"接受时间：%@",receivetime];
    cell.operateTimeLabel.text = [NSString stringWithFormat:@"操作时间：%@",datetime];
    cell.timeLabel.text = [NSString stringWithFormat:@"耗时：%@",elapsedtime];
    cell.statusLabel.text = data[@"opttype"]?data[@"opttype"]:@"未提交";

    NSString *urlStr = data[@"phototUrl"];
    [self roundImageView:cell.txImageView withColor:kALLBUTTON_COLOR];
    [cell.txImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"img_user_default"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentRow = indexPath.row;
    [_tableView reloadData];
}


#pragma mark - HeadViewdelegate
-(void)selectedWith:(ProcessStatusHeadView *)view{
    _currentSection = view.section;

    for(int i = 0;i<[_headViewArray count];i++){
        ProcessStatusHeadView *head = [_headViewArray objectAtIndex:i];
        if(head.section == _currentSection){
            if (head.open) {
                head.open = NO;
                head.imageView.image = [UIImage imageNamed:@"img_wf_log_b"];
            }else{
                head.open = YES;
                head.imageView.image = [UIImage imageNamed:@"img_wf_log_a"];
            }
        }
    }
    [_tableView reloadData];
}

@end
