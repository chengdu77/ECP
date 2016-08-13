//
//  DocumentReplyViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/21.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "DocumentReplyViewController.h"
#import "SJAvatarBrowser.h"
#import "UIView+BindValues.h"
#import "MyQLPreviewController.h"
#import <QuickLook/QuickLook.h>
#import "MRNavigationBarProgressView.h"

@interface DocumentReplyViewController ()<QLPreviewControllerDataSource>{
    NSMutableArray *dirArray;
}


@end

@implementation DocumentReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initThisView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initThisView{
    
    CGRect frame = CGRectZero;
    for (int i = 0; i < self.replyList.count; i++) {
        NSDictionary *result = self.replyList[i];
        NSString *strValue = [NSString stringWithFormat:@"  标题：%@\n",result[@"title"]];
        strValue = [strValue stringByAppendingFormat:@"  内容：%@\n",result[@"content"]?result[@"content"]:@""];
        strValue = [strValue stringByAppendingFormat:@"  回复时间：%@\n",result[@"createdate"]];
        strValue = [strValue stringByAppendingFormat:@"  回复人：%@\n",result[@"creator"]];
        
        frame = [self listViewWithFrame:frame value:strValue img:result[@"img"] docattach:result[@"docattach"]];
//        [self.scrollView addSubview:view];
//        frame = view.frame;
        
        frame.origin.y = CGRectGetMaxY(frame)+1;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(frame));
}

- (CGRect)listViewWithFrame:(CGRect)frame value:(NSString *)value img:(NSArray *)img docattach:(NSArray *)docattach{
//    UIView *view = [[UIView alloc] initWithFrame:frame];
//    view.backgroundColor = [UIColor redColor];
    
    CGRect tFrame = CGRectZero;
    tFrame.origin.y = 2;
    tFrame.size.width = self.viewWidth;
    UILabel *detailLabel = [self adaptiveLabelWithFrame:tFrame detail:value fontSize:14];
    [self.scrollView addSubview:detailLabel];
    tFrame = detailLabel.frame;
    
    if (img.count >0) {
        tFrame.origin.x = 0;
        tFrame.origin.y = CGRectGetMaxY(tFrame)+1;
        tFrame.size.height = 30;
        tFrame.size.width = self.viewWidth;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:tFrame];
        
        [self.scrollView addSubview:scrollView];
        CGFloat w = 5;
        for (int i = 0;i<img.count;i++) {
            NSString *url = img[i];
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(w+i*(w+30),0, 30, 30)];
            [imv sd_setImageWithURL:[NSURL URLWithString:url]];
            [scrollView addSubview:imv];
            
            imv.userInteractionEnabled = YES;
            UITapGestureRecognizer *imvTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageCliecked:)];
            [imv addGestureRecognizer:imvTapGesture];
        }
    }
    
    if (docattach.count >0) {
        tFrame.origin.x = 0;
        tFrame.origin.y = CGRectGetMaxY(tFrame)+1;
        tFrame.size.height = 40;
        tFrame.size.width = self.viewWidth;
        
        for (int i = 0;i<docattach.count;i++) {
            NSDictionary *files = docattach[i];
            NSString *title = files[@"filename"];
            UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
            fujianButton.frame = tFrame;
            fujianButton.value = files[@"fileUrl"];
            fujianButton.Id = files[@"filename"];
            fujianButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            fujianButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            fujianButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [fujianButton setTitle:title forState:UIControlStateNormal];
            [fujianButton setTitleColor:kALLBUTTON_COLOR forState:UIControlStateNormal];
            [fujianButton setBackgroundColor:[UIColor whiteColor]];
            [fujianButton addTarget:self action:@selector(fujianPreviewerAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:fujianButton];
            tFrame.origin.y = CGRectGetMaxY(tFrame)+5;
        }
    }
    
//    frame.size.height = CGRectGetHeight(tFrame);
//    view.frame = frame;
    
    return tFrame;
}

- (void)imageCliecked:(UITapGestureRecognizer *)sender {
    
    UIImageView *imv = (UIImageView *)sender.view;
    [SJAvatarBrowser showImage:imv];
    
}

- (void)fujianPreviewerAction:(UIButton *)sender{
    
    NSString *fileName = ((UIButton *)sender).titleLabel.text;
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
    NSString *urlStr = fileId;
    
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
