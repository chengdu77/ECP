//
//  AppendixDetailsViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/8.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "AppendixDetailsViewController.h"
#import "MRNavigationBarProgressView.h"
#import "UIView+BindValues.h"
#import "NSData+Base64.h"
#import "ASIFormDataRequest.h"
#import "FormFieldsBean.h"
#import "DDList.h"
#import "LeveyPopListView.h"
#import "RichLeveyPopListView.h"
#import "IQTextView.h"
#import "SSCheckBoxView.h"
#import "NSDate+Helper.h"

#import "MyQLPreviewController.h"
#import "UploadImageFileViewController.h"
#import "TreeDeptViewController.h"

#define kFileDownLoad @"下载"
#define kFilePreview @"查看"

#define kDDListViewTag 900
#define kDDListTag 800

#define kFujianViewTag 700


@interface AppendixDetailsViewController ()<UITextFieldDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate,LeveyPopListViewDelegate,RichLeveyPopListViewDelegate>{
    NSMutableArray *dataArray;
    NSMutableArray *dirArray;
    NSMutableArray *viewsArray;
    NSMutableArray *imageArrays;
    NSMutableArray *imageFileIds;
    
    NSMutableArray *ddListArray;
    
}

@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@end

@implementation AppendixDetailsViewController

- (id)initData:(NSArray *)arr {
    self = [super init];
    if (self) {
        dataArray = [NSMutableArray arrayWithArray:arr];
        viewsArray = [NSMutableArray array];
        ddListArray = [NSMutableArray array];
        imageArrays = [NSMutableArray array];
        imageFileIds = [NSMutableArray array];
       
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.canEditFlag)
        [self showRightBarButtonItemWithTitle:@"确认" target:self action:@selector(submitAction:)];
    
    for (int i=0;i<dataArray.count;i++) {
        DDList *_ddList = [[DDList alloc] initWithStyle:UITableViewStylePlain];

        _ddList.view.tag = kDDListViewTag+i;
        
        [ddListArray addObject:_ddList];
        
        [viewsArray addObject:[NSMutableArray array]];
        [imageArrays addObject:[NSMutableArray array]];
        [imageFileIds addObject:[NSMutableArray array]];
    }
    
     [self setUI];
    
    for (int i=0;i<ddListArray.count;i++) {
        DDList *_ddList = ddListArray[i];
    
        [self.scrollView addSubview:_ddList.view];
        [_ddList setDDListHidden:YES];
    
    }
    
//    self.navigationController.progressView.progressTintColor = [UIColor redColor];
//     [[MRNavigationBarProgressView progressViewForNavigationController:self.navigationController] setProgress:0.8000011 animated:YES];
    
//    [self downloadFileAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (UIView *)addViewFrame:(CGRect)frame tag:(int)tag bean:(FormFieldsBean *)bean fieldType:(NSString *)fieldType index:(NSInteger)index {
    
    CGRect rect = frame;
    NSString *value = dataArray[index][bean.Id];
    NSString *fileName = dataArray[index][@"filedName"];
    
    UIView *view = [UIView new];
    view.tag = tag;
    
    rect.size.height = 34;
    view.frame = rect;
    rect = CGRectMake(8,10,82,40);
    
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
        
        rect=CGRectMake(87,10,self.viewWidth -110,34);
        if ([fieldType isEqualToString:kEditTextField]) {
            UITextField *textField = [[UITextField alloc] init];
            textField.font = [UIFont fontWithName:kFontName size:14];
            textField.frame = rect;
            textField.text = value;
            textField.value = value;
//            textField.tag = tag;
            textField.fieldType = fieldType;
            textField.Id = bean.Id;
            textField.fieldname = bean.fieldname;
            
            //小数
            if ([bean.datatype isEqualToString:@"3"]) {
                textField.keyboardType = UIKeyboardTypeDecimalPad;
                
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
            }
            //整数
            if ([bean.datatype isEqualToString:@"2"]){
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }
            
            textField.labelname = bean.labelname;
            textField.backgroundColor = [UIColor whiteColor];
            textField.textAlignment = NSTextAlignmentCenter;
            
            if ([bean.displaymode isEqualToString:@"3"]) {
                textField.must = @"1";
                textField.placeholder =@"必填";
            }
            
            textField.delegate = self;
            textField.userInteractionEnabled = ((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag);
            if (((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag)) {
                textField.placeholder = @"可输入修改";
            }
            
            textField.layer.borderColor = kALLBUTTON_COLOR.CGColor;
            textField.layer.borderWidth = .5;
            textField.layer.cornerRadius = 6;
            [textField.layer setMasksToBounds:YES];
            
            [view addSubview:textField];
            [viewsArray[index] addObject:textField];
        }else{
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.font = [UIFont fontWithName:kFontName size:14];
            bLabel.frame = rect;
            if ([fieldType isEqualToString:kSelectListField]) {
               bLabel.tag = kDDListTag+index;
            }
            bLabel.text = value;
            bLabel.value = value;
            bLabel.fieldType = fieldType;
            bLabel.Id = bean.Id;
            bLabel.fieldname = bean.fieldname;
            bLabel.bemulti = bean.bemulti;
            bLabel.textAlignment = NSTextAlignmentCenter;
            bLabel.browserid = bean.browserid;
            bLabel.datatype = bean.datatype;
            
            if (([fieldType isEqualToString:kSelectListField] ||[fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField]) && self.canEditFlag ) {
                bLabel.pulldownData = bean.fileData;
                bLabel.value = [self findId:bLabel];
                
                if ([fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ) {
                    bLabel.viewListTitle = bean.labelname;
                    UIImageView *tmepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_edit_search"]];
                    tmepImageView.frame = CGRectMake(CGRectGetWidth(rect)-20, (CGRectGetHeight(rect)-18)/2, 18, 18);
                    [bLabel addSubview:tmepImageView];
                }
            }
            
            if ([fieldType isEqualToString:kSelectListField]) {
                UIImageView *tmepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_spinner_arror"]];
                tmepImageView.frame = CGRectMake(CGRectGetWidth(rect)-20, (CGRectGetHeight(rect)-18)/2, 18, 18);
                [bLabel addSubview:tmepImageView];
            }
            
            if ([fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ||[fieldType isEqualToString:kDateField]  ||[fieldType isEqualToString:kTimeField] || [fieldType isEqualToString:kSelectListField]) {
                
//                bLabel.backgroundColor = RGB(230, 233, 238);
                bLabel.layer.borderColor = kBackgroundColor.CGColor;
                bLabel.layer.borderWidth = .5;
                bLabel.layer.cornerRadius = 6;
                [bLabel.layer setMasksToBounds:YES];
            
                if (self.canEditFlag) {
                    //增加点击事件
                    bLabel.userInteractionEnabled = YES;
                    UITapGestureRecognizer *firstDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction:)];
                    [bLabel addGestureRecognizer:firstDtapGesture];
                    
                    bLabel.labelname = bean.labelname;
                    if ([bean.displaymode isEqualToString:@"3"]) {
                        bLabel.must = @"1";
                    }
                }
            }
            
            [view addSubview:bLabel];
            [viewsArray[index] addObject:bLabel];
        }
        
    }else{
        
        if ([fieldType isEqualToString:kCheckboxField]) {
            rect = CGRectMake(self.viewWidth -84,10,28,28);
            SSCheckBoxView *cbv =[[SSCheckBoxView alloc] initWithFrame:rect style:kSSCheckBoxViewStyleGlossy checked:NO];
            cbv.tag = tag;
            cbv.fieldType = fieldType;
            cbv.Id = bean.Id;
            cbv.fieldname = bean.fieldname;
            if (self.canEditFlag) {
                [cbv setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
            }
            cbv.checked=[value boolValue];
            cbv.value = value;
            [view addSubview:cbv];
            [viewsArray[index] addObject:cbv];
            cbv.labelname = bean.labelname;
            if ([bean.displaymode isEqualToString:@"3"]) {
                cbv.must = @"1";
            }
        }
        
        if ([fieldType isEqualToString:kUploadFileField]) {
            
            rect = CGRectMake(self.viewWidth -100,10,80,30);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = rect;
            button.tag = index;
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
                rect = CGRectMake(10,CGRectGetMaxY(rect)+5,self.viewWidth -107,26);
                
                NSArray *array = [value componentsSeparatedByString:@","];
                NSArray *files = [fileName componentsSeparatedByString:@","];
              
                for (int c =0;c<array.count;c++) {
                    NSString * filename = files[c];
                    NSString * fileid = array[c];
                    
                    UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    fujianButton.frame = rect;
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
                    
                    CGRect frame2=CGRectMake(self.viewWidth-80,CGRectGetMinY(fujianButton.frame)+5,60,26);
                    UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    delButton.frame = frame2;
                    delButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
                    delButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [delButton setTitle:@"删除" forState:UIControlStateNormal];
                    [delButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [delButton setBackgroundColor:[UIColor whiteColor]];
                    [delButton addTarget:self action:@selector(delAction:) forControlEvents:UIControlEventTouchUpInside];
                    delButton.tag = index+900;
                    [view addSubview:delButton];
                    delButton.layer.borderColor = [UIColor redColor].CGColor;
                    delButton.layer.borderWidth = .5;
                    delButton.layer.cornerRadius = 5;
                    delButton.value = fileid;
                    delButton.Id = filename;
                    delButton.newValue = bean.Id;
                    delButton.fieldname = bean.fieldname;
                    
                    if (c < array.count-1) {
                        rect.origin.y = CGRectGetMaxY(rect)+5;
                    }
                }
                
                CGRect tmpFrame = view.frame;
                tmpFrame.size.height = CGRectGetMaxY(rect)+5*array.count;
                view.frame = tmpFrame;
            }

            [view addSubview:button];
            [viewsArray[index] addObject:button];
        }
        
        //        #define kUploadFileField @"uploadFileField" //可选上传附件
    }
    
    return view;
}

- (NSString *)findId:(UILabel *)view{
    

    if ([view.fieldType isEqualToString:kMoreListField] && ![view.fieldname containsString:@"bumen"]) {
        return [self findId_dx:view];
    }
    
    NSDictionary *info=nil;
    for (NSDictionary *dic in view.pulldownData) {
        for (NSString *keyStr in dic.allKeys) {
            NSString *value = dic[keyStr];
            NSString *title=view.text;
            if ([view.fieldname containsString:@"bumen"]) {
                title=[NSString stringWithFormat:@"/%@",title];
            }
    
            if ([value hasSuffix:title]) {
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
        if (![value hasSuffix:title]) {
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

//去除字符串中间空格
- (NSString *)removeIntermediateSpace:(NSString *)theString{
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
    
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    
    return [filteredArray componentsJoinedByString:@""];
}


- (UIView *)addViewFrame:(CGRect)frame titles:(NSArray *)titles values:(NSArray *)values buttons:(NSArray *)buttons{
    
    frame.size.height = titles.count*21 +10;
    UIView *view = [[UIView alloc] init];
    view.frame = frame;
    
    for (int i =0;i<titles.count;i++) {
        frame=CGRectMake(8,5+21*i,70,21);
        NSString *title = titles[i];
        if (title) {
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.frame = frame;
            aLabel.text = title;
            aLabel.font = [UIFont systemFontOfSize:14.0];
            [view addSubview:aLabel];
        }
        
        frame=CGRectMake(78,5+21*i,self.viewWidth -120,21);
        NSString *value = values[i];
        if (value) {
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.frame = frame;
            bLabel.text = value;
            bLabel.font = [UIFont systemFontOfSize:14.0];
            [view addSubview:bLabel];
        }
        
        frame=CGRectMake(self.viewWidth -20,5+21*i,self.viewWidth -120 -CGRectGetMaxX(frame),21);
        NSString *but = buttons[i];
        //必须是待办才有权限操作附件
        if (but.length >0 && self.canEditFlag) {
            
            NSString *folderPath = [self createFolderPath];
            NSString *filePath = [folderPath stringByAppendingPathComponent:value];
            NSString *title = [self isFileExistsPath:filePath]?kFilePreview:kFileDownLoad;
            
            UIButton *btn = [self buttonForTitle:title action:@selector(buttonAction:)];
            btn.frame = frame;
            btn.Id = but;
            btn.value = value;
            btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
            [view addSubview:btn];
        }
    }
    
    //    设置边框：
    view.layer.borderColor = RGB(230, 233, 238).CGColor;
    view.layer.borderWidth = 1.0;
    view.layer.cornerRadius = 5.0;
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}

- (UIButton *)buttonForTitle:(NSString *)title action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:kALLBUTTON_COLOR forState:UIControlStateNormal];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setUI{
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
 
    CGRect frame=CGRectMake(10, 10, self.viewWidth-20, [UIScreen mainScreen].bounds.size.height-80);
    
    for (NSInteger j=0;j<dataArray.count;j++) {
        
        [viewsArray[j] removeAllObjects];
        
        for (int i=0;i<self.formFields.count;i++) {
            FormFieldsBean *bean = self.formFields[i];
            //过滤掉富文本
//            if ([bean.fieldname isEqualToString:@"fuwenben"]) {
//                continue;
//            }
            
            NSString *returnInputType = [self getInputType:bean.displaytype datatype:bean.datatype displaymode:bean.displaymode];
            
            NSString *title = dataArray[j][bean.Id];
//            NSLog(@"returnInputType:%@ title:%@",returnInputType,title);
            if (!title) {
                continue;
            }
            
            UIView *view = [self addViewFrame:frame tag:100*i bean:bean fieldType:returnInputType index:j];
            if (!view) {
                continue;
            }
            
            if ([returnInputType isEqualToString:kSelectListField]) {
                DDList *_ddList =ddListArray[j];
                [_ddList setPosition:CGPointMake(87,CGRectGetMaxY(view.frame)+12)];
            }
            
            
            [self.scrollView addSubview:view];
            frame = view.frame;
            frame.origin.y =CGRectGetMaxY(frame) +5;
        }
        //分割
        frame.origin.y +=20;
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0,frame.origin.y ,self.viewWidth,10)];
        tempView.backgroundColor = [UIColor blueColor];
        [self.scrollView addSubview:tempView];
        
        frame = tempView.frame;
        frame.origin.y =CGRectGetMaxY(frame) +5;
    }

    frame.size.height = CGRectGetMaxY(frame)-25;
    [self.scrollView setContentSize:frame.size];
}


- (void)buttonAction:(UIButton *)sender{
    
    NSString *title = sender.titleLabel.text;
    if ([title isEqualToString:kFilePreview]) {
       [self previewFilePath:sender.value Id:sender.Id];
    }
    
    if ([title isEqualToString:kFileDownLoad]) {
        [self downloadFilePath:sender.value Id:sender.Id];
    }
}


- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv{
    
    cbv.value = [NSString stringWithFormat:@"%d", cbv.checked];
    
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
        
        NSRange range1 = NSMakeRange(0, 0);
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
        NSRange range = NSMakeRange(0, 0);
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
    
}


- (void)labelAction:(UITapGestureRecognizer *)sender{
//   [self testExpansionFlag];
    
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
    
    DDList *_ddList = ddListArray[label.tag -kDDListTag];
    
    [_ddList reloadData:name];
    [_ddList setDDListHidden:NO];
    [_ddList.view bringSubviewToFront:self.scrollView];
    
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
//     NSLog(@"label.bemulti:%@ label.browserid:%@ label.Id:%@",label.bemulti,label.browserid,label.Id);
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
    __block ASIHTTPRequest *weakRequest = request;
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
    
    for (DDList *_ddList in ddListArray) {
        if (![touches containsObject:_ddList]) {
            if ( _ddList.isExpansionFlag) {
                [_ddList setDDListHidden:YES];
            }
        }
    }
    
}


- (void)testExpansionFlag{
//    if ( _ddList.isExpansionFlag) {
//        [_ddList setDDListHidden:YES];
//    }
}

- (void)uploadFileAction:(UIButton *)sender{
    
    UploadImageFileViewController *uploadImageFileViewController = [UploadImageFileViewController new];
    uploadImageFileViewController.imageArrays = imageArrays[sender.tag];
    uploadImageFileViewController.imageFileIds = imageFileIds[sender.tag];
    [uploadImageFileViewController setResultImageBlock:^(NSArray *fileIds,NSArray *images) {
        imageFileIds[sender.tag] = [NSMutableArray arrayWithArray:fileIds];
        imageArrays[sender.tag] = [NSMutableArray arrayWithArray:images];
        if (!sender.value) {
            sender.value = [fileIds componentsJoinedByString:@","];
        }else{
            sender.newValue = [fileIds componentsJoinedByString:@","];
        }
        [sender setTitle:[NSString stringWithFormat:@"有%@张照片",@(fileIds.count)] forState:UIControlStateNormal];
    }];
    [self.navigationController pushViewController:uploadImageFileViewController animated:YES];
    
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
    
    if (IOS8_OR_LATER) {
        picer.frame = CGRectMake(-20, 40, self.viewWidth, 200);
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
}
- (void)submitAction:(id)sender{
    
    for (int i=0;i<dataArray.count;i++) {
        NSArray *array = viewsArray[i];
        for (UIView *view in array) {
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
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0;i<dataArray.count;i++) {
        NSMutableArray *array = viewsArray[i];
        NSMutableDictionary *dic = dataArray[i];
        NSMutableDictionary *info=[NSMutableDictionary dictionary];
        id tempId = dic[@"id"];
        if (tempId) {
            [info setObject:dic[@"id"] forKey:@"id"];
        }
        for (UIView *view in array) {
            if (view.value.length >0 && view.Id.length >0) {
                [info setObject:view.value forKey:view.Id];
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    [dic setObject:label.text forKey:view.Id];
                }else{
                   [dic setObject:view.value forKey:view.Id];
                }
            }
            
        }
        [tempArray addObject:info];
    }
    
    //返回数据
    self.block(tempArray);
    
    [self backAction];
}

- (void)setSuccessReturnBlock:(SuccessReturnBlock) block{
    self.block=block;
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
    [request setDownloadProgressDelegate:self.navigationController.progressView];
    
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        [MBProgressHUD showError:@"下载请求失败" toView:ShareAppDelegate.window];
    }];
    
    [request startSynchronous ];
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
    
    NSInteger index = sender.tag - 900;
    
    NSString *value = dataArray[index][sender.newValue];
    value = [self removeStringValue:value delValue:sender.value];
    
    NSString *fileName = dataArray[index][@"filedName"];
    fileName = [self removeStringValue:fileName delValue:sender.Id];
    //删除附件Id
    [dataArray[index] setValue:value forKey:sender.newValue];
    //删除附件Name
    [dataArray[index] setValue:fileName forKey:@"filedName"];
    [self setUI];
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
