//
//  WorkOrderDetailsViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/5.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "WorkOrderDetailsViewController.h"
#import "AppendixDetailsViewController.h"
#import <QuickLook/QuickLook.h>
#import "MRNavigationBarProgressView.h"
#import "UIView+BindValues.h"
#import "FormFieldsBean.h"
#import "WorkOrderBean.h"
#import "NSDate+Helper.h"
#import "DDList.h"
#import "LeveyPopListView.h"
#import "RichLeveyPopListView.h"
#import "IQTextView.h"
#import "SSCheckBoxView.h"
#import "UIHelpers.h"
#import "SignViewController.h"
#import "FlowChartViewController.h"
#import "SIAlertView.h"
#import "MyQLPreviewController.h"
#import "UploadImageFileViewController.h"
#import "TreeDeptViewController.h"

#import "WorkReportViewController.h"
#import "ProcessStatusViewController.h"


#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "YALNavigationBar.h"

static NSString *const menuCellIdentifier = @"ContextMenuCell";

#define kTitleViewTag 100
#define kValueViewTag 101

#define kActionSheetTag 200

#define kPassSheetTag 201
#define kRejectSheetTag 202
#define kAllSheetTag 203

@interface WorkOrderDetailsViewController ()<UITextFieldDelegate,LeveyPopListViewDelegate,RichLeveyPopListViewDelegate,UIActionSheetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
YALContextMenuTableViewDelegate
>{
    NSMutableArray *formfieldsArray;
    NSDictionary *mainformDictionary;
    NSMutableArray *detailforms;
    NSMutableArray *viewsArray;
    //    NSMutableArray *tableArray;
    NSMutableArray *dirArray;
    
    NSMutableDictionary *tableDictionary;
    
    NSNumber *optlevel;
    NSNumber *rejectable;
    NSString *rejecttonode;
    
    DDList *_ddList;
    UIButton *addButton;
    
    
    NSString *filePath;
    NSArray *imageFileIds;
    NSArray *imageArrays;
    
    UIButton *favoriteButton;
    BOOL isFavorite;
    NSString *workflowid;
    
    BOOL isNotify;
    
    UIBarButtonItem *rightButton;
}

@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@property(nonatomic,strong)UILabel *markLabel;

@end

@implementation WorkOrderDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事项详情";
    
    self.markLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 40)];
    self.markLabel.text=@"正在加载数据";
    self.markLabel.textAlignment=NSTextAlignmentCenter;
    self.markLabel.font=[UIFont fontWithName:kFontName size:14.0];
    self.markLabel.hidden=YES;
    [self.scrollView addSubview:self.markLabel];
    
    formfieldsArray = [NSMutableArray array];
    viewsArray = [NSMutableArray array];
    
    rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_black_24dp"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(btnAddAction:)];
    
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)requestData{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessAction?action=getformdata&processid=%@",self.serviceIPInfo,self.processid];
    if (self.type ==1){
        serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.ProcessAction?action=getformdata&processid=%@",self.serviceIPInfo,self.processid];
    }
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] ==1){
            
            //            dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *result = dic[@"result"];
            NSArray *formfields = result[@"formfields"];
            for (NSDictionary *info in formfields) {
                FormFieldsBean *bean = [FormFieldsBean new];
                bean.Id = info[@"Id"];
                //                    bean.bedefault = info[@"bedefault"];
                //                    bean.bemoney = info[@"bemoney"];
                //                    bean.beunique = info[@"beunique"];
                bean.browserid = [NSString stringWithFormat:@"%@",info[@"browserid"]];
                //                    bean.dataproperty = info[@"dataproperty"];
                bean.datatype = [NSString stringWithFormat:@"%@",info[@"datatype"]];
                //                    bean.deleted = info[@"deleted"];
                bean.displaymode = [NSString stringWithFormat:@"%@",info[@"displaymode"]];
                bean.displaytype = [NSString stringWithFormat:@"%@",info[@"displaytype"]];
                bean.bemulti = [NSString stringWithFormat:@"%@",info[@"bemulti"]?info[@"bemulti"]:@""];
                bean.divcolspan = info[@"divcolspan"];
                //                    bean.divorder = info[@"divorder"];
                //                    bean.divsrow = info[@"divsrow"];
                //                    bean.docsavedir = info[@"docsavedir"];
                if (info[@"fileData"]) {
                    bean.fileData = info[@"fileData"];
                }
                //                    bean.formdiv = info[@"formdiv"];
                bean.formid = info[@"formid"];
                bean.fileName = info[@"fileName"]?info[@"fileName"]:@"";
                
                NSString *labelname = info[@"labelname"];
                if ([bean.displaymode isEqualToString:@"3"]) {
                    labelname = [NSString stringWithFormat:@"%@*",labelname];
                }
                bean.labelname = labelname;
                bean.fieldname = info[@"fieldname"]?info[@"fieldname"]:@"";
                
                //                    bean.logged = info[@"logged"];
                //                    bean.prompt = info[@"prompt"];
                //                    bean.validateexpr = info[@"validateexpr"];
                
                [formfieldsArray addObject:bean];
            }
            
            mainformDictionary = result[@"mainform"];
            
            if (!detailforms) {
                detailforms = [NSMutableArray array];
            }
            for (NSDictionary *dic in result[@"detailforms"]){
                DetailformsBean *bean = [DetailformsBean new];
                bean.tabledata = dic[@"tabledata"];
                bean.tabledesc = dic[@"tabledesc"];
                bean.tablename = dic[@"tablename"];
                
                [detailforms addObject:bean];
            }
            
            optlevel = result[@"optlevel"];
            rejectable = result[@"rejectable"];
            isFavorite = [result[@"favorite"] boolValue];
            rejecttonode = result[@"rejecttonode"][@"id"];
            workflowid = result[@"workflowid"];
            
//            NSLog(@"result:%@",result);
            isNotify = [result[@"Notify"] boolValue];
            if (self.type == 1){
                self.canEditFlag = isNotify;
            }
            
            [self setUIWithAnimation:YES];
            
            [self initiateMenuOptions];
            
            self.navigationItem.rightBarButtonItem = rightButton;
            
            //            });
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        self.markLabel.hidden=YES;
        
    }];
    
    [request startAsynchronous];
}

