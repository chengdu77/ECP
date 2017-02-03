//
//  HeadViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/1.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"
#import "Reachability.h"
#import "MyTransformAnimation.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface UIView (MaskAnimation)

-(void)animateCircleMaskWithduration:(NSTimeInterval)duration
                               delay:(NSTimeInterval)delay
                           clockwise:(BOOL)clockwise
                         compeletion:(void (^)(void))completion;

@end

@implementation UIView (MaskAnimation)

-(void)animateCircleMaskWithduration:(NSTimeInterval)duration
                                   delay:(NSTimeInterval)delay
                               clockwise:(BOOL)clockwise
                             compeletion:(void (^)(void))completion{
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat maxSide = MAX(width, height);
    CGPoint center = CGPointMake(width/2, height/2);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:center
                                                               radius:maxSide/2
                                                           startAngle:0.0
                                                             endAngle:M_PI * 2
                                                            clockwise:clockwise];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion !=nil) {
            completion();
        }
        self.layer.mask = nil;
    }];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.lineWidth = maxSide;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [UIColor blackColor].CGColor;
    self.layer.mask = maskLayer;
    
    CABasicAnimation * animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [maskLayer addAnimation:animation forKey:@"maskAnimation"];
    [CATransaction commit];
}

@end


@implementation MyScrollView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}
@end

@interface HeadViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>{
   
}


@end

@implementation HeadViewController

- (void)initView {
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[MyScrollView alloc] init];
    self.scrollView.frame = self.view.bounds;
    [self.view addSubview:self.scrollView];
    
    self.viewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.viewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.iv_netstate = [UIView new];
    self.iv_netstate.frame = CGRectMake(0, 64, self.viewWidth, 40);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(19,12,17,17)];
    imageView.image = [UIImage imageNamed:@"net_warn_icon"];
   
    [self.iv_netstate addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46,10,232,21)];
    label.text = @"当前无网络，请检查设置";
    label.font = [UIFont systemFontOfSize:11.0];
    [self.iv_netstate addSubview:label];
    
    UIImageView *moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.viewWidth-20,14,10,15)];
    moreImageView.image = [UIImage imageNamed:@"setting_more"];
    [self.iv_netstate addSubview:moreImageView];
    
    self.iv_netstate.backgroundColor = RGB(250, 222, 164);
    [self.view addSubview:self.iv_netstate];
    [self.iv_netstate setHidden:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNetworkAction:)];
    [self.iv_netstate addGestureRecognizer:tapGesture];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.navigationController.delegate = self;//自定义转场delegate
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initView];

    if (!self.flag) {
        UIButton * _btnBack = [self defaultBackButtonWithTitle:@" 返回"];
        [_btnBack addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_btnBack setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
        [_btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_btnBack];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    self.serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];

}

//根据自定义Font自适应宽度高度Label
- (UILabel *)adaptiveLabelWithFrame:(CGRect)frame detail:(NSString*)detail fontSize:(CGFloat)fontSize{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:detail];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont fontWithName:kFontName size:fontSize]
                    range:NSMakeRange(0, [detail length])];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:kFontColor_Contacts
                    range:NSMakeRange(0, [detail length])];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraph.lineSpacing = 3;
    //段落间距
    paragraph.paragraphSpacing = 3;
    //对齐方式
    paragraph.alignment = NSTextAlignmentLeft;
    //指定段落开始的缩进像素
    paragraph.firstLineHeadIndent = 0;
    //调整全部文字的缩进像素
    paragraph.headIndent = 3;
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:paragraph
                    range:NSMakeRange(0, [detail length])];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:frame];
    //自动换行
    detailLabel.numberOfLines = 0;
    //设置label的富文本
    detailLabel.attributedText = attrStr;
    //label高度自适应
    [detailLabel sizeToFit];
    
    return detailLabel;
}


- (UIButton *)buttonForTitle:(NSString *)title action:(SEL)action{
    
    UIImage *image = [UIImage imageNamed:@"button-default"];
    CGFloat hInset = floorf(image.size.width / 2);
    CGFloat vInset = floorf(image.size.height / 2);
    UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    image = [image resizableImageWithCapInsets:insets];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:kALLBUTTON_COLOR forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

//    UIButton *button = [self defaultRightButtonWithTitle:title];
    
    if (action) {
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    return button;
}

- (UIButton *)defaultBackButtonWithTitle:(NSString *)title{
    UIButton *button = [self defaultRightButtonWithTitle:title];
    return button;
}

-(UIButton *)defaultRightButtonWithTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 65, 35);
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    return btn;
}

-(void)showNetStateBar
{
    self.iv_netstate.hidden = NO;
    self.iv_netstate.layer.opacity = 0.0;
    CGRect rect = self.view.bounds;
    rect.size.height -= self.iv_netstate.frame.size.height;
    rect.origin.y += self.iv_netstate.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.iv_netstate.layer.opacity = 1.0;
        _scrollView.frame = rect;
    }completion:^(BOOL finished) {
        [self.iv_netstate bringSubviewToFront:self.view];
    }];

}

