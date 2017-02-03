//
//  WorkReportViewController.m
//  JCDB
//
//  Created by WangJincai on 16/4/7.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "WorkReportViewController.h"
#import "WorkOrderBean.h"
#import "Constants.h"
#import "SJAvatarBrowser.h"
#import "UIView+BindValues.h"
#import <QuickLook/QuickLook.h>
#import "MRNavigationBarProgressView.h"
#import "MyQLPreviewController.h"

@interface WorkReportViewController ()<UIActionSheetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>{
    MyScrollView *myScrollView;
    NSMutableArray *imageArray;
    
    NSMutableArray *dirArray;
}

@end

@implementation WorkReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    imageArray = [NSMutableArray array];
//    UIImageView *myImageView = nil;
//    CGRect tempFrame = CGRectZero;
//    int k=0;
//    for (WorkReportBean *bean in self.data){
//        UIImageView *imageView=nil;
//        tempFrame = CGRectMake(0,CGRectGetMaxY(tempFrame)+5,self.viewWidth,40);
//        UIView *stateView = [self addCheckView:tempFrame bean:bean imageView:&imageView];
//    
//        [self.scrollView addSubview:stateView];
//        tempFrame = stateView.frame;
//    
//        
//        CGRect rect = CGRectMake(imageView.center.x,0,1,imageView.center.y+5);
//        if (k>0) {
//            rect = CGRectMake(imageView.center.x,myImageView.center.y,1,stateView.center.y -20);
//        }
//        
//        UIView *lineView = [[UIView alloc] initWithFrame:rect];
//        lineView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
//        [self.scrollView addSubview:lineView];
//        [self.scrollView sendSubviewToBack:lineView];
//        myImageView = imageView;
//        
//        k++;
//    }
//    
//    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(tempFrame)+5);
    
    [self initThisView];
    
}

- (void)initThisView{
    
    for(UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    
    int k=0;
    CGRect tempFrame = CGRectMake(0,10,self.viewWidth,40);
    for (WorkReportBean *bean in self.data){
        
        UIView *stateView = [self addCheckView:tempFrame bean:bean tag:k];
        [self.scrollView addSubview:stateView];
        tempFrame = stateView.frame;
        
        if (k < self.data.count -1) {
            tempFrame.origin.y = CGRectGetMaxY(tempFrame)+5;
        }

        k++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(tempFrame)+5);
    
}

- (UIView *)addCheckView:(CGRect)frame bean:(WorkReportBean *)bean tag:(NSInteger)tag{
    frame.size.height = 40;
    UIView *view = [[UIView alloc] init];
    view.frame = frame;
    
    
    CGRect tmpFrame = CGRectMake(10, (CGRectGetHeight(frame)-40)/2+5,60,40);
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:tmpFrame];
    tempLabel.text = bean.datatime;
    tempLabel.font=[UIFont fontWithName:kFontName size:11];
    tempLabel.numberOfLines = 0;
    [view addSubview:tempLabel];
    
    
    NSString *imageName=@"pd_right";
    UIImageView *stateView = [[UIImageView alloc] initWithFrame:CGRectMake(68,10,20,20)];
    stateView.image = [UIImage imageNamed:imageName];
    CGRect stateFrame = stateView.frame;
    
    //  添加图
    UIImage *image = [UIImage imageNamed:@"pd_bj"];
    UIView *bjView = [[UIView alloc] initWithFrame:CGRectMake(90,0,frame.size.width-100,40)];
     bjView.layer.contents = (id)image.CGImage;
    [view addSubview:bjView];
    
    UIImageView *txView = [[UIImageView alloc] initWithFrame:CGRectMake(8,5,30,30)];
    txView.image = [UIImage imageNamed:@"img_user_default"];
    [self roundImageView:txView withColor:kALLBUTTON_COLOR];
    [bjView addSubview:txView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 9, frame.size.width, 22)];
    
    titleLabel.text = (bean.filename.length==0)?bean.operator_:[NSString stringWithFormat:@"%@(有签名)",bean.operator_];
    titleLabel.font=[UIFont fontWithName:kFontName size:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [bjView addSubview:titleLabel];

    if (bean.filename.length >0) {
        titleLabel.tag = tag;
        titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *titleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleCliecked:)];
        [titleLabel addGestureRecognizer:titleTapGesture];
        
    }
    
//    int Y = 0;
    CGRect tFrame = CGRectMake(5,CGRectGetMaxY(txView.frame)+3,bjView.bounds.size.width-8,20);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:tFrame];
    messageLabel.text = bean.message;
    messageLabel.font=[UIFont fontWithName:kFontName size:12];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    [bjView addSubview:messageLabel];
    frame.size.height += 20;