- (void)setUIWithAnimation:(BOOL)hasAnimation{
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [viewsArray removeAllObjects];
    
    CGRect frame=CGRectMake(0, 0, self.viewWidth-20, self.viewHeight-80);
    
    if (hasAnimation) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
    }
    
    for (int i=0;i<formfieldsArray.count;i++) {
        FormFieldsBean *bean = formfieldsArray[i];
        NSString *returnInputType = [self getInputType:bean.displaytype datatype:bean.datatype displaymode:bean.displaymode];
        NSString *title = mainformDictionary[bean.Id];
        
        if (!title) {
            continue;
        }
        
        UIView *view = [self addViewFrame:frame tag:100*i bean:bean fieldType:returnInputType];
        if (!view) {
            continue;
        }
        
        if ([returnInputType isEqualToString:kSelectListField]) {
            _ddList = [[DDList alloc] initWithStyle:UITableViewStylePlain];
            [_ddList setPosition:CGPointMake(87,CGRectGetMaxY(view.frame)+12)];
        }
        
        [self.scrollView addSubview:view];
        frame = view.frame;
        frame.origin.y =CGRectGetMaxY(frame) +5;
    }
    
    for (int i=0;i<detailforms.count;i++) {
        DetailformsBean *b = detailforms[i];
        FormFieldsBean *bean = [FormFieldsBean new];
        bean.labelname = b.tabledesc;
        bean.fileData = b.tabledata;
        bean.tablename = b.tablename;
        
        UIView *view = [self addViewFrame:frame tag:1000+100*i bean:bean fieldType:kTableField];
        if (!view) {
            continue;
        }
        
        [self.scrollView addSubview:view];
        frame = view.frame;
        frame.origin.y =CGRectGetMaxY(frame) +5;
    }
    
    frame.size.height =CGRectGetMaxY(frame) -50;
    [self.scrollView setContentSize:frame.size];
    
    [self initAddButton];
    
    if (hasAnimation){
        [UIView commitAnimations];
    }
    [self.scrollView addSubview:_ddList.view];
    [_ddList setDDListHidden:YES];
    
    [favoriteButton setTitle:isFavorite?@"取关":@"关注" forState:UIControlStateNormal];
    
}

