//
//  SignViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/21.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "SignViewController.h"
#import "SketchpadView.h"
#import "ASIFormDataRequest.h"
#import "MyPhotographViewController.h"

#define kTEXTVIEWHEIGHT 80

#define kREMARK_VIEWTAG 500

#define kScrollView_VIEWTAG 800


#define kwidth [UIScreen mainScreen].bounds.size.width

@interface SignViewController ()<UITextViewDelegate>{
    SketchpadView *sketchpadView;
    NSMutableArray *imageArray;
    NSMutableArray *imageInfos;
}

@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showRightBarButtonItemWithTitle:@"提交" target:self action:@selector(submitAction:)];
    
    sketchpadView = [[SketchpadView alloc] initWithFrame:CGRectMake(10, 10,self.viewWidth-20, 250)];
    sketchpadView.backgroundColor = RGB(230, 233, 238);
    
    sketchpadView.layer.shadowColor=[UIColor blackColor].CGColor;
    sketchpadView.layer.shadowOffset=CGSizeMake(1, 1);
    sketchpadView.layer.shadowOpacity=0.5;
    sketchpadView.layer.shadowRadius=1;
    [self.scrollView addSubview:sketchpadView];
    
    CGRect frame = sketchpadView.frame;
    
    CGRect rect=CGRectMake(10, CGRectGetMaxY(frame)+5, self.viewWidth-20,self.viewHeight-CGRectGetMaxY(frame)-74);
    UIView *tempView = [self addViewFrame:rect];
    [self.scrollView addSubview:tempView];
 
}


- (UIButton *)createButtonFrame:(CGRect)frame title:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:kALLBUTTON_COLOR];
    button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)addViewFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    CGRect buttonFrame = CGRectMake(self.viewWidth -225,5,60,34);
    UIButton *uploadButton = [self createButtonFrame:buttonFrame title:@"上传" action:@selector(uploadAction)];
    [view addSubview:uploadButton];
    
    buttonFrame = CGRectMake(self.viewWidth -155,5,60,34);
    UIButton *button = [self createButtonFrame:buttonFrame title:@"重置" action:@selector(resetAction)];
    [view addSubview:button];
 
    buttonFrame = CGRectMake(self.viewWidth -85,5,60,34);
    UIButton *commitbutton = [self createButtonFrame:buttonFrame title:@"确认" action:@selector(submitAction:)];
    [view addSubview:commitbutton];
    
    CGRect r = CGRectZero;
    r.origin.x = 5;
    r.origin.y = CGRectGetMaxY(button.frame)+5;
    r.size.width = self.viewWidth -30;
    r.size.height = 60;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:r];
    scrollView.tag = kScrollView_VIEWTAG;
    [view addSubview:scrollView];
    
    r.origin.x = 5;
    r.origin.y = CGRectGetMaxY(r)+5;
    r.size.height = frame.size.height-115;
    IQTextView *textView_ = [[IQTextView alloc] initWithFrame:r];
    textView_.tag =  kREMARK_VIEWTAG;
    textView_.font = [UIFont fontWithName:kFontName size:14];
    textView_.placeholder = [self.action isEqualToString:@"submit"]?@"请输入提交内容":@"请输入驳回内容";
    textView_.backgroundColor = [UIColor whiteColor];
    textView_.keyboardType = UIKeyboardTypeDefault;
    textView_.delegate = self;
    
    //    设置边框：
    textView_.layer.borderColor = RGB(230, 233, 238).CGColor;
    textView_.layer.borderWidth = 1.0;
    
    [view addSubview:textView_];
    
    frame.size.height = CGRectGetMaxY(r)+7;
    
    view.backgroundColor = RGB(230, 233, 238);
    
    view.layer.shadowColor=[UIColor blackColor].CGColor;
    view.layer.shadowOffset=CGSizeMake(1, 1);
    view.layer.shadowOpacity=0.5;
    view.layer.shadowRadius=1;
    
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setSuccessRefreshViewBlock:(SuccessRefreshViewBlock) block{
    self.block = block;
}

