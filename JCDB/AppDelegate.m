//
//  AppDelegate.m
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>

#import "KSJXTabBarController.h"
#import "FirstViewController.h"
#import "WorkOrderPageViewController.h"
#import "WorkStationViewController.h"
#import "StaffContactsViewController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>{
    NSTimer *timer;
    KSJXTabBarController *tabBarController;
}

@property (strong, nonatomic) NSString *alertBody;

@end

@implementation AppDelegate


- (void)addTabBarController{
    
    tabBarController = [KSJXTabBarController new];
//    tabBarController.delegate = self;

    FirstViewController *firstViewController = [FirstViewController new];
    firstViewController.tabBarItem.title = @"首页";
    firstViewController.tabBarItem.image = [UIImage imageNamed:@"first"];
    
    UINavigationController *vc1 = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    
    WorkOrderPageViewController *workOrderPageViewController = [WorkOrderPageViewController new];
    workOrderPageViewController.tabBarItem.title = @"流程";
    workOrderPageViewController.tabBarItem.image = [UIImage imageNamed:@"third"];
    workOrderPageViewController.title = @"流程";
    
    UINavigationController *vc2 = [[UINavigationController alloc] initWithRootViewController:workOrderPageViewController];
    
    WorkStationViewController *workStationViewController = [WorkStationViewController new];
    workStationViewController.tabBarItem.title = @"工作台";
    workStationViewController.tabBarItem.image = [UIImage imageNamed:@"work_item"];
    workStationViewController.title = @"工作台";
    
    UINavigationController *vc3 = [[UINavigationController alloc] initWithRootViewController:workStationViewController];
    
    StaffContactsViewController *staffContactsViewController = [StaffContactsViewController new];
    staffContactsViewController.tabBarItem.title = @"通讯录";
    staffContactsViewController.tabBarItem.image = [UIImage imageNamed:@"four"];
    
    UINavigationController *vc4 = [[UINavigationController alloc] initWithRootViewController:staffContactsViewController];
    
    tabBarController.viewControllers = @[vc1,vc2,vc3,vc4];
    
    self.window.rootViewController = tabBarController;
    
}

- (BOOL)tabBarController:(UITabBarController *)_tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
//    NSLog(@"--tabbaritem.title--%@",viewController.tabBarItem.title);
//    for (UIViewController *vc in tabBarController.viewControllers) {
//        vc.tabBarItem.badgeValue = @"35";
//    }
//    if ([viewController.tabBarItem.title isEqualToString:@"通讯录"]){
//        
//    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kALLBUTTON_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:kFontName size:20],NSFontAttributeName,@0.0,NSBaselineOffsetAttributeName, nil]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self loginView];
    
    [self.window makeKeyAndVisible];
    
    [self registerUserNotification];
    
    return YES;
}

- (void)loginView{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.window.rootViewController = navController;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self startFalsePush];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self startFalsePush];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"processid_FalsePushKey"];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:array.count];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    NSLog(@"noti:%@",notification.userInfo[@"FalsePushKey"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FalsePushNotification" object:notification.userInfo[@"FalsePushKey"]];
}

- (void)startFalsePush{
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)timerFired:(id)sender{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestfalsePush];
    });
}

- (void)registerUserNotification {
    /*
     注册通知(推送)
     申请App需要接受来自服务商提供推送消息
     */
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}


// 设置本地通知
- (void)registerLocalNotification:(NSInteger)alertTime alert:(NSString *)alertBody{
    
    
    if (!alertBody ||alertBody.length == 0) {
        return;
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    //notification.repeatInterval = kCFCalendarUnitSecond;
    // 设置重复间隔（默认0，不重复推送）
    notification.repeatInterval = 0;
    // 推送声音（系统默认）
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知内容
    notification.alertBody = alertBody;
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge ++;
    
    notification.applicationIconBadgeNumber = badge;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    notification.userInfo = @{@"FalsePushKey":alertBody};
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    notification.alertTitle = app_Name;

    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


- (void)requestfalsePush{
  
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.NotifyAction?action=getIsNotify",serviceIPInfo];
    NSURL *url = [NSURL URLWithString:serviceStr];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if (dic == nil){
            return;
        }
        if ([dic[@"flag"] integerValue] != kSuccessCode){
            return;
        }
        NSArray *result = dic[@"result"];
        if (result == nil){
            return;
        }
        NSString *processid = result[0][@"processid"];
        if (processid.length >0) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *array = [defaults objectForKey:@"processid_FalsePushKey"];
            if (!([array indexOfObject:processid] == NSNotFound) && array !=nil){
                return;
            }
            NSMutableArray *mArray = [array mutableCopy];
            if (mArray ==nil){
                mArray = [NSMutableArray array];
            }
            [mArray addObject:processid];
            [defaults setObject:mArray forKey:@"processid_FalsePushKey"];
            [defaults synchronize];
        }else{
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self registerLocalNotification:.5 alert:dic[@"msg"]];
        });
        
    }];
    [request startAsynchronous];
}


@end
