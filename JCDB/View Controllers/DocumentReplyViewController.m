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

@protocol DocumentHeadViewDelegate;

@interface DocumentHeadView : UIView

@property(nonatomic, assign) id<DocumentHeadViewDelegate> delegate;
@property(nonatomic, assign) NSInteger section;
@property(nonatomic, assign) BOOL open;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, assign) NSInteger statusListCount;
@property(nonatomic, assign) CGFloat CellHeight;
@end

@protocol DocumentHeadViewDelegate <NSObject>
-(void)selectedWith:(DocumentHeadView *)view;
@end

#import "Constants.h"

@implementation DocumentHeadView


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.open = NO;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(CGRectGetHeight(frame)-20)/2,frame.size.width-20,20)];
        self.titleLabel.font = [UIFont fontWithName:kFontName size:14];
        [self addSubview:self.titleLabel];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-30,(CGRectGetHeight(frame)-20)/2,20,20)];
        self.imageView.image = [UIImage imageNamed:@"img_wf_log_b"];
        [self addSubview:self.imageView];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doSelected)];
        [self addGestureRecognizer:viewTapGesture];
    }
    return self;
}

-(void)doSelected{
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectedWith:)]){
        [_delegate selectedWith:self];
    }
}
@end


@interface DocumentReplyViewController ()<QLPreviewControllerDataSource,UITableViewDelegate,UITableViewDataSource,DocumentHeadViewDelegate>{
    NSMutableArray *dirArray;
    UITableView* _tableView;
    
    NSInteger _currentSection;
    NSInteger _currentRow;
    
    UIBarButtonItem *expandButton;
}

@property(nonatomic, strong) NSMutableArray *headViewArray;


@end

@implementation DocumentReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    expandButton = [[UIBarButtonItem alloc] initWithTitle:@"展开"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                   action:@selector(expandAction:)];
    self.navigationItem.rightBarButtonItem = expandButton;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64,self.viewWidth,self.viewHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self.scrollView removeFromSuperview];
    
//    [self initThisView];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)loadModel{

    _currentRow = -1;
    _headViewArray = [[NSMutableArray alloc] init];
    for(int i = 0;i< self.replyList.count ;i++){
        DocumentHeadView* headview = [[DocumentHeadView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 40)];
        headview.delegate = self;
        headview.section = i;
        headview.open = NO;
        
        headview.userInteractionEnabled = YES;
        
        NSDictionary *result = self.replyList[i];
        NSString *strValue = [NSString stringWithFormat:@"  标题：%@\n",result[@"title"]];
        headview.titleLabel.text = strValue;
        headview.statusListCount = i;
        [_headViewArray addObject:headview];
    }
}


- (void)initTableView{
    
    [self loadModel];
    [_tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DocumentHeadView* headView = [_headViewArray objectAtIndex:indexPath.section];
   
    return headView.open?headView.CellHeight:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [_headViewArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DocumentHeadView* headView = [_headViewArray objectAtIndex:section];
    return headView.open?1:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.replyList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *result = self.replyList[indexPath.row];
    NSString *strValue = [NSString stringWithFormat:@"  内容：%@\n",result[@"content"]?result[@"content"]:@""];
    strValue = [strValue stringByAppendingFormat:@"  回复时间：%@\n",result[@"createdate"]];
    strValue = [strValue stringByAppendingFormat:@"  回复人：%@\n",result[@"creator"]];

    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.viewWidth,0.5)];
    lineLabel.backgroundColor = kBackgroundColor;
    [cell addSubview:lineLabel];
    
    CGRect rect = lineLabel.frame;
    CGRect r = CGRectMake(0,CGRectGetMaxY(rect)+2,self.viewWidth, 40);

    CGRect frame = [self listView:cell withFrame:r value:strValue img:result[@"img"] docattach:result[@"docattach"] section:indexPath.section];
    cell.frame = frame;

    DocumentHeadView* headView = [_headViewArray objectAtIndex:indexPath.section];
    headView.CellHeight = frame.size.height;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentRow = indexPath.row;
    [_tableView reloadData];
}


