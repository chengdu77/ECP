//
//  ChangePasswordViewController.m
//  xsgj
//
//  Created by Geory on 14-7-24.
//  Copyright (c) 2014年 ilikeido. All rights reserved.
//

#import "ChangePasswordViewController.h"

#import "MBProgressHUD+Add.h"
#import "NSString+URL.h"

@interface ChangePasswordViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tf_oldpwd;
@property (weak, nonatomic) IBOutlet UITextField *tf_newpwd;
@property (weak, nonatomic) IBOutlet UITextField *tf_confirmpwd;

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setup];
    
    [self setRightBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup{
    
    NSString *nameStr = [[NSUserDefaults standardUserDefaults] objectForKey:kUSERNAME];
    UILabel *lb_account = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 35)];
    lb_account.text = [NSString stringWithFormat:@"当前账号：%@",nameStr];
    lb_account.textColor = kALLBUTTON_COLOR;
    lb_account.font = [UIFont systemFontOfSize:18];
    lb_account.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:lb_account];
   
    
    UIImage *image = [UIImage imageNamed:@"normal"];
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 100, 20, 30);
    CGSize size = {300,40};
    image= [self image:image resizableImageWithCapInsets:insets size:size];
    
    UIImageView *iv_oldpwd = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lb_account.frame) + 10,size.width, size.height)];
    
    [iv_oldpwd setImage:image];
    [self.scrollView addSubview:iv_oldpwd];
  
    UILabel *lb_oldpwd = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lb_account.frame) + 10, 80, 40)];
    lb_oldpwd.text = @"旧密码";
    lb_oldpwd.font = [UIFont systemFontOfSize:17];
    lb_oldpwd.textColor = HEX_RGB(0x939fa7);
    lb_oldpwd.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:lb_oldpwd];
    
    UILabel *lblStart = [self getStarMarkPrompt];
    lblStart.frame = CGRectMake(88, CGRectGetMaxY(lb_account.frame) + 24, 10, 20);
    [self.scrollView addSubview:lblStart];
    
    UITextField *tf_oldpwd = [[UITextField alloc] initWithFrame:CGRectMake(110, CGRectGetMaxY(lb_account.frame) + 10, 180, 40)];
    [tf_oldpwd setBorderStyle:UITextBorderStyleNone];
    tf_oldpwd.secureTextEntry = YES;
    tf_oldpwd.font = [UIFont systemFontOfSize:17];
    tf_oldpwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.scrollView addSubview:tf_oldpwd];
    tf_oldpwd.placeholder = @"请输入旧密码";
    _tf_oldpwd = tf_oldpwd;

    UIImageView *iv_newpwd = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(iv_oldpwd.frame) + 15, size.width, size.height)];
    [iv_newpwd setImage:image];
    [self.scrollView addSubview:iv_newpwd];
    
    UILabel *lb_newpwd = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iv_oldpwd.frame) + 15, 80, 40)];
    lb_newpwd.text = @"新密码";
    lb_newpwd.font = [UIFont systemFontOfSize:17];
    lb_newpwd.textColor = HEX_RGB(0x939fa7);
    lb_newpwd.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:lb_newpwd];
    
    lblStart = [self getStarMarkPrompt];
    lblStart.frame = CGRectMake(88, CGRectGetMaxY(iv_oldpwd.frame) + 29, 10, 20);
    [self.scrollView addSubview:lblStart];
    
    UITextField *tf_newpwd = [[UITextField alloc] initWithFrame:CGRectMake(110, CGRectGetMaxY(iv_oldpwd.frame) + 15, 180, 40)];
    [tf_newpwd setBorderStyle:UITextBorderStyleNone];
    tf_newpwd.secureTextEntry = YES;
    tf_newpwd.font = [UIFont systemFontOfSize:17];
    tf_newpwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.scrollView addSubview:tf_newpwd];
    tf_newpwd.placeholder = @"请输入新密码";
    _tf_newpwd = tf_newpwd;
    
    UIImageView *iv_confirmpwd = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(iv_newpwd.frame) + 15, size.width, size.height)];
    [iv_confirmpwd setImage:image];
    [self.scrollView addSubview:iv_confirmpwd];
    
    UILabel *lb_confirmpwd = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iv_newpwd.frame) + 15, 80, 40)];
    lb_confirmpwd.text = @"确认密码";
    lb_confirmpwd.font = [UIFont systemFontOfSize:17];
    lb_confirmpwd.textColor = HEX_RGB(0x939fa7);
    lb_confirmpwd.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:lb_confirmpwd];
    
    lblStart = [self getStarMarkPrompt];
    lblStart.frame = CGRectMake(88, CGRectGetMaxY(iv_newpwd.frame) + 29, 10, 20);
    [self.scrollView addSubview:lblStart];
    
    UITextField *tf_confirmpwd = [[UITextField alloc] initWithFrame:CGRectMake(110, CGRectGetMaxY(iv_newpwd.frame) + 15, 180, 40)];
    [tf_confirmpwd setBorderStyle:UITextBorderStyleNone];
    tf_confirmpwd.secureTextEntry = YES;
    tf_confirmpwd.font = [UIFont systemFontOfSize:17];
    tf_confirmpwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.scrollView addSubview:tf_confirmpwd];
    _tf_confirmpwd = tf_confirmpwd;
    tf_confirmpwd.placeholder = @"请输入确认密码";
    
    self.view.backgroundColor = HEX_RGB(0xefeff4);
}