- (void)submitAction:(id)sender{
    
    IQTextView *textView = [self.view viewWithTag:kREMARK_VIEWTAG];
    NSString *remark=textView.text;
    if (remark == nil) {
        remark = @"";
    }
    
    NSString *subDetails = @"{\"detailtables\":{}}";
    if (self.tables) {
        subDetails = [self toJSONWithObject:self.tables];
        
        subDetails = [NSString stringWithFormat:@"{\"detailtables\":%@}",subDetails];
    }
    
    NSString *json=[self toJSONWithObject:self.info];
    
    NSString *processid=self.processid;
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessAction?action=%@&subDetails=%@&jsonStr=%@",self.serviceIPInfo,self.action,subDetails,json];
    
    urlStr=[NSString stringWithFormat:@"%@&processid=%@",urlStr,processid];
    
    urlStr = [self removeIntermediateSpace:urlStr];
    
    NSString *ids = @"";
    if (imageArray.count >0) {
        ids = [imageArray componentsJoinedByString:@","];
    }
    urlStr=[NSString stringWithFormat:@"%@&fileIds=%@",urlStr,ids];
    
    urlStr=[NSString stringWithFormat:@"%@&remark=%@  ",urlStr,remark];
    
    if ([sketchpadView count] <=0) {
        urlStr=[NSString stringWithFormat:@"%@&maintable=%@",urlStr,self.maintable];
    }else{
        
        UIImage *image = [sketchpadView getImageInfo];
        
        NSString *photoId =[self uploadWithImage:image];
        urlStr=[NSString stringWithFormat:@"%@<img alt=\"\" style=\"width:300px;height:300px\" src=\"/filedownload.do\?attachid=%@\" />&maintable=%@",urlStr,photoId,self.maintable];
    }
    
    
    if ([self.action isEqualToString:@"reject"]) {
      urlStr=[NSString stringWithFormat:@"%@&rejecttonode=%@",urlStr,self.rejecttonode];
    }
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        //接受服务端（通过还是驳回）处理信息
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        //判断是否处理成功
        if ([dic[@"success"] integerValue] == kSuccessCode){
            //处理成功
            self.block();
            [self.navigationController popViewControllerAnimated:YES];//关闭该签名界面
        }else{
            //处理失败，显示服务端信息
            [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
        }
    }];
    //处理失败
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
    }];
    
    [request startAsynchronous];
//
//    NSLog(@"urlStr:%@",urlStr);
    
/*
http://123.57.205.36:8080/ext/com.cinsea.action.WfprocessAction?action=submit&
    jsonStr={"zhengshu":"12","fuxuankuang":"0","riqi":"2016-01-12","xingming":"12132131",
        "bumen":"11111111111111111111111111111111","dxwb":"23131313","shijian":"16:43:00",
        "fudianshu":"231.00","xialaliebiao":"297e9e7950eb17020150fe8c256606a6","fuwenben":"12312313 "}
    &processid=297e9e7951f6dc98015235020f525381&remark=okokok
    <img alt="" style="width:300px;height:300px" src="/filedownload.do?attachid=297e9e7951f6dc9801523a12af1e6e25" />
    &maintable=ut_biaodan1
 */
    
}

- (void)uploadAction{
    
    if (imageInfos.count >=5){
        [MBProgressHUD showError:@"只能上传一张图片" toView:ShareAppDelegate.window];
        return;
    }
        
    
    [[MyPhotographViewController shareInstance] viewController:self withBlock:^(UIImage *image) {
        
//        NSString *processid=[[NSUserDefaults standardUserDefaults] objectForKey:kProcessid];
//        
//        NSString *serviceStr = [NSString stringWithFormat:@"/ext/com.cinsea.action.HrmAction?action=uploadphoto&processid=%@",processid];
        
        NSString *serviceStr = @"/ext/com.cinsea.action.UploadAction?action=uploadphoto";
        
        NSString *fileId =[self uploadWithImage:image url:serviceStr];
        
        if (fileId.length >0) {
            if (!imageArray){
                imageArray = [NSMutableArray array];
            }
            if (!imageInfos) {
                imageInfos = [NSMutableArray array];
            }
            [imageArray addObject:fileId];
            [imageInfos addObject:image];
            
            UIScrollView *sView = [self.view viewWithTag:kScrollView_VIEWTAG];
            NSArray *array = sView.subviews;
            for (UIView *v in array){
                [v removeFromSuperview];
            }
            
            CGRect r = CGRectMake(0,0,60,60);
            for (UIImage *image in imageInfos) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:r];
                imageView.image = image;
                [sView addSubview:imageView];
                r.origin.x=CGRectGetMaxX(r)+1;
            }
        }
    }];
    
}

- (void)resetAction{
    [sketchpadView clearAll];
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [_textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//去除字符串中间空格
- (NSString *)removeIntermediateSpace:(NSString *)theString{
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
    
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    
    return [filteredArray componentsJoinedByString:@""];
}


@end
