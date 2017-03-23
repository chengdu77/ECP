//
//  FirstViewController.m
//  KSJX
//
//  Created by wangjc on 15-6-28.
//  Copyright (c) 2015年 wjc. All rights reserved.
//

#import "FirstViewController.h"

#import "JGGModel.h"
#import "JGGView.h"
#import "JGGLabel.h"

#import "UIView+WZLBadge.h"
#import "StaffContactsViewController.h"
#import "MyPhotographViewController.h"
#import "EndMatterPageViewController.h"
#import "ScheduleInfoViewController.h"
#import "ChartListViewController.h"
#import "MessageViewController.h"
#import "DocumentViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "CCLocationManager.h"
#import "CLLocation+YCLocation.h"

#import "NotiSettingViewController.h"
#import "DBListViewController.h"

#import "DXPopover.h"

#define kDaibanRedPointViewTag 100
#define kQqwwcRedPointViewTag 101
#define kYibanRedPointViewTag 102

@interface FirstViewController ()<CLLocationManagerDelegate>{
  
    NSMutableArray *redViewArrays;
    NSArray *wfprocessValues;
    
    NSTimer *timer;
    
    UIView *foundView;
    UITextField *foundTextField;
}


@property (nonatomic, strong) NSArray *appList;
@property (nonatomic, strong) JGGLabel *myLabel;

@property (nonatomic, strong) NSString *jingweidu;
@property (nonatomic, strong) NSString *didian;

@property (nonatomic ,strong) UIView *falsePushView;//伪推送View

@property (nonatomic, strong) DXPopover *popover;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation FirstViewController


-(void)viewWillDisappear:(BOOL)animated{

}

- (void)initPopFoundView {
    
    _popover = [DXPopover new];
    _popover.cornerRadius = 0;
    _popover.arrowSize = CGSizeMake(26, 12);
    
    foundView = [[UIView alloc] init];
    foundView.frame = CGRectMake(0, 0, self.viewWidth, 90);
    foundView.backgroundColor = [UIColor whiteColor];
    

    foundTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.viewWidth-20, 30)];
    foundTextField.borderStyle = UITextBorderStyleRoundedRect;
    foundTextField.placeholder=@"请输入搜索";
    foundTextField.font = [UIFont systemFontOfSize:11.0];
    [foundView addSubview:foundTextField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(self.viewWidth-70, 50, 49, 30);
    btn.backgroundColor = kALLBUTTON_COLOR;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(okActoin:) forControlEvents:UIControlEventTouchUpInside];
    [foundView addSubview:btn];

}

- (void)okActoin:(id)sender{
    
    NSString *found = foundTextField.text;
    if (found.length == 0) {
        [MBProgressHUD showError:@"请输入有效内容" toView:self.view.window];
        return;
    }
    
    [self.popover dismiss];
    
    MessageViewController *messageViewController = MessageViewController.new;
    messageViewController.listFlag=@"1";
    messageViewController.foundValue=found;
    [self.navigationController pushViewController:messageViewController animated:YES];
    
    foundTextField.text = @"";
}

- (void)findAction{
    
    CGPoint startPoint = CGPointMake(self.viewWidth-70,64);
    [_popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:foundView inView:self.view];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)initJGGMenuView{
    
    [self arraysList];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 136)];
    txImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.viewWidth -65)/2, 8, 65, 65)];
    
    txImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *txImageDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTXImageView)];
    [txImageView addGestureRecognizer:txImageDtapGesture];
    
    [topView addSubview:txImageView];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 74, self.viewWidth, 21)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:11.0];
    [topView addSubview:nameLabel];
    
    bmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, self.viewWidth, 21)];
    bmLabel.textColor = [UIColor whiteColor];
    bmLabel.textAlignment = NSTextAlignmentCenter;
    bmLabel.font = [UIFont systemFontOfSize:11.0];
    [topView addSubview:bmLabel];
    
    messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageButton.frame=CGRectMake(self.viewWidth-80, 86, 60, 50);
    [messageButton setTitle:@"消息" forState:UIControlStateNormal];
    [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    messageButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [messageButton setImage:[UIImage imageNamed:@"img_message"] forState:UIControlStateNormal];
    messageButton.imageEdgeInsets = UIEdgeInsetsMake(5,13,21,messageButton.titleLabel.bounds.size.width);
    messageButton.titleEdgeInsets = UIEdgeInsetsMake(35,-21, 13, 0);
    [messageButton addTarget:self action:@selector(messageActoin:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:messageButton];
    
    
    signButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signButton.frame=CGRectMake(30, 86, 60, 50);
    [signButton setTitle:@"签到" forState:UIControlStateNormal];
    [signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [signButton setImage:[UIImage imageNamed:@"img_signin"] forState:UIControlStateNormal];
    signButton.imageEdgeInsets = UIEdgeInsetsMake(5,13,21,messageButton.titleLabel.bounds.size.width);
    signButton.titleEdgeInsets = UIEdgeInsetsMake(35,-21, 13, 0);
    [signButton addTarget:self action:@selector(signActoin:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:signButton];
    
    topView.backgroundColor = kALLBUTTON_COLOR;
    
    [self.scrollView addSubview:topView];
    
    //控制总列数
    int totalColumns = 3;
    
    CGFloat Y = CGRectGetMaxY(topView.frame) +20;
    CGFloat W = 120;
    CGFloat H = 120;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 40) / totalColumns;
    
    NSInteger col=0;
    NSInteger row=0;
    for ( NSInteger index = 0;index < _appList.count;index++){
        JGGModel *model = _appList[index];
        col = index % 3;
        row = floorl(index / 3);
        
        JGGView *view = [[JGGView alloc] initWithFrame:CGRectMake(col*(width+5)+25, Y+row*(100+5), W, H) Model:model MyButtonBlock:^{
            
            _myLabel = [[JGGLabel alloc] init];
            
            [self.view addSubview:_myLabel];
            
            NSTimer *timer_ = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:NO];
            [timer_ fire];
            
        }];
        
        view.model = model;
        [self.scrollView addSubview:view];
        CGFloat maxY = CGRectGetMaxY(view.frame);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [view addGestureRecognizer:tapGesture];
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, maxY);

    }
    
    [UIView commitAnimations];
}

