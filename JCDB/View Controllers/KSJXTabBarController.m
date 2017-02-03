//
//  KSJXTabBarController.m
//  KSJX
//
//  Created by wangjc on 15-6-30.
//  Copyright (c) 2015年 wjc. All rights reserved.
//

#import "KSJXTabBarController.h"

@interface KSJXTabBarController ()<UITabBarDelegate>

@end

@implementation KSJXTabBarController

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear{
    
    self.tabBar.delegate=self;


}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar*)atabBar didSelectItem:(UITabBarItem*)item{
    
    CATransition* animation = [CATransition animation];
    [animation setDuration:0.5f];
    [animation setType:kCATransitionFade];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.view layer] addAnimation:animation forKey:@"switchView"];
}

@end
