//
//  LoginViewController.m
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//

#import "LoginViewController.h"
#import "DXPopover.h"
#import "SIAlertView.h"
#import "Reachability.h"


@interface LoginViewController (){
    CGFloat _popoverWidth;
    Reachability *_reachability;
}

@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, strong) NSString *serviceIPInfo;
@property (nonatomic ,assign) CGFloat viewWidth;
    
@end

@implementation LoginViewController


- (BOOL)isExistenceNetwork
{
    _reachability = [Reachability reachabilityWithHostname:@"www.baidu.com"];  // 测试服务器状态
    
    BOOL isExistenceNetwork;
    switch([_reachability currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = TRUE;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = TRUE;
            break;
    }
    return  isExistenceNetwork;
}

-(void)alertNetworkStatus{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"当前无网络，是否进行设置？"
                                          cancelButtonTitle:@"取消"
                                              cancelHandler:^(SIAlertView *alertView) {}
                                     destructiveButtonTitle:@"马上设置"
                                         destructiveHandler:^(SIAlertView *alertView) {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
                                             
                                         }];
    alert.alignment=NSTextAlignmentLeft;
    [alert show];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden=YES;
   
    self.viewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    _popover = [DXPopover new];
    _popover.cornerRadius = 6;
    _popover.arrowSize = CGSizeMake(26, 12);
    _popoverWidth = self.viewWidth;
    
    serverView = [[UIView alloc] init];
    serverView.frame = CGRectMake(0, 0, _popoverWidth, 120);
    serverView.backgroundColor = [UIColor whiteColor];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 102, 21)];
    aLabel.text=@"服务器地址：";
    [serverView addSubview:aLabel];
    
    addrTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 43, 280, 30)];
    addrTextField.borderStyle = UITextBorderStyleRoundedRect;
    [serverView addSubview:addrTextField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(236, 81, 49, 30);
    btn.backgroundColor = kALLBUTTON_COLOR;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(okActoin:) forControlEvents:UIControlEventTouchUpInside];
    [serverView addSubview:btn];
    
    
    loginButton.backgroundColor = kALLBUTTON_COLOR;
    NSString *addressHttps = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    if (!addressHttps) {
        addressHttps=@"http://";
    }
    addrTextField.text = addressHttps;
    
    
    userTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUSERNAME];
    passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kPASSWORD];
    
    BOOL REMBERFLAG = [[NSUserDefaults standardUserDefaults] boolForKey:kREMBERFLAG];
    [remberMeSwitch setOn:REMBERFLAG animated:NO];
    remberMeSwitch.onTintColor = kALLBUTTON_COLOR;
   
    
    if ([self isExistenceNetwork]) {
    }else{
        [self alertNetworkStatus];
    }

    [_reachability startNotifier]; //开始监听,会启动一个run loop

    [self getCompanyInfo];
    
}

- (void)viewUnDidLoad {
    [super viewDidLoad];
    
    [_reachability stopNotifier];

}

- (void)getCompanyInfo{
   
    self.serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/LoginAction?action=LogoAction",self.serviceIPInfo];
    
//    [self getUrlValue:serviceStr success:@"success" result:@"result" delegate:self];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] ==1){
            NSDictionary *result = dic[@"result"];
            NSString *urlStr = result[@"url"];
            [logoImageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
            GsmcLabel.text = result[@"gsmc"];
//            ZdymcLabel.text = result[@"zdymc"];
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    [request startAsynchronous];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (IBAction)loginActoin:(id)sender {
    
    if (userTextField.text.length ==0) {
        [MBProgressHUD showError:@"账号不能为空，请输入" toView:self.view.window];
        return;
    }
    
    if (passwordTextField.text.length ==0) {
        [MBProgressHUD showError:@"密码不能为空，请输入" toView:self.view.window];
        return;
    }
    
    self.serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    if (self.serviceIPInfo.length ==0) {
        [MBProgressHUD showError:@"请设置服务器地址" toView:self.view.window];
        return;
    }
    
     NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/LoginAction?action=mobileLogin&username=%@&password=%@&imei=0",self.serviceIPInfo,userTextField.text,passwordTextField.text];
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        __block NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            [self requestDeptInfo:dic];//请求第一级部门数据
           
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        
        NSLog(@"weakRequest.error:%@",weakRequest.error);
        
    }];
    
    [request startAsynchronous];
    
}