- (void)timer
{
    [UIView animateWithDuration:2.0f animations:^{
        _myLabel.alpha = 0.0f;
    }];
}
- (NSArray *)arraysList
{
    if (_appList == nil) {
        NSMutableArray *mutArray = [NSMutableArray array];
        
        NSString* jsonPath = [[NSBundle mainBundle] pathForResource:@"menu_config" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:jsonPath];
        NSError *error=nil;
        NSArray *array =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        for (NSDictionary *dict in array) {
            [mutArray addObject:[JGGModel modelWithDict:dict]];
        }
        _appList = mutArray;
    }
    
    return _appList;
}

- (void)redPoint{
    
    UILabel *redDaiban = [[UILabel alloc] init];
    
    redDaiban.frame = CGRectMake(messageButton.bounds.size.width-40, messageButton.bounds.size.height-20, 20, 20);
    redDaiban.tag = kDaibanRedPointViewTag;
    [messageButton addSubview:redDaiban];
    [messageButton bringSubviewToFront:redDaiban];
    
}

- (void)viewDidLoad{
    self.flag = YES;
    
    [super viewDidLoad];
    self.title=@"首页";
    
    [self initPopFoundView];
    
    [self initJGGMenuView];
//屏蔽伪推送2017-03-01
//    [self initFalsePushView];
    
    [self redPoint];
    
    [self myselfInfo];

    timer = [NSTimer scheduledTimerWithTimeInterval:1*60*60 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(settingAction)];
    self.navigationItem.leftBarButtonItem = settingButton;
    
    
    
    UIBarButtonItem *findButton = [[UIBarButtonItem alloc] initWithTitle:@"搜索"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(findAction)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(myselfInfo)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:refreshButton,findButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
//    __weak FirstViewController *wself = self;
//    [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
//        wself.jingweidu = [NSString stringWithFormat:@"%f,%f",locationCorrrdinate.longitude,locationCorrrdinate.latitude];
//    } withAddress:^(NSString *addressString) {
//        
//        wself.didian = addressString;
//
//    }];
//
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(falsePushAction:) name: @"FalsePushNotification" object:nil];
    
}


#pragma mark 伪推送View
- (void)initFalsePushView{
    
    self.falsePushView = [UIView new];
    self.falsePushView.frame = CGRectMake(0, 64, self.viewWidth, 40);
    self.falsePushView.backgroundColor = RGB(51,153,0);
    [self.view addSubview:self.falsePushView];
    
    self.falsePushLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.viewWidth-20,40)];
    self.falsePushLabel.textColor = [UIColor whiteColor];
    self.falsePushLabel.font = [UIFont systemFontOfSize:11.0];
    [self.falsePushView addSubview:self.falsePushLabel];
    [self.falsePushView setHidden:YES];
    
    UITapGestureRecognizer *falsePushGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFalsePush)];
    [self.falsePushView addGestureRecognizer:falsePushGesture];

}

- (void)falsePushAction:(NSNotification* )note{
    NSString *value = note.object;
    self.falsePushLabel.text = value;
    if (!self.iv_netstate.hidden) {
        return;
    }
    if(self.falsePushView.hidden){
        [self showFalsePush];
    }
}