#pragma mark - HeadViewdelegate
-(void)selectedWith:(DocumentHeadView *)view{
    _currentSection = view.section;
    
    for(int i = 0;i<[_headViewArray count];i++){
        DocumentHeadView *head = [_headViewArray objectAtIndex:i];
        if(head.section == _currentSection){
            if (head.open) {
                head.open = NO;
                head.imageView.image = [UIImage imageNamed:@"img_wf_log_b"];
            }else{
                head.open = YES;
                head.imageView.image = [UIImage imageNamed:@"img_wf_log_a"];
            }
        }
    }
    [_tableView reloadData];
}



- (CGRect)listView:(UIView *)view withFrame:(CGRect)frame value:(NSString *)value img:(NSArray *)img docattach:(NSArray *)docattach section:(NSInteger)section{


    CGRect tFrame = frame;
    tFrame.origin.y = 2;
    tFrame.size.width = self.viewWidth;
    UILabel *detailLabel = [self adaptiveLabelWithFrame:tFrame detail:value fontSize:14];
    tFrame = detailLabel.frame;
    [view addSubview:detailLabel];
    
    if (img.count >0) {
        tFrame.origin.x = 0;
        tFrame.origin.y = CGRectGetMaxY(tFrame)-10;
        tFrame.size.height = 30;
        tFrame.size.width = self.viewWidth;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:tFrame];
        
        [view addSubview:scrollView];
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
        CGRect tmpRect = CGRectZero;
        tmpRect.origin.x = 0;
        tmpRect.origin.y = CGRectGetMaxY(tFrame) -10;
        tmpRect.size.height = 40;
        tmpRect.size.width = self.viewWidth;
        
        for (int i = 0;i<docattach.count;i++) {
            NSDictionary *files = docattach[i];
            NSString *title = files[@"filename"];
            UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
            fujianButton.frame = tmpRect;
            fujianButton.value = files[@"fileUrl"];
            fujianButton.Id = title;
            fujianButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            fujianButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            fujianButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [fujianButton setTitle:title forState:UIControlStateNormal];
            [fujianButton setTitleColor:kALLBUTTON_COLOR forState:UIControlStateNormal];
            [fujianButton setBackgroundColor:[UIColor whiteColor]];
            [fujianButton addTarget:self action:@selector(fujianPreviewerAction:) forControlEvents:UIControlEventTouchUpInside];
            
            fujianButton.tag = 100*(section+1) +i;
            [view addSubview:fujianButton];
            tmpRect.origin.y = CGRectGetMaxY(tmpRect)+5;
        }
      
        tFrame.size.height = CGRectGetMaxY(tmpRect) - frame.origin.y - 40;
    }
   
    return tFrame;
}

- (void)imageCliecked:(UITapGestureRecognizer *)sender {
    
    UIImageView *imv = (UIImageView *)sender.view;
    if (imv.image)
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
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{
    
    return [dirArray count];
}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx{
    
    NSString *path = dirArray[idx];
    return [NSURL fileURLWithPath:path];
}


- (void)expandAction:(id)sener{
    
    for(NSUInteger i = 0;i< _headViewArray.count ;i++){
        DocumentHeadView* headview = [[DocumentHeadView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 40)];
        headview.open = [expandButton.title isEqualToString:@"展开"]?YES:NO;
        
        headview.userInteractionEnabled = YES;
        
        NSDictionary *result = self.replyList[i];
        NSString *strValue = [NSString stringWithFormat:@"  标题：%@\n",result[@"title"]];
        headview.titleLabel.text = strValue;
        headview.statusListCount = i;
        
        [_headViewArray replaceObjectAtIndex:i withObject:headview];
    }

    if ([expandButton.title isEqualToString:@"收起"]) {
        expandButton.title = @"展开";
    }else{
        expandButton.title = @"收起";
    }
    
    [_tableView reloadData];
    
    
}




@end
