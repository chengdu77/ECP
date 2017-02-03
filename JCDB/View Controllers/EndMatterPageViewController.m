//
//  EndMatterPageViewController.m
//  JCDB
//
//  Created by WangJincai on 16/9/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "EndMatterPageViewController.h"
#import "TYTabButtonPagerController.h"
#import "Constants.h"
#import "EndMatterNewListViewController.h"

@interface EndMatterPageViewController ()<TYPagerControllerDataSource>{
    NSArray *pageNames;
    
    TYTabButtonPagerController *_pagerController;
}

@end

@implementation EndMatterPageViewController

- (UIButton *)defaultBackButtonWithTitle:(NSString *)title{
    UIButton *button = [self defaultRightButtonWithTitle:title];
    return button;
}

- (UIButton *)defaultRightButtonWithTitle:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 65, 35);
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"事项列表";
    pageNames = @[@"办结事宜",@"完结事宜"];
    
    UIButton * _btnBack = [self defaultBackButtonWithTitle:@" 返回"];
    [_btnBack addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnBack setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
    [_btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_btnBack];

    
    [self addPagerController];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)addPagerController{

    _pagerController = [[TYTabButtonPagerController alloc]init];
    _pagerController.dataSource = self;
    _pagerController.adjustStatusBarHeight = YES;
    _pagerController.barStyle = TYPagerBarStyleCoverView;
    _pagerController.cellSpacing = 8;
    
    _pagerController.progressColor = kALLBUTTON_COLOR;
    _pagerController.collectionViewBarColor = kBackgroundColor;
    
    
    _pagerController.view.frame = self.view.bounds;
    [self addChildViewController:_pagerController];
    [self.scrollView addSubview:_pagerController.view];
    
    [_pagerController reloadData];
    [_pagerController moveToControllerAtIndex:0 animated:YES];
 
}


#pragma mark - TYPagerControllerDataSource
- (NSInteger)numberOfControllersInPagerController{
    return pageNames.count;
}


- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index{
    return pageNames[index];
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index{
    
    EndMatterNewListViewController *vc = [EndMatterNewListViewController new];
    vc.index = index;
    return vc;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