#pragma mark 显示伪推送View
- (void)showFalsePush{
    self.falsePushView.hidden = NO;
    self.falsePushView.layer.opacity = 0.0;
    CGRect rect = self.view.bounds;
    rect.size.height -= self.falsePushView.frame.size.height;
    rect.origin.y += self.falsePushView.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.falsePushView.layer.opacity = 1.0;
         self.scrollView.frame = rect;
    }completion:^(BOOL finished) {
        [self.falsePushView bringSubviewToFront:self.view];
    }];
    
}

#pragma mark 隐藏伪推送View
- (void)hideFalsePush{
    CGRect rect = self.view.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        self.falsePushView.layer.opacity = 0.0;
         self.scrollView.frame = rect;
    } completion:^(BOOL finished) {
        self.falsePushView.hidden = YES;
        [self messageActoin:nil];
    }];
}

- (void)myselfInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    });

    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.HrmAction?action=searchself",self.serviceIPInfo];
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] ==1){
            NSDictionary *result = dic[@"result"];
            nameLabel.text = result[@"name"];
            bmLabel.text = result[@"org"];
            NSString *urlStr = result[@"photoId"];
            
            NSDictionary *wfprocess=result[@"wfprocess"];
            NSNumber *daiban =wfprocess[@"daiban"];
            if (!daiban) {
                daiban = @(0);
            }
            NSNumber *qqwwc = wfprocess[@"qqwwc"];
            if (!qqwwc) {
                qqwwc = @(0);
            }
            NSNumber *wjsx = wfprocess[@"wjsx"];
            if (!wjsx) {
                wjsx = @(0);
            }
            
            NSNumber *xmgl = wfprocess[@"xmgl"];
            if (!xmgl) {
                xmgl = @(0);
            }
            NSNumber *xxjd = wfprocess[@"xxjd"];
            if (!xxjd) {
                xxjd = @(0);
            }
            
            NSNumber *notify = wfprocess[@"notify"];
            if (!notify) {
                notify = @(0);
            }
            NSNumber *yiban = wfprocess[@"yiban"];
            if (!yiban) {
                yiban = @(0);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [self redPointInfo:@[qqwwc,daiban,wjsx,xmgl,xxjd,notify,yiban]];
            
            NSString *processid = result[kProcessid];
            
            [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:kAddressTXURL];
            [[NSUserDefaults standardUserDefaults] setObject:processid forKey:kProcessid];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *serviceUrl = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",self.serviceIPInfo,urlStr];
            [self roundImageView:txImageView withColor:nil];
            [txImageView sd_setImageWithURL:[NSURL URLWithString:serviceUrl] placeholderImage:[UIImage imageNamed:@"img_user_default"]];
            
             });
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
      
    }];
    [request startAsynchronous];
}

- (void)timerFired:(id)sender{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self myselfInfo];
    });
}

