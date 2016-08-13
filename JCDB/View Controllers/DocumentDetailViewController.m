//
//  DocumentDetailViewController.m
//  JCDB
//
//  Created by WangJincai on 16/7/6.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "DocumentDetailViewController.h"
#import "DocumentReplyViewController.h"
#import "SJAvatarBrowser.h"
#import "UIView+BindValues.h"
#import "MyQLPreviewController.h"
#import <QuickLook/QuickLook.h>
#import "MRNavigationBarProgressView.h"

@interface DocumentDetailViewController ()<QLPreviewControllerDataSource>{
    NSMutableArray *dirArray;
}

@end

@implementation DocumentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.replyList.count >0){
        UIBarButtonItem *replyHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"回复历史"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(replyHistoryAction:)];
        NSArray *buttonArray = [[NSArray alloc]initWithObjects:replyHistoryButton,nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }
    
    CGRect frame = self.scrollView.bounds;
    frame.origin.y = 10;
    frame.size.height -=10;
    UILabel *detailLabel = [self adaptiveLabelWithFrame:frame detail:self.valueStr fontSize:14];
    [self.scrollView addSubview:detailLabel];
    frame = detailLabel.frame;
    
    if (self.img.count >0) {
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(frame)+5;
        frame.size.height = 60;
        frame.size.width = self.viewWidth;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        
        [self.scrollView addSubview:scrollView];
        CGFloat w = (self.viewWidth - 300)/6.0;
        for (int i = 0;i<self.img.count;i++) {
            NSString *url = self.img[i];
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(w+i*(w+60),0, 60, 60)];
            [imv sd_setImageWithURL:[NSURL URLWithString:url]];
            [scrollView addSubview:imv];
            
            imv.userInteractionEnabled = YES;
            UITapGestureRecognizer *imvTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageCliecked:)];
            [imv addGestureRecognizer:imvTapGesture];
        }
    }

    if (self.docattach.count >0) {
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(frame)+5;
        frame.size.height = 40;
        frame.size.width = self.viewWidth;
        
        for (int i = 0;i<self.docattach.count;i++) {
            NSDictionary *files = self.docattach[i];
            NSString *title = files[@"filename"];
            UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
            fujianButton.frame = frame;
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
            frame.origin.y = CGRectGetMaxY(frame)+5;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.viewWidth,CGRectGetMaxY(frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

////根据自定义Font自适应宽度高度Label
//- (UILabel *)adaptiveLabelWithFrame:(CGRect)frame detail:(NSString*)detail fontSize:(CGFloat)fontSize{
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:detail];
//    [attrStr addAttribute:NSFontAttributeName
//                    value:[UIFont fontWithName:kFontName size:fontSize]
//                    range:NSMakeRange(0, [detail length])];
//    
////    [attrStr addAttribute:NSForegroundColorAttributeName
////                    value:kFontColor_Contacts
////                    range:NSMakeRange(0, [detail length])];
//    
//    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
//    //行间距
//    paragraph.lineSpacing = 5;
//    //段落间距
//    paragraph.paragraphSpacing = 5;
//    //对齐方式
//    paragraph.alignment = NSTextAlignmentLeft;
//    //指定段落开始的缩进像素
//    paragraph.firstLineHeadIndent = 0;
//    //调整全部文字的缩进像素
//    paragraph.headIndent = 5;
//    [attrStr addAttribute:NSParagraphStyleAttributeName
//                    value:paragraph
//                    range:NSMakeRange(0, [detail length])];
//    
//    UILabel *detailLabel = [[UILabel alloc] initWithFrame:frame];
//    //自动换行
//    detailLabel.numberOfLines = 0;
//    //设置label的富文本
//    detailLabel.attributedText = attrStr;
//    //label高度自适应
//    [detailLabel sizeToFit];
//    
//    return detailLabel;
//}

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
    
    //    NSLog(@"path:%@",path);
    
    //    [request setDataReceivedBlock:^(NSData *data) {
    //        NSLog(@"%d",data.length);
    //    }];
    
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

- (void)replyHistoryAction:(id)sender{
    
    DocumentReplyViewController *documentReplyViewController = DocumentReplyViewController.new;
    documentReplyViewController.replyList = self.replyList;
    documentReplyViewController.title = @"回复历史";
    [self.navigationController pushViewController:documentReplyViewController animated:YES];
    
}

@end
