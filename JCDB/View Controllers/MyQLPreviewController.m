//
//  MyQLPreviewController.m
//  JCDB
//
//  Created by WangJincai on 16/4/22.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "MyQLPreviewController.h"

@interface MyQLPreviewController ()

@end

@implementation MyQLPreviewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
@end