-(void)hideNetStateBar{
    CGRect rect = self.view.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        self.iv_netstate.layer.opacity = 0.0;
        _scrollView.frame = rect;
    } completion:^(BOOL finished) {
        self.iv_netstate.hidden = YES;
    }];
}


-(void)reachabilityChanged: (NSNotification* )note {
    
    Reachability* curReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            [self showNetStateBar];
            break;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi:
        {
            [self hideNetStateBar];
            break;
        }
    }
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



- (void)tapNetworkAction:(id)sender{
    [self alertNetworkStatus];
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reachabilityChanged:nil];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
 
    [self.tabBarController.tabBar setHidden:!self.flag];
}

-(void)getUrlValue:(NSString *)urlValue success:(NSString *)success result:(NSString *)result delegate:(id<HeadViewControllerDelegate> )delegate{
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSString *serviceStr = [NSString stringWithFormat:@"%@%@",self.serviceIPInfo,urlValue];
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
         [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
         NSString *url = [NSString stringWithFormat:@"%@",weakRequest.url];
        if ([dic[success] integerValue] ==1){
            NSDictionary *result = dic[result];
            if (delegate && [delegate respondsToSelector:@selector(getUrlValue:successInfo:)]) {
                [delegate getUrlValue:url successInfo:result];
            }
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

//创建postdata
- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict{
    
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
    
    for (int i = 0; i < [keys count]; i++){
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]])
        {
            // handle image data
            NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
            [result appendData: DATA(formstring)];
            [result appendData:value];
        }
        else
        {
            // all non-image fields assumed to be strings
            NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
            [result appendData: DATA(formstring)];
            [result appendData:DATA(value)];
        }
        
        NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
    
    NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    return result;
}

- (NSString *)uploadWithImage:(UIImage *)image{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSString *serviceUrl = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.UploadAction?action=uploadphoto",self.serviceIPInfo];
    
    NSDate *now = [NSDate new];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"IMG_%@",[formatter stringFromDate:now]];

    MyOperation *pic = [MyOperation new];
    pic.theImage=image;
    pic.fileName = fileName;
    NSDictionary *result = [pic uploadingWithUrl:serviceUrl];
    [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    if (result[@"result"]) {
        return result[@"result"][@"photoId"];
    }
    return nil;
}

- (NSString *)uploadWithImage:(UIImage *)image url:(NSString *)url{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSString *serviceUrl = [NSString stringWithFormat:@"%@%@",self.serviceIPInfo,url];
    
    NSDate *now = [NSDate new];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"IMG_%@.jpg",[formatter stringFromDate:now]];
    
    MyOperation *pic = [MyOperation new];
    pic.theImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(640.0, 960.0)];
    pic.fileName = fileName;
    NSDictionary *result = [pic uploadingWithUrl:serviceUrl];
    [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    if (result[@"result"]) {
        return result[@"result"][@"photoId"];
    }
    return nil;
}

- (void)roundImageView:(UIImageView *)imageView withColor:(UIColor *)color{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
    imageView.layer.borderWidth = 1.0;
    if (!color) {
        color = [UIColor whiteColor];
    }
    imageView.layer.borderColor = color.CGColor;
    
    
    [imageView animateCircleMaskWithduration:2.0 delay:0.0 clockwise:YES compeletion:^{
       
    }];
}

- (NSString *)createFolderPath{
    
//    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
//    
//    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:kOneselfInfo];
//    NSString *username = info[@"objname"];
//    
//    path = [path stringByAppendingPathComponent:username];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL fileExists = [fileManager fileExistsAtPath:path];
//    if (!fileExists) {
//        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    }
    
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    
    return path;
}

- (BOOL)isFileExistsPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:path];
}

//根据title和区域大小画圆形，背景色为随机颜色
- (UIImage *)drawRoundWith:(NSString *)title size:(CGSize)size fillColor:(UIColor *)fillColor{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0,size.width, size.height);
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    随机颜色
    UIColor *color = fillColor?fillColor:kALLBUTTON_COLOR;
    
    button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    button.backgroundColor = color;
    button.layer.borderWidth = 1;
    button.layer.borderColor = color.CGColor;
    button.layer.cornerRadius = button.bounds.size.width/2;
    //    以下是形成图片快照
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    //从上下文中获取图片
    [button.layer renderInContext:ctx];
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    return image;
}


