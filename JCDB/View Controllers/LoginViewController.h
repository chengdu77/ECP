//
//  LoginViewController.h
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"

@interface LoginViewController : UIViewController{

    IBOutlet UITextField *userTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *serverButton;
    IBOutlet UIButton *loginButton;
    
    IBOutlet UISwitch *remberMeSwitch;
    
    IBOutlet UIImageView *logoImageView;
    IBOutlet UILabel *GsmcLabel;
    IBOutlet UILabel *ZdymcLabel;
    
    UIView *serverView;
    UITextField *addrTextField;
}



- (IBAction)loginActoin:(id)sender;
- (IBAction)setServiceAction:(id)sender;

- (IBAction)switchAction:(id)sender;

@end
