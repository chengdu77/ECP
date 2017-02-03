//
//  WorkOrderPageViewController.m
//  Pods
//
//  Created by WangJincai on 16/9/29.
//
//

#import "WorkOrderPageViewController.h"
#import "WorkOrderNewListViewController.h"
#import "DeviceViewController.h"

@interface WorkOrderPageViewController ()<TYPagerControllerDataSource>{
    
    TYTabButtonPagerController *_pagerController;
    
    NSArray *pageNames;
    
    NSMutableArray *tagViewArray;

    NSMutableDictionary *ywInfos;
}

@property (nonatomic,strong) NSString *state;
@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation WorkOrderPageViewController

- (void)viewDidLoad {
    self.flag = YES;
    [super viewDidLoad];
    
     pageNames = @[@"需办",@"未完成",@"已办"];
    [self getYWList];
    
    tagViewArray = [NSMutableArray array];
    ywInfos = [NSMutableDictionary dictionary];
    _currentIndex= 0;
    
    UIBarButtonItem *businessButton = [[UIBarButtonItem alloc] initWithTitle:@"业务分类"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(businessAction:)];
    
    self.navigationItem.rightBarButtonItem = businessButton;
    
    
    for (NSUInteger i=0;i<pageNames.count;i++) {
        WorkOrderNewListViewController *vc = [WorkOrderNewListViewController new];
        vc.index = i;
         [tagViewArray insertObject:vc atIndex:i];
    }
   
    [self addPagerController];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma -mark 业务分类按钮点击事件
- (void)businessAction:(id)sender{
    
    if (ywInfos.count ==0) {
        [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
        return;
    }
    
    NSArray *data = ywInfos[@(_currentIndex)];
    
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] init];
    deviceViewController.infos = data[0];
    deviceViewController.title = @"业务分类";
    [self.navigationController pushViewController:deviceViewController animated:YES];
    
    [deviceViewController setDeviceTypeBlock:^(NSInteger deviceId, NSString *deviceName) {
        
        NSString *workflowid = data[1][deviceId];
        WorkOrderNewListViewController *vc = tagViewArray[_currentIndex];
        [vc businessWithIndex:workflowid];
        
    }];
    
}

- (void)addPagerController{
    
    _pagerController = [[TYTabButtonPagerController alloc]init];
    _pagerController.dataSource = self;
    _pagerController.adjustStatusBarHeight = YES;
    _pagerController.barStyle = TYPagerBarStyleCoverView;
    _pagerController.cellSpacing = 8;
    
    _pagerController.progressColor = kALLBUTTON_COLOR;
    _pagerController.collectionViewBarColor = kBackgroundColor;
    
    
    _pagerController.view.frame = self.scrollView.bounds;
    [self addChildViewController:_pagerController];
    [self.scrollView addSubview:_pagerController.view];
    
    [_pagerController reloadData];
    [_pagerController moveToControllerAtIndex:0 animated:YES];
    
    __weak WorkOrderPageViewController *weakSelf = self;
    _pagerController.scrollToTabPageIndexBlock = ^(NSInteger index){
        
        weakSelf.currentIndex = index;
    };
    
}

#pragma mark - TYPagerControllerDataSource
- (NSInteger)numberOfControllersInPagerController{
    return pageNames.count;
}

- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index{
    return pageNames[index];
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index{
    
    return tagViewArray[index];
}

#pragma mark 业务分类
- (void)getYWFLData:(NSString *)state{
    
    NSNumber *key = @(0);
    NSString *serviceStr = nil;
    NSString *_serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    // @"需办",@"未完成",@"已办"
    if ([state isEqualToString:@"getwfprocessDBlist"]){
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessDBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",_serviceIPInfo];
         key = @(0);
    }
    
    if ([state isEqualToString:@"getwfprocesslist"]){
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessqqwwcAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",_serviceIPInfo];
        key = @(1);
    }
    
    if ([state isEqualToString:@"getwfprocessYBlist"]){
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessYBAction?action=getWfdefine&action=getwfprocessDBlist&pageIndex=1",_serviceIPInfo];
        key = @(2);
    }
    

    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        NSMutableArray *ywData = [NSMutableArray array];
        NSMutableArray *ywName = [NSMutableArray array];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result){
                NSString *objname = info[@"objname"];
                NSInteger wfnum = [info[@"wfnum"] integerValue];
                NSString *workflowid_ = info[@"workflowid"];
                NSString *key = [NSString stringWithFormat:@"%@(%@)",objname,@(wfnum)];
                
                [ywName addObject:key];
                [ywData addObject:workflowid_];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [ywInfos setObject:@[ywName,ywData] forKey:key];
            });
        }
    }];
    
    [request startAsynchronous];
    
}

- (void)getYWList{
    NSArray *array = @[@"getwfprocessDBlist",@"getwfprocesslist",@"getwfprocessYBlist"];
    for (NSInteger i=0;i<array.count;i++) {
        NSString *state = array[i];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getYWFLData:state];
        });
    }
}


@end