#pragma mark - navBarButton

- (void)setRightBarButtonItem{
    [self showRightBarButtonItemWithTitle:@"提交" target:self action:@selector(submitAction:)];
}

#pragma mark - private

- (BOOL)isValidData
{
    NSString *errorMessage = nil;
    
    if (_tf_oldpwd.text.length == 0)
    {
        errorMessage = @"请输入旧密码";
    }
    else if(_tf_newpwd.text.length == 0)
    {
        errorMessage = @"请输入新密码";
    }
    else if (_tf_confirmpwd.text.length == 0)
    {
        errorMessage = @"请输入确认密码";
    }
    else if (![_tf_newpwd.text isEqualToString:_tf_confirmpwd.text])
    {
        errorMessage = @"密码不一致,请重新输入";
    }/*
    else if (![_tf_oldpwd.text isEqualToString:[ShareValue shareInstance].userPwd])
    {
        errorMessage = @"旧密码输入错误,请重新输入";
    }*/
    else if (![_tf_newpwd.text isWeakPswd])
    {
        errorMessage = @"请使用英文和数字组合,总长度为6-20个字符,请重新输入";
    }
    
    if (errorMessage.length > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

-(UILabel *)getStarMarkPrompt{
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"*";
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)updatePwdRequest
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    UpdataPwdHttpRequest *request = [[UpdataPwdHttpRequest alloc] init];
//    request.OLDPWD = [[CRSA shareInstance]encryptByRsa:_tf_oldpwd.text withKeyType:KeyTypePublic];
//    request.NEWPWD = [[CRSA shareInstance]encryptByRsa:_tf_newpwd.text withKeyType:KeyTypePublic];
//    [XTGLAPI updatePwdByRequest:request success:^(UpdatePwdHttpResponse *response)
//    {
//        
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改成功" message:@"密码修改成功，确定后跳转到登录页面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        alert.tag = 101;
//        [alert show];
//    } fail:^(BOOL notReachable, NSString *desciption)
//    {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [MBProgressHUD showError:desciption toView:self.view];
//        
//    }];
}

#pragma mark - Action

- (void)submitAction:(id)sender
{
    [_tf_oldpwd resignFirstResponder];
    [_tf_newpwd resignFirstResponder];
    [_tf_confirmpwd resignFirstResponder];
    if (![self isValidData])
    {
        return;
    }
    [self updatePwdRequest];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
       
    }
//    if (alertView.tag == 101)
//    {
//        [ShareValue shareInstance].userPwd = _tf_newpwd.text;
//        [ShareAppDelegate showLoginViewController];
//    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
 
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

@end