- (UIView *)addViewFrame:(CGRect)frame tag:(int)tag bean:(FormFieldsBean *)bean fieldType:(NSString *)fieldType {
    
    NSString *value = mainformDictionary[bean.Id];
    UIView *view = [UIView new];

    BOOL isOk  = ([fieldType isEqualToString:kEditTextField] &&([bean.fieldname isEqualToString:@"content"] || [bean.fieldname isEqualToString:@"subject"]));
    
    frame.size.height = isOk?kTextFieldHeight:kEditTextFieldHeight;
    view.frame = frame;
    frame=CGRectMake(8,10,82,40);
    
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.font = [UIFont fontWithName:kFontName size:14];
    
    if ([bean.displaymode isEqualToString:@"3"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:bean.labelname];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(str.length-1,1)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontNameB size:17] range:NSMakeRange(str.length-1,1)];
        aLabel.attributedText = str;
    }else{
        aLabel.text = bean.labelname;
    }
    aLabel.textAlignment = NSTextAlignmentLeft;
    aLabel.numberOfLines = 0;
    CGSize size = CGSizeMake(82,200);
    CGSize labelsize = [aLabel sizeThatFits:size];
    [aLabel setFrame:CGRectMake(8,10,82,labelsize.height)];
    [view addSubview:aLabel];
    
    if ([fieldType isEqualToString:kEditTextField] ||[fieldType isEqualToString:kTextField] ||[fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ||[fieldType isEqualToString:kDateField]  ||[fieldType isEqualToString:kTimeField] || [fieldType isEqualToString:kSelectListField]) {
        
        frame = CGRectMake(87,10,self.viewWidth -100,isOk?kTextFieldHeight:kEditTextFieldHeight);
       
        if ([fieldType isEqualToString:kEditTextField] ||[fieldType isEqualToString:kTextField]) {
            
            if (!([bean.fieldname isEqualToString:@"content"] || [bean.fieldname isEqualToString:@"subject"])){
                UITextField *textField = [[UITextField alloc] init];
                
                textField.font = [UIFont fontWithName:kFontName size:14];
                textField.frame = frame;
                textField.text = value;
                textField.value = value;
                textField.tag = tag;
                textField.fieldType = fieldType;
                textField.Id = bean.Id;
                textField.fieldname = bean.fieldname;
                //小数
                if ([bean.datatype isEqualToString:@"3"]) {
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                }
                //整数
                if ([bean.datatype isEqualToString:@"2"]){
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                }
                
                textField.backgroundColor = [UIColor whiteColor];
                textField.textAlignment = NSTextAlignmentCenter;
                textField.delegate = self;
                textField.userInteractionEnabled = ((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag);
                if (((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag)) {
                    textField.placeholder = @"可输入修改";
                }
                
                if ([bean.displaymode isEqualToString:@"3"]) {
                    textField.must = @"1";
                    textField.placeholder =@"必填";
                    textField.labelname = bean.labelname;
                }
                
                textField.layer.borderColor = self.canEditFlag?kALLBUTTON_COLOR.CGColor:kBackgroundColor.CGColor;
                textField.layer.borderWidth = .5;
                textField.layer.cornerRadius = 6;
                [textField.layer setMasksToBounds:YES];
                
                [view addSubview:textField];

                [viewsArray addObject:textField];
            }else{
                
                UITextView *textView = [[UITextView alloc] init];
                textView.scrollEnabled = YES;   //允许滚动
                textView.font = [UIFont fontWithName:kFontName size:14];
                textView.frame = frame;
                textView.text = value;
                textView.value = value;
                textView.tag = tag;
                textView.fieldType = fieldType;
                textView.Id = bean.Id;
                textView.fieldname = bean.fieldname;
                
                textView.keyboardType = UIKeyboardTypeDecimalPad;
                
                if ([bean.displaymode isEqualToString:@"3"]) {
                    textView.must = @"1";
//                    textView.placeholder =@"必填";
                    textView.labelname = bean.labelname;
                }
                
                textView.layer.borderColor = self.canEditFlag?kALLBUTTON_COLOR.CGColor:kBackgroundColor.CGColor;
                textView.layer.borderWidth = .5;
                textView.layer.cornerRadius = 6;
                [textView.layer setMasksToBounds:YES];
                
                [view addSubview:textView];
                
                [viewsArray addObject:textView];
            }
        }else{
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.font = [UIFont fontWithName:kFontName size:14];
            bLabel.frame = frame;
            aLabel.tag = tag;
            bLabel.text = value;
            bLabel.value = value;
            bLabel.fieldType = fieldType;
            bLabel.Id = bean.Id;
            bLabel.fieldname = bean.fieldname;
            bLabel.bemulti = bean.bemulti;
            bLabel.browserid = bean.browserid;
            bLabel.datatype = bean.datatype;
            bLabel.textAlignment = NSTextAlignmentCenter;
            if ([bean.displaymode isEqualToString:@"3"]) {
                bLabel.must = @"1";
                bLabel.labelname = bean.labelname;
            }
            bLabel.text = value?value:@"请点击";
            
            if (([fieldType isEqualToString:kSelectListField] ||[fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField]) && self.canEditFlag && ![bean.displaymode isEqualToString:@"1"] ) {
                bLabel.pulldownData = bean.fileData;
                //                NSLog(@"id:%@",bean.Id);
                bLabel.value = mainformDictionary[[NSString stringWithFormat:@"%@_id",bean.Id]]; //[self findId:bLabel];
                //                NSLog(@"bLabel.value:%@",bLabel.value);
                
                if ([fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ) {
                    bLabel.viewListTitle = bean.labelname;
                    UIImageView *tmepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_edit_search"]];
                    tmepImageView.frame = CGRectMake(CGRectGetWidth(frame)-20, (CGRectGetHeight(frame)-18)/2, 18, 18);
                    [bLabel addSubview:tmepImageView];
                }
            }
            
            if ([fieldType isEqualToString:kSelectListField]) {
                UIImageView *tmepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_spinner_arror"]];
                tmepImageView.frame = CGRectMake(CGRectGetWidth(frame)-20, (CGRectGetHeight(frame)-18)/2, 18, 18);
                [bLabel addSubview:tmepImageView];
            }
            
            if ([fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ||[fieldType isEqualToString:kDateField]  ||[fieldType isEqualToString:kTimeField] || [fieldType isEqualToString:kSelectListField]) {
                
                //                bLabel.backgroundColor = RGB(230, 233, 238);
                bLabel.layer.borderColor = self.canEditFlag?kALLBUTTON_COLOR.CGColor:kBackgroundColor.CGColor;
                bLabel.layer.borderWidth = .5;
                bLabel.layer.cornerRadius = 6;
                [bLabel.layer setMasksToBounds:YES];
                
                
                if (self.canEditFlag && ![bean.displaymode isEqualToString:@"1"]) {
                    //增加点击事件
                    bLabel.userInteractionEnabled = YES;
                    UITapGestureRecognizer *firstDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction:)];
                    [bLabel addGestureRecognizer:firstDtapGesture];
                }
                //add by 2017-1-13
                if (self.canEditFlag && [bean.displaymode isEqualToString:@"1"]) {
                     bLabel.value = mainformDictionary[[NSString stringWithFormat:@"%@_id",bean.Id]];
                }
            }
            
            [view addSubview:bLabel];
            [viewsArray addObject:bLabel];
        }
        
    }else{
        
        if ([fieldType isEqualToString:kCheckboxField]) {
            frame=CGRectMake(self.viewWidth -48,10,28,28);
            SSCheckBoxView *cbv =[[SSCheckBoxView alloc] initWithFrame:frame style:kSSCheckBoxViewStyleGlossy checked:NO];
            cbv.tag = tag;
            cbv.fieldType = fieldType;
            cbv.Id = bean.Id;
            cbv.fieldname = bean.fieldname;
            if (self.canEditFlag && ![bean.displaymode isEqualToString:@"1"]) {
                [cbv setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
            }
            cbv.enabled = self.canEditFlag;
            cbv.checked = [value boolValue];
            cbv.value = value;
            [view addSubview:cbv];
            [viewsArray addObject:cbv];
            
            if ([bean.displaymode isEqualToString:@"3"]) {
                cbv.must = @"1";
                cbv.labelname = bean.labelname;
            }
        }
        
        if ([fieldType isEqualToString:kUploadFileField]) {
            
            frame=CGRectMake(self.viewWidth -100,10,80,30);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = frame;
            button.tag = tag;
            button.fieldType = fieldType;
            button.Id = bean.Id;
            button.fieldname = bean.fieldname;
            button.value = value;
            
            button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [button setTitle:@"上传" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:kALLBUTTON_COLOR];
            if (self.canEditFlag && ![bean.displaymode isEqualToString:@"1"]) {
                [button addTarget:self action:@selector(uploadFileAction:) forControlEvents:UIControlEventTouchUpInside];
                if ([bean.displaymode isEqualToString:@"3"]) {
                    button.must = @"1";
                }
            }
            if (bean.fieldname.length >0 && value.length >0){
                frame=CGRectMake(20,CGRectGetMaxY(frame)+2,self.viewWidth -108,30);
                
                NSArray *array = [value componentsSeparatedByString:@","];
                NSString *fileName = bean.fileName;
                
                NSArray *files = [fileName componentsSeparatedByString:@","];
                
                if (array.count == files.count){
                    
                    for (int c=0;c<array.count;c++) {
                        NSString *filename = files.count >0?files[c]:@"";
                        NSString *fileid = array[c];
                        
                        UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        fujianButton.frame = frame;
                        fujianButton.value = fileid;
                        fujianButton.Id = filename;
                        fujianButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
                        fujianButton.titleLabel.textAlignment = NSTextAlignmentLeft;
                        fujianButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                        [fujianButton setTitle:filename forState:UIControlStateNormal];
                        [fujianButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [fujianButton setBackgroundColor:[UIColor whiteColor]];
                        [fujianButton addTarget:self action:@selector(fujianPreviewerAction:) forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:fujianButton];
                        
                        if (self.canEditFlag) {
                            CGRect frame2=CGRectMake(self.viewWidth-80,CGRectGetMinY(fujianButton.frame)+5,60,26);
                            UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
                            delButton.frame = frame2;
                            delButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
                            delButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                            [delButton setTitle:@"删除" forState:UIControlStateNormal];
                            [delButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                            [delButton setBackgroundColor:[UIColor whiteColor]];
                            [delButton addTarget:self action:@selector(delAction:) forControlEvents:UIControlEventTouchUpInside];
                            delButton.tag = tag+900;
                            [view addSubview:delButton];
                            delButton.layer.borderColor = [UIColor redColor].CGColor;
                            delButton.layer.borderWidth = .5;
                            delButton.layer.cornerRadius = 5;
                            delButton.value = fileid;
                            delButton.Id = filename;
                            delButton.newValue = bean.Id;
                            delButton.fieldname = bean.fieldname;
                        }
                        
                        if (c < array.count-1) {
                            frame.origin.y = CGRectGetMaxY(frame)+5;
                        }
                    }
                }
                
                CGRect tmpFrame = view.frame;
                tmpFrame.size.height = CGRectGetMaxY(frame)+5*array.count;
                view.frame = tmpFrame;
                
            }
            
            [view addSubview:button];
            [viewsArray addObject:button];
        }
        
        if ([fieldType isEqualToString:kTableField]) {
            frame=CGRectMake(87,10,self.viewWidth -100,34);
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.font = [UIFont fontWithName:kFontName size:14];
            bLabel.frame = frame;
            bLabel.tag = tag;
            bLabel.text = @"点击查看详情";
            bLabel.fieldType = fieldType;
            bLabel.Id = bean.labelname;
            bLabel.pulldownData= bean.fileData;
            bLabel.tablename = bean.tablename;
            bLabel.textAlignment = NSTextAlignmentCenter;
            
            if ([bean.displaymode isEqualToString:@"3"]) {
                bLabel.must = @"1";
                bLabel.labelname = bean.labelname;
            }
            
            bLabel.backgroundColor = RGB(230, 233, 238);
            bLabel.layer.cornerRadius = 6;
            [bLabel.layer setMasksToBounds:YES];
            
            //增加点击事件
            bLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *firstDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableAction:)];
            [bLabel addGestureRecognizer:firstDtapGesture];
            
            [view addSubview:bLabel];
        }
        
        //        #define kUploadFileField @"uploadFileField" //可选上传附件
    }
    
    return view;
}

- (NSString *)findId:(UILabel *)view{
    
    NSDictionary *info=nil;
    for (NSDictionary *dic in view.pulldownData) {
        for (NSString *keyStr in dic.allKeys) {
            NSString *value = dic[keyStr];
            NSString *title=view.text;
            if ([view.fieldname containsString:@"bumen"]) {
                title=[NSString stringWithFormat:@"/%@",title];
            }
            //            NSLog(@"view.text:%@ value:%@",title,value);
            if ([title isEqualToString:value]) {
                info = dic;
                break;
            }
        }
    }
    
    NSString *findId=nil;
    for (NSString *keyStr in info) {
        NSString *value = info[keyStr];
        NSString *title=view.text;
        if ([view.fieldname containsString:@"bumen"]) {
            title=[NSString stringWithFormat:@"/%@",title];
        }
        if (![title isEqualToString:value]) {
            findId = value;
            break;
        }
    }
    
    return findId;
}

- (NSString *)findId_dx:(UILabel *)view{
    
    NSMutableArray *infoArray=[NSMutableArray array];
    NSArray *titleArray=[view.text componentsSeparatedByString:@","];
    for (NSUInteger i=0;i<titleArray.count;i++) {
        NSString *title=titleArray[i];
        for (NSDictionary *dic in view.pulldownData) {
            for (NSString *keyStr in dic.allKeys) {
                NSString *value = dic[keyStr];
                if ([title isEqualToString:value]) {
                    [infoArray addObject:dic];
                    break;
                }
            }
        }
    }
    
    NSString *findId=nil;
    for (NSUInteger i=0;i<infoArray.count;i++) {
        NSDictionary *info = infoArray[i];
        NSString *processid = info[@"processid"];
        if (i==0) {
            findId = processid;
        }else{
            findId = [NSString stringWithFormat:@"%@,%@",findId,processid];
        }
    }
    
    return findId;
    
}



- (void)initAddButton{

    if (!([optlevel isEqual:@(2)] || [rejectable isEqual:@(1)])){
        return;
    }
    
    addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addButton.frame = CGRectMake(self.viewWidth-50,self.viewHeight-50, 40, 40);
    
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.backgroundColor = kALLBUTTON_COLOR;
    
    addButton.layer.borderWidth = 1;
    addButton.layer.borderColor = kALLBUTTON_COLOR.CGColor;
    addButton.layer.cornerRadius = addButton.bounds.size.width/2;
    
    addButton.layer.shadowColor=[UIColor blackColor].CGColor;
    addButton.layer.shadowOffset=CGSizeMake(1, 1);
    addButton.layer.shadowOpacity=0.5;
    addButton.layer.shadowRadius=1;
    
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
    
    //    favoriteButton = [[UIBarButtonItem alloc] initWithTitle:@"关注"
    //                                                      style:UIBarButtonItemStylePlain
    //                                                     target:self
    //                                                     action:@selector(favoriteAction:)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL res = YES;
    
    if (textField.keyboardType == UIKeyboardTypeDecimalPad) {
        
        // allow backspace
        if (range.length > 0 && [string length] == 0) {
            return YES;
        }
        // 不许小数点开头
        if (range.location == 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        
        NSString *currentText = textField.text;  // currentField指的是当前确定的那个输入框
        if ([string isEqualToString:@"."]&& [currentText rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
            
        }else if([string isEqualToString:@"."]&& [currentText rangeOfString:@"." options:NSBackwardsSearch].length== 1) {
            string = @"";
            //alreay has a decimal point
        }
        
        NSRange range1 = {0,0};
        range1 = [currentText rangeOfString:@"."];
        if (range1.length ==1 && (range.location - range1.location) >2) {
            return NO;//小数位数只能是2位
        }
        
        NSString *newValue = [currentText stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
        textField.text = newValue;
        textField.value = newValue;
        
        return NO;
    }
    
    return res;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.keyboardType == UIKeyboardTypeDecimalPad) {
        NSRange range={0,0};
        NSString *currentText = textField.text;
        BOOL flag = [currentText containsString:@"."];
        if (flag) {
            range = [currentText rangeOfString:@"."];
            if (range.location == currentText.length-1) {
                textField.text = [NSString stringWithFormat:@"%@0",currentText];
            }
            
            if (range.location == 0) {
                textField.text = [NSString stringWithFormat:@"0%@",currentText];
            }
        }else{
            if (currentText.length == 0) {
                currentText = @"0";
            }
            textField.text = [NSString stringWithFormat:@"%@.0",currentText];
        }
    }
    
    textField.value = textField.text;
    
    //    for (int i=0;i<viewsArray.count;i++) {
    //        UIView *view = viewsArray[i];
    //        if ([view.labelname isEqualToString:textField.labelname]) {
    //            [viewsArray replaceObjectAtIndex:i withObject:textField];
    //        }
    //    }
}


- (void)labelAction:(UITapGestureRecognizer *)sender{
    [self testExpansionFlag];
    
    UILabel *bLabel = (UILabel *)sender.view;
    
    if ([bLabel.fieldType isEqualToString:kSelectListField]){
        
        [self selectList:bLabel];
    }
    
    if ([bLabel.fieldType isEqualToString:kSingleListField] || [bLabel.fieldType isEqualToString:kMoreListField]) {
        [self listField:bLabel];
    }
    
    if ([bLabel.fieldType isEqualToString:kDateField] || [bLabel.fieldType isEqualToString:kTimeField]){
        [self selectDateAndTime:bLabel];
    }
    
}

#pragma mark 选择下拉列表
- (void)selectList:(UILabel *)label {
    
    if (label.pulldownData.count <=0) {
        [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
        return;
    }
    NSMutableArray *name = [NSMutableArray array];
    NSDictionary *dic = label.pulldownData[0];
    NSString *keyV= nil;
    NSString *idKey= nil;
    for (NSString *key in dic.allKeys){
        if ([key containsString:@"name"]){
            keyV=key;
            break;
        }else{
            idKey =key;
        }
    }
    
    if (!keyV) {
        return;
    }
    
    for (NSDictionary *dic in label.pulldownData){
        [name addObject:dic[keyV]];
    }
    if (name.count <=0) {
        return;
    }
    [_ddList reloadData:name];
    [_ddList setDDListHidden:NO];
    
    [_ddList setDefectsTypeBlock:^(NSString *deviceName) {
        label.text = deviceName;
        for (NSDictionary *dic in label.pulldownData){
            if ([dic[keyV] isEqualToString:deviceName]){
                label.value = dic[idKey];
                break;
            }
        }
    }];
}

- (void)listField:(UILabel *)label{
    //     NSLog(@"label.bemulti:%@ label.browserid:%@ label.datatype:%@",label.bemulti,label.browserid,label.datatype);
    if ([label.datatype isEqualToString:@"6"] || [label.datatype isEqualToString:@"11"]) {
        NSArray *defaultDepts = [label.text componentsSeparatedByString:@","];
        TreeDeptViewController *treeDeptViewController = [TreeDeptViewController new];
        treeDeptViewController.defaultDepts = defaultDepts;
        treeDeptViewController.isRadioFlag = [label.fieldType isEqualToString:kSingleListField];
        [treeDeptViewController setTreeDeptBlock:^(NSArray *ids, NSArray *names) {
            label.text = [names componentsJoinedByString:@","];
            label.value = [ids componentsJoinedByString:@","];
        }];
        [self.navigationController pushViewController:treeDeptViewController animated:YES];
        return;
    }
    
    NSString *serviceIPInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressHttps];
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.WfprocessAction?action=getbrowser&id=%@",serviceIPInfo,label.browserid];
    NSURL *url = [NSURL URLWithString:serviceStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] ==1){
            
            NSMutableArray *name = [NSMutableArray array];
            NSMutableArray *processid = [NSMutableArray array];
            
            NSArray *fileData = dic[@"fileData"];
            for (int i=0;i<fileData.count;i++) {
                NSDictionary *info = fileData[i];
                [name addObject:info[@"name"]];
                [processid addObject:info[@"processid"]];
            }
            if (name.count <=0) {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
                return;
            }
            
            if ([label.fieldType isEqualToString:kSingleListField]) {
                NSString *title = [NSString stringWithFormat:@"请选择%@",label.viewListTitle];
                LeveyPopListView *listVew = [[LeveyPopListView alloc] initWithTitle:title options:name];
                listVew.label = label;
                listVew.nameArray = name;
                listVew.processidArray = processid;
                listVew.delegate = self;
                [listVew showInView:self.view.window animated:YES];
            }
            
            if ([label.fieldType isEqualToString:kMoreListField]) {
                NSArray *info = [label.text componentsSeparatedByString:@","];
                NSString *title = [NSString stringWithFormat:@"请选择%@",label.viewListTitle];
                RichLeveyPopListView *richPopView = [[RichLeveyPopListView alloc] initWithTitle:title options:name choosed:info];
                richPopView.label = label;
                richPopView.nameArray = name;
                richPopView.processidArray = processid;
                richPopView.delegate = self;
                [richPopView showInView:self.view.window animated:YES];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:ShareAppDelegate.window];
        
    }];
    
    [request startAsynchronous];
    
}

#pragma mark 选择日期和时间
- (void)selectDateAndTime:(UILabel *)label {
    
    [self testExpansionFlag];
    
    NSString *title = nil;
    UIDatePicker *picer = [[UIDatePicker alloc] init];
    if ([label.fieldType isEqualToString:kDateField]) {
        picer.datePickerMode = UIDatePickerModeDate;
        title = @"请选择日期：年月日\n\n\n\n\n\n\n\n\n\n\n\n";
    }else{
        picer.datePickerMode = UIDatePickerModeTime;
        title = @"请选择时间：时分\n\n\n\n\n\n\n\n\n\n\n\n";
    }
    
    picer.frame = CGRectMake(-20, 40, 320, 200);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSDate *date = picer.date;
        if ([label.fieldType isEqualToString:kDateField]) {
            label.text = [date stringWithFormat:@"yyyy-MM-dd"];
            label.value = [date stringWithFormat:@"yyyy-MM-dd"];
        }else{
            label.text = [date stringWithFormat:@"HH:mm"];
            label.value = [date stringWithFormat:@"HH:mm"];
        }
    }];
    [alertController.view addSubview:picer];
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)tableAction:(UITapGestureRecognizer *)sender{
    
    __weak UILabel *label = (UILabel *)sender.view;
    
    if (label.pulldownData.count <=0) {
        [MBProgressHUD showError:@"没有显示数据" toView:ShareAppDelegate.window];
        return;
    }
    
    NSMutableArray *info=[NSMutableArray array];
    for (int i=0;i<formfieldsArray.count;i++) {
        FormFieldsBean *bean=formfieldsArray[i];
        if ([bean.formid isEqualToString:label.tablename]) {
            [info addObject:bean];
            //            NSLog(@"id:%@ tablename:%@ fileData:%@",bean.Id,label.Id,bean.fileData);
        }
    }
    
    if (info.count<=0) {//detailforms
        [MBProgressHUD showError:@"没有显示数据" toView:ShareAppDelegate.window];
        return;
    }
    
    AppendixDetailsViewController *appendixDetailsViewController = [[AppendixDetailsViewController alloc] initData:label.pulldownData];
    appendixDetailsViewController.title = label.Id;
    appendixDetailsViewController.formFields = info;
    appendixDetailsViewController.canEditFlag = self.canEditFlag;
    [appendixDetailsViewController setSuccessReturnBlock:^(id object) {
        if (!tableDictionary) {
            tableDictionary = [NSMutableDictionary dictionary];
        }
        
        NSMutableArray *newInfo = [NSMutableArray array];
        for(NSDictionary *info in object){
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            for (NSString *keyStr in info.allKeys) {
                if (![keyStr isEqualToString:@"id"]) {
                    NSString *newKey =  [keyStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",label.tablename] withString:@""];
                    [data setObject:info[keyStr] forKey:newKey];
                }else{
                    [data setObject:info[keyStr] forKey:keyStr];
                }
            }
            
            [newInfo addObject:data];
            
        }
        
        [tableDictionary setObject:newInfo forKey:label.tablename];
        
    }];
    
    [self.navigationController pushViewController:appendixDetailsViewController animated:YES];
    
}

- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedValue:(NSString *)value {
    UILabel *tempLabel = popListView.label;
    tempLabel.text = value;
    
    NSInteger index = [popListView.nameArray indexOfObject:value];
    tempLabel.value = popListView.processidArray[index];
    
}

- (void)RichLeveyPopListView:(RichLeveyPopListView *)popListView clickOK:(NSArray*)res{
    
    NSString *nameStr=nil;
    NSString *valueStr=nil;
    for(int i=0;i<res.count;i++){
        nameStr = res[i];
        NSInteger index = [popListView.nameArray indexOfObject:nameStr];
        NSString *value = popListView.processidArray[index];
        if (i==0){
            valueStr = value;
        }else{
            valueStr = [NSString stringWithFormat:@"%@,%@",valueStr,value];
        }
    }
    
    popListView.label.value = valueStr;
    popListView.label.text = [res componentsJoinedByString:@","];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if (![touches containsObject:_ddList]) {
        [self testExpansionFlag];
    }
}


- (void)testExpansionFlag{
    if ( _ddList.isExpansionFlag) {
        [_ddList setDDListHidden:YES];
    }
}

- (void)uploadFileAction:(UIButton *)sender{
    
    UploadImageFileViewController *uploadImageFileViewController = [UploadImageFileViewController new];
    uploadImageFileViewController.imageArrays = imageArrays;
    uploadImageFileViewController.imageFileIds = imageFileIds;
    [uploadImageFileViewController setResultImageBlock:^(NSArray *fileIds,NSArray *images) {
        imageFileIds = [NSArray arrayWithArray:fileIds];
        imageArrays = [NSArray arrayWithArray:images];
        if (!sender.value) {
            sender.value = [fileIds componentsJoinedByString:@","];
        }else{
            sender.newValue = [fileIds componentsJoinedByString:@","];
        }
        [sender setTitle:[NSString stringWithFormat:@"有%@张照片",@(fileIds.count)] forState:UIControlStateNormal];
    }];
    [self.navigationController pushViewController:uploadImageFileViewController animated:YES];
    
}


- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv{
    
    cbv.value = [NSString stringWithFormat:@"%d", cbv.checked];
    
}

#pragma mark 增加按钮事件
- (void)addButtonAction:(UIButton *)sender{
    
    for (UIView *view in viewsArray) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            view.value = textField.text;
        }
        if ([view.must isEqualToString:@"1"] && view.value.length ==0){
            NSString *title = [NSString stringWithFormat:@"%@:必须有值",view.labelname];
            [MBProgressHUD showError:title toView:ShareAppDelegate.window];
            return;
        }
    }
    
    NSString *buttonTitle=nil;
    NSString *rejectbutton=nil;
    NSInteger index = 0;
    if ([rejectable integerValue]==1) {
        rejectbutton=@"驳回";
        index=kRejectSheetTag;
    }
    
    if ([optlevel integerValue]==2) {
        buttonTitle=@"通过";
        index=kPassSheetTag;
    }
    
    if (buttonTitle == nil && rejectbutton == nil) {
        return;
    }
    
    if (buttonTitle && rejectbutton) {
        index=kAllSheetTag;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:buttonTitle
                                  otherButtonTitles:rejectbutton,nil];
    actionSheet.tag = index;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *title;
    NSString *action;
    if (actionSheet.tag==kPassSheetTag) {
        title=@"通过签字";
        action=@"submit";
    }
    
    if (actionSheet.tag==kRejectSheetTag) {
        title=@"驳回签字";
        action=@"reject";
    }
    
    if (actionSheet.tag==kAllSheetTag && buttonIndex ==0) {
        title=@"通过签字";
        action=@"submit";
    }
    
    if (actionSheet.tag==kAllSheetTag && buttonIndex ==1) {
        title=@"驳回签字";
        action=@"reject";
    }
    
    if (action.length ==0) {
        return;
    }
    
    NSString *maintable = mainformDictionary[@"tablename"];
    if (maintable.length ==0) {
        return;
    }
    
    //    NSLog(@"mainformDictionary:%@",mainformDictionary);
    NSMutableDictionary *info=[NSMutableDictionary dictionary];
    for (UIView *view in viewsArray) {
        if (view.value && view.fieldname) {
            NSString *value = view.value;
            if (view.newValue) {
                value = [NSString stringWithFormat:@"%@,%@",value,view.newValue];
            }
            [info setObject:value forKey:view.fieldname];
        }
    }
    
    if (info.count <=0) {
        return;
    }
    
    SignViewController *signViewController=[SignViewController new];
    signViewController.title = title;
    signViewController.info = info;
    signViewController.action = action;
    signViewController.processid = self.processid;
    signViewController.maintable = maintable;
    signViewController.rejecttonode = rejecttonode;
    
    //    id tables = @"{\"detailtables\":{}}";
    //    if (tableDictionary.count>0) {
    //        tables = tableDictionary;
    //    }
    signViewController.tables = tableDictionary;
    [signViewController setSuccessRefreshViewBlock:^{
        self.canEditFlag = NO;
        [addButton setHidden:YES];
        self.block();
        [self backAction];
    }];
    [self.navigationController pushViewController:signViewController animated:YES];
}

