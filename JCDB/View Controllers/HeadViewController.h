//
//  HeadViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/1.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MBProgressHUD+Add.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"
#import "SIAlertView.h"
#import "MyOperation.h"
#import "KeyboardManager.h"

#undef ShareAppDelegate
#define ShareAppDelegate [UIApplication sharedApplication].delegate

typedef void(^SuccessRefreshViewBlock)();


@interface MyScrollView:UIScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@protocol HeadViewControllerDelegate;

@interface HeadViewController : UIViewController {
    
}
@property (nonatomic ,assign) BOOL flag;

@property (nonatomic ,strong) NSString *serviceIPInfo;
@property (nonatomic ,assign) CGFloat viewWidth;
@property (nonatomic ,assign) CGFloat viewHeight;
@property (nonatomic ,strong) MyScrollView *scrollView;
@property (nonatomic ,strong) UIView *iv_netstate;

@property (nonatomic ,strong) UILabel *falsePushLabel;


- (void)backAction;

-(void)getUrlValue:(NSString *)urlValue success:(NSString *)success result:(NSString *)result delegate:(id<HeadViewControllerDelegate> )delegate;


- (UILabel *)adaptiveLabelWithFrame:(CGRect)frame detail:(NSString*)detail fontSize:(CGFloat)fontSize;

- (UIButton *)buttonForTitle:(NSString *)title action:(SEL)action;

- (NSString *)uploadWithImage:(UIImage *)image;
- (NSString *)uploadWithImage:(UIImage *)image url:(NSString *)url;

- (void)roundImageView:(UIImageView *)imageView withColor:(UIColor *)color;

- (NSString *)createFolderPath;
- (BOOL)isFileExistsPath:(NSString *)path;

- (UIImage *)drawRoundWith:(NSString *)title size:(CGSize)size fillColor:(UIColor *)fillColor;
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;
- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

- (UIImage *)image:(UIImage *)image resizableImageWithCapInsets:(UIEdgeInsets)insets size:(CGSize)size;
- (void)showRightBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
//id转json格式字符串
- (NSString *)toJSONWithObject:(id)data;


- (NSString *)getInputType:(NSString *)displaytype datatype:(NSString *)datatype displaymode:(NSString *)displaymode;


- (void)setCookie:(NSURL *)url;

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

- (NSString*)uuid;

@end

//定义一个协议
@protocol HeadViewControllerDelegate<NSObject>
- (void)getUrlValue:(NSString *)urlValue successInfo:(NSDictionary *)info;
- (void)getUrlValue:(NSString *)urlValue failed:(NSString *)msg;
@end