- (void)redPointInfo:(NSArray *)redinfo{
   
    NSInteger daiban = [redinfo[1] integerValue];
   
    for ( NSInteger index = 0;index < _appList.count;index++){
        JGGModel *model = _appList[index];
        JGGView *view = [self.view viewWithTag:model.id_];
        if ([model.alias isEqualToString:@"daiban"]) {
            if (daiban >0) {
                [view.redPountLabel showBadgeWithStyle:WBadgeStyleNumber value:daiban animationType:WBadgeAnimTypeScale];
            }else{
                [view.redPountLabel clearBadge];
            }
        }
        
        if ([model.alias isEqualToString:@"wjsx"]){
            NSInteger wjsx = [redinfo[2] integerValue];
            if (wjsx >0) {
                [view.redPountLabel showBadgeWithStyle:WBadgeStyleNumber value:wjsx animationType:WBadgeAnimTypeScale];
            }else{
                [view.redPountLabel clearBadge];
            }
        }
        
        if ([model.alias isEqualToString:@"yiban"]){
            NSInteger yiban = [redinfo[6] integerValue];
            if (yiban >0) {
                [view.redPountLabel showBadgeWithStyle:WBadgeStyleNumber value:yiban animationType:WBadgeAnimTypeScale];
            }else{
                [view.redPountLabel clearBadge];
            }
        }
        
        if ([model.alias isEqualToString:@"xmgl"]){
            NSInteger xmgl = [redinfo[3] integerValue];
            if (xmgl >0) {
                [view.redPountLabel showBadgeWithStyle:WBadgeStyleNumber value:xmgl animationType:WBadgeAnimTypeScale];
            }else{
                [view.redPountLabel clearBadge];
            }
        }
        
        if ([model.alias isEqualToString:@"xxjd"]){
            NSInteger xxjd = [redinfo[4] integerValue];
            if (xxjd >0) {
                [view.redPountLabel showBadgeWithStyle:WBadgeStyleNumber value:xxjd animationType:WBadgeAnimTypeScale];
            }else{
                [view.redPountLabel clearBadge];
            }
        }
    }
    
    NSInteger notify = [redinfo[5] integerValue];
    UILabel *notifyLabel = [self.view viewWithTag:kDaibanRedPointViewTag];
    if (notify > 0) {
        [notifyLabel showBadgeWithStyle:WBadgeStyleNumber value:notify animationType:WBadgeAnimTypeScale];
    }else{
        [notifyLabel clearBadge];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = notify;
}

- (void)dealloc {
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapAction:(UITapGestureRecognizer *)sender{
    UIView *view = sender.view;
    
    if (view.tag == 5){
        
        DBListViewController *listViewController = DBListViewController.new;
        listViewController.title = @"待办事项";
        listViewController.state = @"getwfprocessDBlist";
        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    if (view.tag == 6){
        EndMatterPageViewController *endMatterPageViewController =[EndMatterPageViewController new];
//        endMatterPageViewController.showNavBar = YES;
//        endMatterPageViewController.barStyle = TYPagerBarStyleCoverView;
        [self.navigationController pushViewController:endMatterPageViewController animated:YES];
    }
    
    if (view.tag == 7){
        
        DBListViewController *listViewController = DBListViewController.new;
        listViewController.title = @"已办事项";
        listViewController.state = @"getwfprocessYBlist";
        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    if (view.tag == 8){
        DocumentViewController *documentViewController = DocumentViewController.new;
        documentViewController.title = @"选择目录";
        [self.navigationController pushViewController:documentViewController animated:YES];
    }
    
    if (view.tag == 9){
        ScheduleInfoViewController *scheduleInfoViewController = ScheduleInfoViewController.new;
        scheduleInfoViewController.title = @"日程管理";
        [self.navigationController pushViewController:scheduleInfoViewController animated:YES];
    }
    
    if (view.tag == 10){
        ChartListViewController *chartListViewController = [ChartListViewController new];
        [self.navigationController pushViewController:chartListViewController animated:YES];
    }
    
}

- (void)messageActoin:(UIButton *)sender{

    MessageViewController *messageViewController = MessageViewController.new;
    [self.navigationController pushViewController:messageViewController animated:YES];
    
}

- (void)signActoin:(UIButton *)sender{
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        
        __weak FirstViewController *wself = self;
        [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
            wself.jingweidu = [NSString stringWithFormat:@"%f,%f",locationCorrrdinate.longitude,locationCorrrdinate.latitude];
        } withAddress:^(NSString *addressString) {
            
            wself.didian = addressString;
            
            if (wself.didian.length == 0 || wself.jingweidu.length == 0){
                [MBProgressHUD showError:@"没有取到签到定位信息" toView:ShareAppDelegate.window];
                [wself.locationManager stopUpdatingLocation];
                return;
            }
            
            //初始化提示框；
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前位置" message:wself.didian preferredStyle:  UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"签到" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [wself signButtonAction:nil];
                [wself.locationManager stopUpdatingLocation];
            }]];
            
            //弹出提示框；
            [wself presentViewController:alert animated:YES completion:nil];
           
        }];
        
    }
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    // 1.获取用户位置的对象
//    CLLocation *location = [locations lastObject];
//    CLLocationCoordinate2D coordinate = location.coordinate;
//    NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
//    
//  
//
//    
//    // 2.停止定位
//    [manager stopUpdatingLocation];
//}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        [MBProgressHUD showError:@"没有取到签到定位信息" toView:ShareAppDelegate.window];
    }
}


- (void)selectTXImageView{
    
    [[MyPhotographViewController shareInstance] viewController:self withBlock:^(UIImage *image) {
        
         NSString *processid=[[NSUserDefaults standardUserDefaults] objectForKey:kProcessid];
        
        NSString *serviceStr = [NSString stringWithFormat:@"/ext/com.cinsea.action.HrmAction?action=uploadphoto&processid=%@",processid];
        
        NSString *fileId =[self uploadWithImage:image url:serviceStr];
        
        if (fileId.length >0) {
            txImageView.image = image;
        }
    }];
}

- (void)settingAction{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotiSettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotiSettingViewController"];
    
    [self.navigationController pushViewController:settingViewController animated:YES];
    
}

- (void)signButtonAction:(id)sender{
    
    NSString *urlStr = [NSString stringWithFormat:kURL_signed,self.serviceIPInfo,self.didian,self.jingweidu];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        [MBProgressHUD showSuccess:dic[@"msg"] toView:self.view.window];
        
    }];
    
    //处理失败
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
    }];
    
    [request startAsynchronous];

}


@end