- (void)flowChartAction:(id)sender{
    
    FlowChartViewController *flowChartViewController = [FlowChartViewController new];
    flowChartViewController.processid = self.processid;
    flowChartViewController.currentnode = self.currentnode;
    [self.navigationController pushViewController:flowChartViewController animated:YES];
    
}

#pragma mark 流程日志事件
- (void)reportAction:(id)sender{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSString *serviceStr = [NSString stringWithFormat:kURL_ReportInstructions,self.serviceIPInfo,self.processid,self.currentnode];
    serviceStr = [serviceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *info in result) {
                //                NSDictionary *attachments = info[@"attachments"];
                //                NSString *attachmentsUrls = attachments[@"attachmentsUrl"];
                WorkReportBean *bean = [WorkReportBean new];
                bean.attachments = info[@"attachments"];
                bean.datatime = info[@"datatime"];
                bean.dept = info[@"dept"];
                bean.filename = info[@"filename"];
                bean.leader = info[@"leader"];
                bean.operator_ = info[@"operator"];
                bean.opertype = info[@"opertype"];
                bean.point = info[@"point"];
                bean.message = info[@"message"];
                [array addObject:bean];
            }
            
            if (array.count >0) {
                
                NSArray *resultArray = [array sortedArrayUsingComparator:^NSComparisonResult(WorkReportBean *obj1, WorkReportBean *obj2) {
                    
                    NSDateFormatter *df =[NSDateFormatter new];
                    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSDate *date1 = [df dateFromString:obj1.datatime];
                    NSDate *date2 = [df dateFromString:obj2.datatime];
                    
                    NSComparisonResult result = [date1 compare:date2];
                    
                    return result == NSOrderedDescending; // 升序
                    //                    return result == NSOrderedAscending;  // 降序
                }];
                
                WorkReportViewController *workReportViewController = [WorkReportViewController new];
                workReportViewController.data = [NSMutableArray arrayWithArray:resultArray];
                [self.navigationController pushViewController:workReportViewController animated:YES];
            }else{
                [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
            }
            
        }else{
            [MBProgressHUD showError:@"没有数据！！" toView:self.view.window];
        }
    }];
    
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
        self.markLabel.hidden=YES;
        
    }];
    
    [request startAsynchronous];
    
}

