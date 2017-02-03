//
//  NotiSettingViewController.m
//  xsgj
//
//  Created by NewDoone on 14-10-13.
//  Copyright (c) 2014年 ilikeido. All rights reserved.
//

#import "NotiSettingViewController.h"
#import "LoginViewController.h"
#import "AboutViewController.h"
#import "ChangePasswordViewController.h"
#import "FavoriteViewController.h"
#import "WorkOrderBean.h"
#import "SettingNewAddViewController.h"
#import "AttendanceHistoryViewController.h"

@interface NotiSettingViewController ()<UIAlertViewDelegate>
{
    NSArray* _signConfigArr;
}
@property(nonatomic,strong)NSString* notiStaut;
@property(nonatomic,strong)NSString* soundStaut;
@property(nonatomic,strong)NSString* shakeStaut;
@end
static NotiSettingViewController* _nsvc;
@implementation NotiSettingViewController

- (void)viewDidLoad{
   // [super viewDidLoad];
    
    self.txView.backgroundColor = kALLBUTTON_COLOR;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.abortButton setTitleColor:kALLBUTTON_COLOR forState:UIControlStateNormal];
    [self.abortButton addTarget:self action:@selector(abortAppAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.modifyPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.modifyPasswordButton addTarget:self action:@selector(actionModifyPswd:) forControlEvents:UIControlEventTouchUpInside];

    NSString *urlStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressTXURL];
    NSString *nameStr = [[NSUserDefaults standardUserDefaults] objectForKey:kUSERNAME];
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    
    self.nameLabel.text = nameStr;
    
    NSString *serviceUrl = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",serviceIPInfo,urlStr];
    [self roundImageView:self.txImageView withColor:nil];
    [self.txImageView sd_setImageWithURL:[NSURL URLWithString:serviceUrl] placeholderImage:[UIImage imageNamed:@"img_user_default"]];

}

- (void)roundImageView:(UIImageView *)imageView withColor:(UIColor *)color{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
    imageView.layer.borderWidth = 2.0;
    if (!color) {
        color = [UIColor whiteColor];
    }
    imageView.layer.borderColor = color.CGColor;
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


- (void)actionModifyPswd:(id)sender{
    ChangePasswordViewController *changePasswordVC = [[ChangePasswordViewController alloc]init];
    changePasswordVC.title = @"修改密码";
    [self.navigationController pushViewController:changePasswordVC animated:YES];
}


- (void)actionSystemUpdate:(id)sender{

}

- (void)abortAppAction:(id)sender{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注销" message:@"是否退出本次登陆的账号?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel =  [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
    UIAlertAction *actionOK     =  [UIAlertAction actionWithTitle:@"退出系统" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self loginOutActoin:nil];
        
    }];
    [alert addAction:actionOK];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)loginOutActoin:(id)sender {
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.LogoutAction",serviceIPInfo];
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] ==1){
            
            [self showLoginView];
            
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

- (void)showLoginView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    ShareAppDelegate.window.rootViewController = navController;
}

- (IBAction)focusFavorite:(id)sender{
    
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.FavoritesAction?action=getfavo&title=&pageIndex=1",serviceIPInfo];
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        

        if ([dic[@"success"] integerValue] ==1){
            NSMutableArray *data = [NSMutableArray array];
            for (NSDictionary *info in dic[@"result"]) {
                WorkOrderBean *bean = [WorkOrderBean new];
                bean._id = info[@"id"];
                bean.createdate = info[@"datatime"];
                bean.dowid = info[@"dowid"];
                bean.processid = info[@"objid"];
                bean.title = info[@"title"];
                bean.iconnew = info[@"iconnew"];
                bean.type= [info[@"type"] integerValue];

                [data addObject:bean];
            }
        
            if(data.count>0){
                FavoriteViewController *favoriteViewController = [FavoriteViewController new];
                favoriteViewController.listData = data;
                [self.navigationController pushViewController:favoriteViewController animated:YES];
                return;
            }
        }
        [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        
    }];
    
    [request startAsynchronous];
    
}

- (IBAction)addNewDataAction:(id)sender{
    
    SettingNewAddViewController *settingNewAddViewController = SettingNewAddViewController.new;
    
    [self.navigationController pushViewController:settingNewAddViewController animated:YES];
    
}

- (IBAction)attendanceHistory:(id)sender{
    
    AttendanceHistoryViewController *attendanceHistoryViewController = AttendanceHistoryViewController.new;
    attendanceHistoryViewController.title = @"签到历史";
//    attendanceHistoryViewController.listArray = listArray;
    [self.navigationController pushViewController:attendanceHistoryViewController animated:YES];

}

@end