//    view.frame = frame;
    
    CGRect rect = bjView.frame;
    rect.size.height += 20;
 
    if (bean.isExtendFlag) {
        tFrame.origin.y = CGRectGetMaxY(tFrame)+3;
        tFrame.size.width = 60;
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:tFrame];
        tempLabel.text = @"手写签名：";
        tempLabel.font=[UIFont fontWithName:kFontName size:12];
        tempLabel.textAlignment = NSTextAlignmentLeft;
        [bjView addSubview:tempLabel];
        
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(65,CGRectGetMaxY(tempLabel.frame)-20, 40, 40)];
        NSString *url = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",self.serviceIPInfo,bean.filename];
        [imv sd_setImageWithURL:[NSURL URLWithString:url]];
        [bjView addSubview:imv];
        
         imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *imvTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageCliecked:)];
        [imv addGestureRecognizer:imvTapGesture];
        
        frame.size.height += 43;
        rect.size.height += 43;
        
        CGRect bFrame = CGRectMake(5,CGRectGetMaxY(imv.frame)+3,bjView.bounds.size.width-8,30);
        if (bean.attachments.count>0){
            NSDictionary *info = bean.attachments;
            UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
            fujianButton.frame = bFrame;
            fujianButton.value = info[@"attachmentsUrl"];
            fujianButton.Id = info[@"attachmentsName"];
            fujianButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            fujianButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            fujianButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [fujianButton setTitle:info[@"attachmentsName"] forState:UIControlStateNormal];
            [fujianButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [fujianButton setBackgroundColor:[UIColor whiteColor]];
            [fujianButton addTarget:self action:@selector(fujianPreviewerAction:) forControlEvents:UIControlEventTouchUpInside];
            [bjView addSubview:fujianButton];
            
            frame.size.height += 33;
            rect.size.height += 33;
        }
    }

    
    frame.size.height += 3;
    view.frame = frame;
    
    stateFrame.origin.y = (CGRectGetHeight(frame) - CGRectGetHeight(stateFrame))/2;
    stateView.frame = stateFrame;
    
    tmpFrame.origin.y = (CGRectGetHeight(frame) - CGRectGetHeight(tmpFrame))/2;
    tempLabel.frame = tmpFrame;

    
    CGRect lineRect = CGRectMake(stateView.center.x,-10,1,frame.size.height+7);
    UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
    lineView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [view addSubview:lineView];
    [view sendSubviewToBack:lineView];
    
    [view addSubview:stateView];
    [view bringSubviewToFront:stateView];
    
    bjView.frame = rect;
    
    return view;
}

- (void)titleCliecked:(UITapGestureRecognizer *)sender{
 
    NSInteger tag = sender.view.tag;
    
    WorkReportBean *bean = self.data[tag];
    bean.isExtendFlag = !bean.isExtendFlag;
    
    [self initThisView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)imageCliecked:(UITapGestureRecognizer *)sender {
   
    UIImageView *imv = (UIImageView *)sender.view;
    if (imv.image)
        [SJAvatarBrowser showImage:imv];

}

- (void)fujianPreviewerAction:(UIButton *)sender{
    
    NSString *fileName = sender.Id;
    NSString *fileId = sender.value;
    NSString *folderPath = [self createFolderPath];
    NSString *path=[folderPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [self previewFilePath:path Id:fileId];
    }else{
        [self downloadFilePath:path Id:fileId];
    }
    
}

- (void)downloadFilePath:(NSString *)path Id:(NSString *)fileId{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",self.serviceIPInfo,fileId];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    [request setDownloadDestinationPath :path];
    [request setAllowResumeForFileDownloads:YES];
    [request setDownloadProgressDelegate:self.navigationController.progressView];
    
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [self previewFilePath:path Id:fileId];
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"下载请求失败" toView:ShareAppDelegate.window];
    }];
    
    [request startSynchronous];
    
    
}

- (void)previewFilePath:(NSString *)path Id:(NSString *)fileId{
    
    if (!dirArray) {
        dirArray = [NSMutableArray array];
    }
    if ([dirArray indexOfObject:path] == NSNotFound) {
        [dirArray addObject:path];
    }
    
    MyQLPreviewController *previewController = [[MyQLPreviewController alloc] init];
    previewController.dataSource = self;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - QLPreviewControllerDataSource
//Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{
    
    return [dirArray count];
}


// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx{
    
    NSString *path=dirArray[idx];
    return [NSURL fileURLWithPath:path];
}


@end