- (void)setSuccessRefreshViewBlock:(SuccessRefreshViewBlock) block{
    self.block=block;
}


- (UIImage*)createImageWithColor:(UIColor*)color{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)textFieldDidChange:(NSNotification *)obj{
    
    UITextField * textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    
    // 键盘输入模式(判断输入模式的方法是iOS7以后用到的,如果想做兼容,另外谷歌)
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode * current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            NSRange range={0,0};
            BOOL flag = [toBeString containsString:@"."];
            if (flag) {
                range = [toBeString rangeOfString:@"."];
            }
            NSString *front = [toBeString substringToIndex:range.location];
            if (front.length >0){
                NSString *behind = [toBeString substringFromIndex:range.location+1];
                
                if (behind.length > 2) {
                    behind = [behind substringToIndex:2];
                    textField.text = [NSString stringWithFormat:@"%@.%@",front,behind];
                    //此方法是我引入的第三方警告框.读者可以自己完成警告弹窗.
                }
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    //    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    //    else{
    //        if (toBeString.length > 3) {
    //            textField.text = [toBeString substringToIndex:3];
    //
    //        }
    //    }
    
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
    NSString *urlStr = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",self.serviceIPInfo,fileId];
    
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

- (void)delAction:(UIButton *)sender{
    
    [self keepInputValue];
    
    NSInteger tag = sender.tag - 900;
    NSInteger index = tag/100;
    
    FormFieldsBean *bean = formfieldsArray[index];
    NSString *value = mainformDictionary[bean.Id];
    value = [self removeStringValue:value delValue:sender.value];
    
    NSString *fileName = bean.fieldname;
    fileName = [self removeStringValue:fileName delValue:sender.Id];
    bean.fieldname = fileName;
    
    [formfieldsArray replaceObjectAtIndex:index withObject:bean];
    [mainformDictionary setValue:value forKey:bean.Id];
    [self setUIWithAnimation:NO];
    
    NSString *folderPath = [self createFolderPath];
    NSString *path=[folderPath stringByAppendingPathComponent:sender.fieldname];
    [dirArray removeObject:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (NSString *)removeStringValue:(NSString *)value delValue:(NSString *)delValue{
    NSArray *tempValue = [value componentsSeparatedByString:@","];
    NSMutableArray *values = [NSMutableArray arrayWithArray:tempValue];
    [values removeObject:delValue];
    if (values.count >0) {
        value = [values componentsJoinedByString:@","];
    }else{
        value = @"";
    }
    
    return value;
}

#pragma mark 删除时，保持主表单数据
- (void)keepInputValue{
    for (UIView *view in viewsArray) {
        if (view.value && view.fieldname) {
            
            for (int i=0;i<formfieldsArray.count;i++){
                FormFieldsBean *bean = formfieldsArray[i];
                if ([view.Id isEqualToString:bean.Id]) {
                    
                    if ([view.fieldType isEqualToString:kSingleListField]||
                        [view.fieldType isEqualToString:kMoreListField] ||
                        [view.fieldType isEqualToString:kSelectListField]) {
                        UILabel *tempLabel = (UILabel *)view;
                        
                        [mainformDictionary setValue:tempLabel.text forKey:bean.Id];
                        [mainformDictionary setValue:view.value forKey:[NSString stringWithFormat:@"%@_id",bean.Id]];
                        
                    }else{
                        [mainformDictionary setValue:view.value forKey:bean.Id];
                        
                    }
                }
            }
        }
    }
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

- (void)favoriteAction:(UIButton *)sender{
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    
    NSString *processid = self.processid;
    NSString *tablename = mainformDictionary[@"tablename"];
    NSNumber *type = @((self.type==1)?self.type:2);//1工作台;其它type=2;
    //增加关注
    NSString *urlStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.FavoritesAction?action=AddFavorites&processid=%@&type=%@&tablename=%@",self.serviceIPInfo,processid,type,tablename];
    
    //    favorite字段，true处于关注中，false没有关注
    if (isFavorite) {
        //取消关注
        urlStr =  [NSString stringWithFormat:@"%@/ext/com.cinsea.action.FavoritesAction?action=DeleteFavoriteById&processid=%@",self.serviceIPInfo,processid];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    [self setCookie:url];
    __weak ASIHTTPRequest *weakRequest = request;
    
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] ==1){
            isFavorite=!isFavorite;
            //1工作台;其它type=2;
            if (self.type == 1){
                self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注"];
                if (isNotify) {
                    self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注",@"提交"];
                }
            }else{
                self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注",@"流程日志",@"流程状态"];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"处理请求失败" toView:ShareAppDelegate.window];
    }];
    
    [request startSynchronous ];
    
}

- (void)btnAddAction:(id)sender{
    
    if (formfieldsArray.count ==0) {
        [MBProgressHUD showError:@"没有数据，不能操作" toView:ShareAppDelegate.window];
        return;
    }
    
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.15;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
    
}

#pragma mark - Local methods
- (void)initiateMenuOptions {
    CGSize size = {40,40};
    UIImage *image1 = [UIImage imageNamed:@"close"];
    image1 = [self imageByScalingAndCroppingForSourceImage:image1 targetSize:size];
    UIImage *image2 = [self drawRoundWith:@"注" size:size fillColor:nil];
    
    //1工作台;其它type=2;
    if (self.type == 1){
        self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注"];
        if (isNotify)
            self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注",@"提交"];
        UIImage *image3 = [self drawRoundWith:@"提" size:size fillColor:nil];
        self.menuIcons = @[image1,image2,image3];
        
    }else{
        self.menuTitles = @[@"",isFavorite?@"取消关注":@"关注",@"流程日志",@"流程状态"];
        
        UIImage *image3 = [self drawRoundWith:@"日" size:size fillColor:nil];
        UIImage *image4 = [self drawRoundWith:@"状" size:size fillColor:nil];
        
        self.menuIcons = @[image1,image2,image3,image4];
        
    }
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 1://关注
            [self favoriteAction:nil];
            break;
        case 2:{
            if (self.type == 1) {
                //工作台提交
                [self workbenchCommitAction];
            }else{
                //流程日志
                [self reportAction:nil];
            }
            break;
        }
        case 3://流程状态
        {
            ProcessStatusViewController *processStatusViewController = ProcessStatusViewController.new;
            processStatusViewController.title = @"流程状态";
            processStatusViewController.processid = self.processid;
            processStatusViewController.workflowid = workflowid;
            [self.navigationController pushViewController:processStatusViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark 工作台中的提交
- (void)workbenchCommitAction{
    
    for (UIView *view in viewsArray) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            view.value = textField.text;
        }
        if ([view.must isEqualToString:@"1"] && view.value.length ==0){
            NSString *title = [NSString stringWithFormat:@"%@:必须有值",view.labelname];
            [MBProgressHUD showError:title toView:ShareAppDelegate.window];
            return;
        }
    }
    
    NSMutableDictionary *info=[NSMutableDictionary dictionary];
    for (UIView *view in viewsArray) {
        if (view.value && view.fieldname) {
            NSString *value = view.value;
            if (view.newValue) {
                value = [NSString stringWithFormat:@"%@,%@",value,view.newValue];
            }
            [info setObject:value forKey:view.fieldname];
        }
    }
    
    
    NSString *subDetails = @"{\"detailtables\":{}}";
    
    NSString *json=[self toJSONWithObject:info];
    
    NSString *maintable = mainformDictionary[@"tablename"];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/ext/com.cinsea.action.ProcessAction?action=submit&id=%@&maintable=%@&subDetails=%@&jsonStr=%@",self.serviceIPInfo,self.processid,maintable,subDetails,json];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
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
    
}


@end