#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)image:(UIImage *)image resizableImageWithCapInsets:(UIEdgeInsets)insets size:(CGSize)size{

    image= [image resizableImageWithCapInsets:insets];
    
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)showRightBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action{
    
    UIButton *button = [self defaultRightButtonWithTitle:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (NSString *)toJSONWithObject:(id)object{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length]> 0 && error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}

- (NSString *)getInputType:(NSString *)displaytype datatype:(NSString *)datatype displaymode:(NSString *)displaymode{
    
//    NSString *returnInputType = kTextField;
//    if([displaytype isEqualToString:@"4"]){
//        returnInputType = kCheckboxField;//复选框
//    }
//    if([displaytype isEqualToString:@"5"]){
//        returnInputType = kSelectListField;//下拉列表
//    }
//    
//    if([displaytype isEqualToString:@"1"] && ![datatype isEqualToString:@"4"] && ![datatype isEqualToString:@"5"]){
//        returnInputType = kTextField;
//    }
//    
//    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"4"]){
//        returnInputType = kDateField;//日期
//    }
//    
//    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"5"]){
//            returnInputType = kTimeField;
//    }

    NSString *returnInputType = kEditTextField;
    if([displaytype isEqualToString:@"6"]){
        returnInputType = kSingleListField;
        if ([datatype isEqualToString:@"4"] && [displaymode isEqualToString:@"2"]) {
            returnInputType = kSingleListField;
        }
        //多选部门11
        if (([datatype isEqualToString:@"2"] ||[datatype isEqualToString:@"11"]) && [displaymode isEqualToString:@"2"]) {
            returnInputType = kMoreListField;
        }
    }
    
    if([displaytype isEqualToString:@"3"] || [displaytype isEqualToString:@"7"]){
        returnInputType = kUploadFileField;//上传附件
        
        if([displaytype isEqualToString:@"3"] && datatype.length ==0 && [displaymode isEqualToString:@"2"]){
            returnInputType = kEditTextField;//可编辑文本框
        }
    }
    
    if([displaytype isEqualToString:@"4"] && datatype.length ==0){
        returnInputType = kCheckboxField;//复选框
    }
    
    if([displaytype isEqualToString:@"5"]){
        returnInputType = kSelectListField;//下拉列表
    }

    
    if([displaytype isEqualToString:@"1"] && ![datatype isEqualToString:@"4"] && ![datatype isEqualToString:@"5"]){
        returnInputType = kTextField;

        if ([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"1"] && [displaymode isEqualToString:@"2"]) {
            returnInputType = kEditTextField;//可编辑文本框
        }
        
        if([displaymode isEqualToString:@"3"]){
            returnInputType = kEditTextField;
        }
    }
    
    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"4"] && [displaymode isEqualToString:@"3"]){
        returnInputType = kDateField;//日期
    }

    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"5"] && [displaymode isEqualToString:@"3"]){
        returnInputType = kTimeField;//时间
    }
    
    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"4"] && [displaymode isEqualToString:@"2"]){
        returnInputType = kDateField;
    }
    
    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"5"] && [displaymode isEqualToString:@"2"]){
        returnInputType = kTimeField;
    }
    
    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"2"] && [displaymode isEqualToString:@"2"]){
        returnInputType = kEditTextField;
    }
    
    if([displaytype isEqualToString:@"1"] && [datatype isEqualToString:@"3"] && [displaymode isEqualToString:@"2"]){
        returnInputType = kEditTextField;
    }
    
    if([displaytype isEqualToString:@"2"] && datatype.length ==0 && [datatype isEqualToString:@"2"]){
        returnInputType = kTextField;
    }
    
    return returnInputType;
}

//设置cookie
- (void)setCookie:(NSURL *)url{
    
    NSDictionary *result =[[NSUserDefaults standardUserDefaults] objectForKey:kOneselfInfo];
    
    NSString *sessionid=result[@"sessionid"];
    
    NSMutableDictionary *cookiePropertiesUser = [NSMutableDictionary dictionary];
    @try {
        [cookiePropertiesUser setObject:@"JSESSIONID" forKey:NSHTTPCookieName];
        [cookiePropertiesUser setObject:sessionid forKey:NSHTTPCookieValue];
        [cookiePropertiesUser setObject:[url host] forKey:NSHTTPCookieDomain];
        //    [cookiePropertiesUser setObject:[url host] forKey:NSHTTPCookieOriginURL];
        [cookiePropertiesUser setObject:[url path] forKey:NSHTTPCookiePath];
        [cookiePropertiesUser setObject:@"0" forKey:NSHTTPCookieVersion];
        
        [cookiePropertiesUser setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@ host:%@",exception,[url host]);
    }
    
    
    NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookiePropertiesUser];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieuser];
}

//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


- (NSString*)uuid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return result;
}

#pragma mark 自定义转场动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC{
    
    
    MyTransformAnimation *animation = [[MyTransformAnimation alloc] init];
    if (operation == UINavigationControllerOperationPush) {
        animation.transform = CGAffineTransformMakeTranslation(0.0,CGRectGetHeight(toVC.view.bounds));
        return animation;
    }
    else if (operation == UINavigationControllerOperationPop) {
        animation.transform = CGAffineTransformMakeTranslation(0.0,-CGRectGetHeight(toVC.view.bounds));
        return animation;
    }
    return nil;
}


@end