- (void)requestDeptInfo:(NSDictionary *)info{
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_DeptInfo,self.serviceIPInfo,@"11111111111111111111111111111111"];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    __block NSDictionary *dataDic = info;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] == kSuccessCode){
            [self logining:dataDic];
            
            NSArray *deptInfo = dic[@"result"];
            [[NSUserDefaults standardUserDefaults] setObject:deptInfo forKey:kDeptInfo];
            [[NSUserDefaults standardUserDefaults] synchronize];

         }else{
             [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
    }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
    }];
    
    [request startAsynchronous];
}

- (void)logining:(NSDictionary *)dic{
    
    NSDictionary *result = dic[@"result"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyboard instantiateInitialViewController];
    UIWindow *win = [[[UIApplication sharedApplication] delegate] window];
    win.rootViewController = targetVC;
    
    BOOL REMBERFLAG = NO;
    BOOL isButtonOn = [remberMeSwitch isOn];
    if (isButtonOn) {
        [[NSUserDefaults standardUserDefaults] setObject:userTextField.text forKey:kUSERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:kPASSWORD];
        REMBERFLAG = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:REMBERFLAG forKey:kREMBERFLAG];
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:kOneselfInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)getUrlValue:(NSString *)urlValue successInfo:(NSDictionary *)info{
    
    NSString *serviceStr = [NSString stringWithFormat:@"/ext/LoginAction?action=mobileLogin&username=%@&password=%@&imei=0",userTextField.text,passwordTextField.text];
    
    if ([urlValue containsString:serviceStr]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *targetVC = [storyboard instantiateInitialViewController];
        UIWindow *win = [[[UIApplication sharedApplication] delegate] window];
        win.rootViewController = targetVC;
        
        BOOL REMBERFLAG = NO;
        BOOL isButtonOn = [remberMeSwitch isOn];
        if (isButtonOn) {
            [[NSUserDefaults standardUserDefaults] setObject:userTextField.text forKey:kUSERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:kPASSWORD];
            REMBERFLAG = YES;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:REMBERFLAG forKey:kREMBERFLAG];
        [[NSUserDefaults standardUserDefaults] setObject:info forKey:kOneselfInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        
}


- (IBAction)setServiceAction:(UIButton *)btn{
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(serverButton.frame), CGRectGetMaxY(serverButton.frame) -12);
    [serverView setHidden:NO];
    [_popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:serverView inView:self.view];
}

- (void)okActoin:(id)sender{
    NSString *addStr = addrTextField.text;
    if (addStr.length <=0) {
         [MBProgressHUD showError:@"请输入服务器地址" toView:self.view.window];
        return;
    }
   
    [self.popover dismiss];
    
    [[NSUserDefaults standardUserDefaults] setObject:addStr forKey:kAddressHttps];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction:(UISwitch *)sender{
    
    NSString *USERNAME=@"";
    NSString *PASSWORD=@"";
    BOOL REMBERFLAG = NO;
    BOOL isButtonOn = [sender isOn];
    if (isButtonOn) {
        USERNAME = userTextField.text;
        PASSWORD = passwordTextField.text;
        REMBERFLAG = YES;
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:USERNAME forKey:kUSERNAME];
    [[NSUserDefaults standardUserDefaults] setObject:PASSWORD forKey:kPASSWORD];
    [[NSUserDefaults standardUserDefaults] setBool:REMBERFLAG forKey:kREMBERFLAG];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
