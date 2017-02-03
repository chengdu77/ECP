//
//  UploadImageFileViewController.m
//  JCDB
//
//  Created by WangJincai on 16/4/28.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "UploadImageFileViewController.h"
#import "UIView+BindValues.h"
#import "MyPhotographViewController.h"
#import "SJAvatarBrowser.h"

static const CGFloat kWobbleRadians = 1.5;
static const NSTimeInterval kWobbleTime = 1.0;

@interface UploadImageFileViewController (){
    NSInteger col;
    NSMutableArray *fileIds;
    NSMutableArray *images;
    
    BOOL isShake;
}

@end

@implementation UploadImageFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    col = 3;
   
    if (self.imageFileIds) {
        fileIds = [NSMutableArray arrayWithArray:self.imageFileIds];
    }else{
        fileIds = [NSMutableArray array];
    }
    
    if (self.imageArrays) {
        images = [NSMutableArray arrayWithArray:self.imageArrays];
    }else{
        images = [NSMutableArray array];
    }
    
    UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(commitAction:)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:commitButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    [self drawUI];
    [self selectImageViewAction];
    
    [self setTitleButtonStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setResultImageBlock:(ResultImageBlock)block{
    self.block = block;
}

- (void)drawUI{
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat width = (self.viewWidth - 40) / col;
    
    NSInteger i=0;
    NSInteger k=0;
    for ( NSInteger j = 0;j < fileIds.count;j++){
        i = j % col;
        k = floorl(j / col);
        CGRect frame = CGRectMake(i*(width+10)+10, 10+k*(width+10), width, width);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = images[j];
        imageView.tag = j;
        
        
        imageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        [imageView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        recognizer.minimumPressDuration = 1; //设置最小长按时间；默认为1秒
        [imageView addGestureRecognizer:recognizer];
        
        [self.scrollView  addSubview:imageView];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,self.viewHeight -100,self.viewWidth,20)];
    label.textColor = RGB(67,74,84);
    label.text = @"长按图片，可删除图片；点击上传可继续上传图片。";
    label.font = [UIFont fontWithName:kFontName size:12];
    [self.scrollView  addSubview:label];
    
}

- (void)addDeleteView {
    
    UIButton *deleteButton = nil;
    for (UIImageView *tempView in self.scrollView.subviews) {
        if ([tempView isKindOfClass:[UIImageView class]]) {
            deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30, 30)];
            [deleteButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
            deleteButton.imageView.tag = tempView.tag;
            deleteButton.tag = tempView.tag;
            [deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
            [tempView addSubview:deleteButton];
            
        }
    }
}

#pragma mark deleteButtonEvent
- (void)delete:(UIButton *)sender {
    
    [self stopShake];
    NSInteger index = sender.tag;
    [fileIds removeObjectAtIndex:index];
    [images removeObjectAtIndex:index];
    [self drawUI];
}
- (void)wobble {
    static BOOL wobblesLeft = NO;
    
    if (isShake) {
        CGFloat rotation = (kWobbleRadians * M_PI) / 180.0;
        CGAffineTransform wobbleLeft = CGAffineTransformMakeRotation(rotation);
        CGAffineTransform wobbleRight = CGAffineTransformMakeRotation(-rotation);
        
        [UIView beginAnimations:nil context:nil];
        
        NSInteger i = 0;
        NSInteger nWobblyButtons = 0;

        
        for (UIView *tempView in self.scrollView.subviews) {
            if ([tempView isKindOfClass:[UIImageView class]] || [tempView isKindOfClass:[UIButton class]]) {
                ++nWobblyButtons;
                if (i % 2) {
                    tempView.transform = wobblesLeft ? wobbleRight : wobbleLeft;
                } else {
                    tempView.transform = wobblesLeft ? wobbleLeft : wobbleRight;
                }
                ++i;
            }
        }
        
        if (nWobblyButtons >= 1) {
            [UIView setAnimationDuration:kWobbleTime];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(wobble)];
            wobblesLeft = !wobblesLeft;
            
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(wobble) withObject:nil afterDelay:kWobbleTime];
        }
        
        [UIView commitAnimations];
    }
}



- (void)stopShake {
    isShake = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    //	[UIView setAnimationDelegate:self];
    
    for (UIView *tempView in self.scrollView.subviews) {
        tempView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
    
    for (UIView *tempView in self.scrollView.subviews) {
        if ([tempView isKindOfClass:[UIButton class]]) {
            [tempView removeFromSuperview];
        }
    }
}


// 设置标题栏上的按钮
-(void)setTitleButtonStyle{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"上传▼" forState:UIControlStateNormal];
    [button setTitle:@"上传▼" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:kFontNameB size:20]];
    [button addTarget:self action:@selector(selectImageViewAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
}

- (void)selectImageViewAction{
    
    if(fileIds.count >9){
        [MBProgressHUD showError:@"最多只能上传九张图片！" toView:self.view.window];
        return;
    }
    
    [[MyPhotographViewController shareInstance] viewController:self withBlock:^(UIImage *image) {
        
//        NSString *processid=[[NSUserDefaults standardUserDefaults] objectForKey:kProcessid];
        
        NSString *serviceStr = @"/ext/com.cinsea.action.UploadAction?action=uploadphoto";
        
        NSString *fileId = [self uploadWithImage:image url:serviceStr];
    
        if (fileId.length >0) {
            [fileIds addObject:fileId];
            [images addObject:image];
            
            [self drawUI];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"上传图片"
                                                            message:@"是否继续添加图片?"
                                                           delegate: self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles: @"确定", nil];
            [alert show];
        }
    }];
}

-(void)magnifyImage:(UITapGestureRecognizer*)tap{
    
    UIImageView *imv = (UIImageView *)tap.view;
    if (imv.image)
    [SJAvatarBrowser showImage:imv];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
    [self addDeleteView];
    
    isShake = YES;
    [self wobble];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self selectImageViewAction];
    }
}

- (void)commitAction:(id)sender{
    self.block(fileIds,images);
    [self backAction];
}


@end
