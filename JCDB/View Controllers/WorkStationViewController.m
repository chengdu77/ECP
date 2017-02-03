//
//  WorkStationViewController.m
//  JCDB
//
//  Created by WangJincai on 16/4/5.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "WorkStationViewController.h"
#import "UIView+BindValues.h"
#import "Constants.h"
#import "WorkStationQuryViewController.h"
#import "AddFormDataViewController.h"

#define kALL_COLOR RGB(24,179,207)

//点击第一条的查看
#define kWSQuryURL @"%@/ext/com.cinsea.action.ProcessAction?action=getprocesslist&processid=%@"
//点击新增
#define kWSAddURL @"%@/ext/com.cinsea.action.FormAction?action=formviewdata&type=1&dowid=%@"


@interface WSButton:UIButton
@end

@implementation WSButton
-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.hidden = NO;
    // Center image
    CGRect iFrame = self.imageView.frame;
    iFrame.origin.x = (self.frame.size.width - 46)/2;
    iFrame.origin.y = 2;
    iFrame.size.width = 46;
    iFrame.size.height = 46;
    self.imageView.frame = iFrame;
    
    //Center text
    CGRect newFrame = self.titleLabel.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.frame.size.height -20;
    newFrame.size.width = self.frame.size.width;
    newFrame.size.height = 20;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end

@implementation WorkStationBean
@end

@interface WorkStationViewController ()<UIActionSheetDelegate>{
    
    NSMutableArray *listArry;
    
    CGFloat height;
    NSInteger col;
}

@end

@implementation WorkStationViewController

- (void)viewDidLoad {
    
    self.flag = YES;
    [super viewDidLoad];
    self.scrollView.backgroundColor = kBackgroundColor;
    
    height = 70;//高度
    col = 3;//列数
    
    listArry = NSMutableArray.new;
    
    [self requestChartListData];
    
}


-(void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)requestChartListData{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
     NSString *serviceStr = [NSString stringWithFormat:kURL_WorkStationList,self.serviceIPInfo];
    
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
            
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result) {
                WorkStationBean *bean = [WorkStationBean new];
                bean.imgUrl = info[@"imgUrl"];
                bean.moduleObjname = info[@"moduleObjname"];
                bean.moduleid = info[@"moduleid"];
                bean.directoryForList = info[@"directoryForList"];
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
    groupLabel.text = bean.moduleObjname;
    groupLabel.textAlignment = NSTextAlignmentCenter;
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
    CGFloat width = (self.viewWidth - 30) / 3.0;
    
    CGFloat h =  (row*height +(row+1)*5 +10);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.viewWidth,h)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSInteger i=0;
    NSInteger k=0;
    for ( NSInteger j = 0;j < arr.count;j++){
        NSDictionary *list =  arr[j];
        i = j % col;
        k = floorl(j / col);
        WSButton *button = [WSButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(width+5)+10, 10+k*(height+5), width, height);
        button.titleLabel.font = [UIFont fontWithName:kFontName size:12];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [button setTitle:list[@"directoryName"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = j;
        button.value = list[@"directoryId"];
        button.Id = list[@"directoryName"];
        [view addSubview:button];
        button.layer.borderColor = kBackgroundColor.CGColor;
        button.layer.borderWidth = .5;
        
        NSString *urlStr = list[@"imgUrl"];
        urlStr = [NSString stringWithFormat:@"%@%@",self.serviceIPInfo,urlStr];
        [self roundImageView:button.imageView withColor:kALLBUTTON_COLOR];
        [button.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"img_xiangmuguanli"]];
        
    }
    
    return view;
    
}

- (void)buttonAction:(UIButton *)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"【%@】选择操作",sender.Id]
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"新增"
                                  otherButtonTitles:@"查看",nil];
    
    actionSheet.value = sender.value;
    actionSheet.Id = sender.Id;
    
    [actionSheet showInView:self.scrollView];
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:{
            [self requestAddData:actionSheet.value title:actionSheet.Id];
            break;
        }
        case 1:{
            WorkStationQuryViewController *workStationQuryViewController = WorkStationQuryViewController.new;
            workStationQuryViewController.title = @"选择目录";
            workStationQuryViewController.queryConditions = [NSString stringWithFormat:kWSQuryURL,self.serviceIPInfo,actionSheet.value];
            [self.navigationController pushViewController:workStationQuryViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)requestAddData:(NSString *)directoryId title:(NSString *)title{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSString *serviceStr = [NSString stringWithFormat:kWSAddURL,self.serviceIPInfo,directoryId];
    
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
            NSDictionary *info = dic[@"result"];
            
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
                addFormDataViewController.title =  bean.objname;
                addFormDataViewController.type = 1;
                [self.navigationController pushViewController:addFormDataViewController animated:YES];
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

@end
