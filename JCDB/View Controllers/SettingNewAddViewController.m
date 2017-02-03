//
//  SettingNewAddViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/8.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "SettingNewAddViewController.h"
#import "WorkStationViewController.h"
#import "TypeMattersViewController.h"
#import "AddFormDataViewController.h"
#import "UIView+BindValues.h"
#import "Constants.h"

#define kAddListURL @"%@/ext/com.cinsea.action.WfdefineAction?action=getWfprocesslist"

@interface SettingNewAddViewController (){
    NSMutableArray *listArry;
    
    CGFloat height;
    NSInteger col;
}

@end

@implementation SettingNewAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择模块";
    height = (self.viewWidth - 30) / 3.0;
    col = 3.0;
    
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSString *serviceStr = [NSString stringWithFormat:kAddListURL,self.serviceIPInfo];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            
            listArry = [NSMutableArray array];
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result) {
                WorkStationBean *bean = [WorkStationBean new];
                bean.imgUrl = info[@"imgUrl"];
                bean.moduleObjname = info[@"moduleObjname"];
                bean.moduleid = info[@"moduleid"];
                bean.directoryForList = info[@"wfprocessForList"];
                [listArry addObject:bean];
            }
            
            if (listArry.count >0) {
                [self initThisView];
            }else {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    }];
    
    [request startAsynchronous];
}


- (void)initThisView{
    
    CGRect frame = CGRectMake(0,0,self.viewWidth,0);
    for (int i=0;i<listArry.count;i++) {
        WorkStationBean *bean = listArry[i];
        UIView *groupView = [self drawGroupViewWithFrame:frame bean:bean];
        [self.scrollView addSubview:groupView];
        frame = groupView.frame;
        if (i < listArry.count-1) {
            frame = CGRectMake(0, CGRectGetMaxY(frame),self.viewWidth,0);
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(frame)+5);
}

- (UIView *)drawGroupViewWithFrame:(CGRect)frame bean:(WorkStationBean *)bean{
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.value = bean.moduleid;
    
    UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.viewWidth, 30)];
    groupLabel.text = [NSString stringWithFormat:@"   %@",bean.moduleObjname];
    groupLabel.font = [UIFont fontWithName:kFontName size:16.0];
    groupLabel.backgroundColor = kBackgroundColor;
    [view addSubview:groupLabel];
    
    UIView *childView;
    if (bean.directoryForList.count >0) {
        childView = [self drawChildViewWithGroup:bean.directoryForList];
        [view addSubview:childView];
        CGRect tFrame = childView.frame;
        tFrame.origin.y = CGRectGetMaxY(groupLabel.frame);
        childView.frame = tFrame;
    }
    
    frame.size.height = CGRectGetHeight(groupLabel.frame) + CGRectGetHeight(childView.frame) +(bean.directoryForList.count >0?0:1);
    view.frame = frame;
    
    return view;
}

- (UIView *)drawChildViewWithGroup:(NSArray *)arr{
    
    NSInteger row = ceil(arr.count/3.0);
    CGFloat width = height;
    
    CGFloat h =  (row*height +(row+1)*5 +10);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.viewWidth,h)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSInteger i=0;
    NSInteger k=0;
    for ( NSInteger j = 0;j < arr.count;j++){
        NSDictionary *list =  arr[j];
        i = j % col;
        k = floorl(j / col);
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(i*(width+5)+10, 10+k*(height+5), width, height)];
        [tempView setBackgroundColor:[UIColor whiteColor]];
        [view addSubview:tempView];
        
        tempView.Id = list[@"id"];
        tempView.value = list[@"formid"];
        tempView.newValue = list[@"objname"];
        tempView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewAction:)];
        [tempView addGestureRecognizer:tapGesture];
        

        CGRect frame = CGRectMake(10, 10, CGRectGetWidth(tempView.frame)-20, CGRectGetHeight(tempView.frame)-20);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = list[@"objname"];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:kFontName size:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = kRandomColor;
        [tempView addSubview:label];
        
        tempView.layer.borderColor = kBackgroundColor.CGColor;
        tempView.layer.borderWidth = .5;
    }
    
    return view;
    
}

- (void)viewAction:(UITapGestureRecognizer *)sender{
//    NSLog(@"value:%@ id:%@",sender.view.value,sender.view.Id);
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_AddFormData,self.serviceIPInfo,sender.view.Id];
//    if ([myBean.type integerValue] >0){
//        //1表示目录，2表示流程，3表示文档
//        serviceStr = [NSString stringWithFormat:@"%@&type=%@",serviceStr,myBean.type];
//    }else{
        serviceStr = [NSString stringWithFormat:@"%@&type=2",serviceStr];
//    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSDictionary *info = dic[@"result"];
            //            NSLog(@"result:%@",info);
            
            AddFormDataBean *bean = [AddFormDataBean new];
            bean.formid = info[@"formid"];
            bean.type = info[@"type"];
            bean.objname = info[@"objname"];
            bean.dowid = info[@"dowid"];
            bean.formfields = info[@"formfields"];
            bean.subtables = info[@"subtables"];
            
            if (bean.formfields.count >0) {
                AddFormDataViewController *addFormDataViewController = [AddFormDataViewController new];
                addFormDataViewController.infoBean = bean;
                addFormDataViewController.title = sender.view.newValue;
                [self.navigationController pushViewController:addFormDataViewController animated:YES];
            }else {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
    }];
    
    [request startAsynchronous];
    
}


@end
