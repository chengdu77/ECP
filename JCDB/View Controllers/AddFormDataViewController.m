//
//  AddFormDataViewController.m
//  JCDB
//
//  Created by WangJincai on 16/3/30.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "AddFormDataViewController.h"
#import "UIView+BindValues.h"
#import "IQTextView.h"
#import "SSCheckBoxView.h"
#import "FormFieldsBean.h"
#import "NSDate+Helper.h"
#import "RichLeveyPopListView.h"
#import "LeveyPopListView.h"
#import "DeviceViewController.h"
#import "ASIFormDataRequest.h"

#import "MyQLPreviewController.h"
#import "UploadImageFileViewController.h"
#import <QuickLook/QuickLook.h>
#import "MRNavigationBarProgressView.h"

#import "TreeDeptViewController.h"


@implementation MyFormFieldsBean
@end

@implementation AddFormDataBean


#pragma mark copying协议的方法
// 这里创建的副本对象不要求释放
- (id)copyWithZone:(NSZone *)zone {
    AddFormDataBean *copy = [[[self class] allocWithZone:zone] init];
    // 拷贝名字给副本对象
    copy.dowid = [_dowid copy];
    copy.formfields = [_formfields copy];
    copy.formid = [_formid copy];
    copy.objname = [_objname copy];
    copy.type = [_type copy];
    copy.subtables = [_subtables copy];
    
    return copy;
}

@end

@interface AddFormDataViewController ()<UITextFieldDelegate,LeveyPopListViewDelegate,RichLeveyPopListViewDelegate,UIActionSheetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>{
    
    NSMutableArray *formfieldsArray;
    NSMutableArray *viewsArray;
    NSDictionary *mainformDictionary;
    
    NSMutableArray *dirArray;
    
    NSString *filePath;
    NSArray *imageFileIds;
    NSArray *imageArrays;
    
    NSMutableDictionary *subtablesInfos;
    NSString *strSubtables;//子表单初始数据
    NSArray *subtables;//主表单中子表单数据，子表单上的数据为nil；
}

@end

@implementation AddFormDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewsArray = [NSMutableArray array];
    subtablesInfos = [NSMutableDictionary dictionary];
    self.canEditFlag = YES;
 
    UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"提交"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(commitAction:)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:commitButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    
    [self setUIWithAnimation:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setInfoBean:(AddFormDataBean *)infoBean{
   
    _infoBean = [infoBean copy];
    if (formfieldsArray.count >0) {
        [formfieldsArray removeLastObject];
    }else{
        formfieldsArray = [NSMutableArray array];
    }
    
    for (NSDictionary *info in infoBean.formfields) {
        MyFormFieldsBean *bean = [MyFormFieldsBean new];
       
        bean.defaultvalue = info[@"defaultvalue"];
//        NSLog(@"info allkey:%@",info.allKeys);
//        NSLog(@"displayvalue:%@ displayvalue:%@",info[@"displayvalue"],[info objectForKey:@"displayvalue"]);
        bean.displayvalue = info[@"displayvalue"];//显示默认值
        bean.displaymode = [NSString stringWithFormat:@"%@",info[@"displaymode"]];//1表示disable；3表示必输
        bean.fileData = info[@"fileData"];
        bean.bemulti = [NSString stringWithFormat:@"%@",info[@"bemulti"]?info[@"bemulti"]:@""];
        
        NSDictionary *formfield = info[@"formfield"];
//        bean.bedefault = formfield[@"bedefault"];
//        bean.bemoney = formfield[@"bemoney"];
//        bean.beunique = formfield[@"beunique"];
        bean.browserid = [NSString stringWithFormat:@"%@",info[@"browserid"]];
//        bean.dataproperty = formfield[@"dataproperty"];
        bean.datatype = [NSString stringWithFormat:@"%@",formfield[@"datatype"]];
//        bean.deleted = formfield[@"deleted"];
        bean.displaytype = [NSString stringWithFormat:@"%@",formfield[@"displaytype"]];
//        bean.divcolspan = formfield[@"divcolspan"];
//        bean.divorder = formfield[@"divorder"];
//        bean.divsrow = formfield[@"divsrow"];
//        bean.docsavedir = formfield[@"docsavedir"];
        bean.fieldname = formfield[@"fieldname"];
//        bean.formdiv = formfield[@"formdiv"];
        bean.formid = formfield[@"formid"];
        bean.Id = formfield[@"id"];
        
        NSString *labelname = [NSString stringWithFormat:@"%@",formfield[@"labelname"]];
        if ([bean.displaymode isEqualToString:@"3"]) {
            labelname = [NSString stringWithFormat:@"%@*",labelname];
        }
        bean.labelname = labelname;
//        bean.logged = formfield[@"logged"];
//        bean.prompt = formfield[@"prompt"];
//        bean.validateexpr = formfield[@"validateexpr"];
        
        [formfieldsArray addObject:bean];
    }
    
    if (!self.isSelfFlag && _infoBean.subtables) {
        strSubtables = [self toJSONWithObject:_infoBean.subtables];
        subtables = [self getSubtableData];
    }
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
        MyFormFieldsBean *bean = formfieldsArray[i];
        NSString *returnInputType = [self getInputType:bean.displaytype datatype:bean.datatype displaymode:bean.displaymode];
        NSString *title = bean.labelname;
        
        if (!title) {
            continue;
        }
        
        UIView *view = [self addViewFrame:frame tag:1000+100*i bean:bean fieldType:returnInputType];
        if (!view) {
            continue;
        }
        
        
        [self.scrollView addSubview:view];
        frame = view.frame;
        frame.origin.y =CGRectGetMaxY(frame) +5;
    }
    
    for (int i =0;i<subtables.count;i++) {
        AddFormDataBean *bean = subtables[i];
       
        UIView *subView = [self addSubViewFrame:frame title:bean.objname tag:12200+i];
        
        [self.scrollView addSubview:subView];
        frame = subView.frame;
        if (i < subtables.count -1) {
            frame.origin.y =CGRectGetMaxY(frame) +5;
        }
    }

    frame.size.height =CGRectGetMaxY(frame);
    [self.scrollView setContentSize:frame.size];
    
    if (hasAnimation){
        [UIView commitAnimations];
    }
}

- (UIView *)addSubViewFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag{
    
    UIView *view = [UIView new];
    
    CGRect r=frame;
    
    frame.size.height = 34;
    view.frame = frame;
    frame=CGRectMake(8,10,82,34);
    
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.frame = frame;
    aLabel.font = [UIFont fontWithName:kFontName size:14];
    aLabel.text = title;
    aLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:aLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.viewWidth -80,10,60,30);
    button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:kALLBUTTON_COLOR];
    [button addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [view addSubview:button];
    [viewsArray addObject:button];
    
    NSInteger index = tag -12200;//表示表单序号

    NSArray *array = [subtablesInfos objectForKey:@(index)];
    frame = CGRectMake(0,CGRectGetMaxY(button.frame)+10,self.viewWidth, 0);
    for (int w=0;w<array.count;w++) {
        NSString *display = array[w][@"display"];
        UIView *detailView = [self addViewWithFrame:frame title:display tag:tag index:w];
        [view addSubview:detailView];
        frame = detailView.frame;
        
        if (w<array.count-1) {
            CGRect rect = CGRectMake(10,CGRectGetMaxY(frame)+5,self.viewWidth - 20,1);
            UIView *lineView = [[UIView alloc] initWithFrame:rect];
            lineView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
            [view addSubview:lineView];
            frame.origin.y =CGRectGetMaxY(rect) +10;
        }
    }
    
    if (array.count >0) {
        r.size.height = CGRectGetMaxY(frame) +5;
        view.frame = r;
    }

    return view;
}

- (UIView *)addViewFrame:(CGRect)frame tag:(int)tag bean:(MyFormFieldsBean *)bean fieldType:(NSString *)fieldType {
    
    NSString *value = bean.displayvalue;
    if (self.isSelfFlag && value.length == 0) {
        value = bean.defaultvalue;
    }
    
    UIView *view = [UIView new];
    view.tag = tag;
    
    frame.size.height = [fieldType isEqualToString:kTextField]?kTextFieldHeight:kEditTextFieldHeight;
    view.frame = frame;
    frame=CGRectMake(8,10,82,40);
    
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.font = [UIFont fontWithName:kFontName size:14];
    aLabel.text = bean.labelname;
    aLabel.textAlignment = NSTextAlignmentLeft;
    aLabel.numberOfLines = 0;
    CGSize size = CGSizeMake(82,200);
    CGSize labelsize = [aLabel sizeThatFits:size];
    [aLabel setFrame:CGRectMake(8,10,82,labelsize.height)];
    
    [view addSubview:aLabel];
    
    if ([bean.displaymode isEqualToString:@"3"]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:bean.labelname];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(str.length-1,1)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontNameB size:17] range:NSMakeRange(str.length-1,1)];
        aLabel.attributedText = str;
    }else{
        aLabel.text = bean.labelname;
    }
    
    if ([fieldType isEqualToString:kEditTextField] ||[fieldType isEqualToString:kTextField] ||[fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField] ||[fieldType isEqualToString:kDateField]  ||[fieldType isEqualToString:kTimeField] || [fieldType isEqualToString:kSelectListField]) {
        
        frame=CGRectMake(87,10,self.viewWidth -100,[fieldType isEqualToString:kTextField]?kTextFieldHeight:kEditTextFieldHeight);
        if ([fieldType isEqualToString:kEditTextField] ||[fieldType isEqualToString:kTextField]) {
            UITextField *textField = [[UITextField alloc] init];
            textField.font = [UIFont fontWithName:kFontName size:14];
            textField.frame = frame;
            textField.text = value;
            textField.value = value;
            textField.tag = tag;
            textField.fieldType = fieldType;
            textField.Id = bean.Id;
            
            //小数
            if ([bean.datatype isEqualToString:@"3"]) {
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }
            //整数
            if ([bean.datatype isEqualToString:@"2"]){
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }
            
            textField.labelname = bean.labelname;
            textField.backgroundColor = [UIColor whiteColor];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.delegate = self;
            if ([bean.displaymode isEqualToString:@"3"]) {
                textField.must = @"1";
                textField.placeholder = @"必填";
            }
            
            textField.userInteractionEnabled = ((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag);
            if (((![bean.displaymode isEqualToString:@"1"]) && self.canEditFlag)) {
                textField.placeholder = [NSString stringWithFormat:@"请输入%@",bean.labelname];
            }
            textField.text = bean.displayvalue;
            
            textField.layer.borderColor = kALLBUTTON_COLOR.CGColor;
            textField.layer.borderWidth = .5;
            textField.layer.cornerRadius = 6;
            [textField.layer setMasksToBounds:YES];
            
            [view addSubview:textField];
            [viewsArray addObject:textField];
        }else{
            UILabel *bLabel = [[UILabel alloc] init];
            bLabel.font = [UIFont fontWithName:kFontName size:14];
            bLabel.frame = frame;
            aLabel.tag = tag;
            bLabel.text = value;
            bLabel.value = value;
            bLabel.fieldType = fieldType;
            bLabel.Id = bean.Id;
            bLabel.bemulti = bean.bemulti;
            bLabel.textAlignment = NSTextAlignmentCenter;
            bLabel.labelname = bean.labelname;
            bLabel.fieldname = bean.fieldname;
            bLabel.browserid = bean.browserid;
            bLabel.datatype = bean.datatype;
            
            if ([bean.displaymode isEqualToString:@"3"]) {
                bLabel.must = @"1";
            }
            bLabel.text = value?value:@"请点击";

            if (([fieldType isEqualToString:kSelectListField] ||[fieldType isEqualToString:kSingleListField] || [fieldType isEqualToString:kMoreListField]) && self.canEditFlag ) {
                bLabel.pulldownData = bean.fileData;
                
                if (bean.defaultvalue.length >0) {
                    bLabel.value = bean.defaultvalue;
                }else{
                    bLabel.value = [self findId:bLabel];
                }
                
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
                bLabel.layer.borderColor = kBackgroundColor.CGColor;
                bLabel.layer.borderWidth = .5;
                bLabel.layer.cornerRadius = 6;
                [bLabel.layer setMasksToBounds:YES];
                
                
                if (self.canEditFlag && ![bean.displaymode isEqualToString:@"1"]) {
                    //增加点击事件
                    bLabel.userInteractionEnabled = YES;
                    UITapGestureRecognizer *firstDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction:)];
                    [bLabel addGestureRecognizer:firstDtapGesture];
                }
            }
            
            bLabel.text = bean.displayvalue;
            
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
            if (self.canEditFlag && ![bean.displaymode isEqualToString:@"1"]) {
                [cbv setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
                
                if ([bean.displaymode isEqualToString:@"3"]) {
                    cbv.must = @"1";
                }
            }
            cbv.labelname = bean.labelname;
            cbv.checked=[value boolValue];
            cbv.value = value;
            [view addSubview:cbv];
            [viewsArray addObject:cbv];
        }
        
        if ([fieldType isEqualToString:kUploadFileField]) {
            
            frame=CGRectMake(self.viewWidth -100,10,80,30);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.frame = frame;
            
            button.tag = tag;
            button.fieldType = fieldType;
            button.Id = bean.Id;
            button.value = value;
            button.labelname = bean.labelname;
         
            button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            NSString *title = @"上传";
            if (imageArrays.count >0) {
                title =[NSString stringWithFormat:@"有%@张照片",@(imageArrays.count)];
            }
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:kALLBUTTON_COLOR];
            if (self.canEditFlag  && ![bean.displaymode isEqualToString:@"1"]) {
                [button addTarget:self action:@selector(uploadFileAction:) forControlEvents:UIControlEventTouchUpInside];
        
                if ([bean.displaymode isEqualToString:@"3"]) {
                    button.must = @"1";
                }
            }
            
//            if (bean.fileName.length >0 && value.length >0){
//                frame=CGRectMake(20,CGRectGetMaxY(frame)+2,self.viewWidth -108,30);
//                
//                UIButton *fujianButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                fujianButton.frame = frame;
//                fujianButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
//                fujianButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//                fujianButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                [fujianButton setTitle:bean.fileName forState:UIControlStateNormal];
//                [fujianButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                [fujianButton setBackgroundColor:[UIColor whiteColor]];
//                [fujianButton addTarget:self action:@selector(fujianPreviewerAction:) forControlEvents:UIControlEventTouchUpInside];
//                [view addSubview:fujianButton];
//                
//                frame=CGRectMake(self.viewWidth-80,CGRectGetMinY(fujianButton.frame)+5,60,26);
//                UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                delButton.frame = frame;
//                delButton.titleLabel.font = [UIFont fontWithName:kFontName size:14];
//                delButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                [delButton setTitle:@"删除" forState:UIControlStateNormal];
//                [delButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//                [delButton setBackgroundColor:[UIColor whiteColor]];
//                [delButton addTarget:self action:@selector(delAction:) forControlEvents:UIControlEventTouchUpInside];
//                delButton.tag = tag+900;
//                [view addSubview:delButton];
//                delButton.layer.borderColor = [UIColor redColor].CGColor;
//                delButton.layer.borderWidth = .5;
//                delButton.layer.cornerRadius = 5;
//                
//                CGRect tmpFrame = view.frame;
//                tmpFrame.size.height += CGRectGetHeight(frame);
//                view.frame = tmpFrame;
//            }
            
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
            
            bLabel.backgroundColor = RGB(230, 233, 238);
            bLabel.layer.cornerRadius = 6;
            [bLabel.layer setMasksToBounds:YES];
            
            //增加点击事件
            if ( ![bean.displaymode isEqualToString:@"1"]) {
                bLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *firstDtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableAction:)];
                [bLabel addGestureRecognizer:firstDtapGesture];
            }
            
            [view addSubview:bLabel];
        }
        
        //        #define kUploadFileField @"uploadFileField" //可选上传附件
    }
    
    return view;
}

- (NSString *)findId:(UILabel *)view{
    
    if ([view.Id containsString:@"rydx"] || [view.Id containsString:@"bumenduoxuan"] ) {
        return [self findId_dx:view];
    }
    
    NSDictionary *info=nil;
    for (NSDictionary *dic in view.pulldownData) {
        for (NSString *keyStr in dic.allKeys) {
            NSString *value = dic[keyStr];
            NSString *title=view.text;
            if ([view.Id containsString:@"bumen"]) {
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
        if ([view.Id containsString:@"bumen"]) {
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
    
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] init];
    deviceViewController.infos = name;
//    deviceViewController.title = label.text;
    [self.navigationController pushViewController:deviceViewController animated:YES];
    
    [deviceViewController setDeviceTypeBlock:^(NSInteger deviceId, NSString *deviceName) {
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
//    NSLog(@"label.bemulti:%@ label.browserid:%@ label.datatype:%@",label.bemulti,label.browserid,label.datatype);
    //部门
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

    //人员
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

#pragma mark 选择日期和时间
- (void)selectDateAndTime:(UILabel *)label {
    
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
        
        __block UILabel *tempLabel = label;
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSDate *date = picer.date;
            if ([tempLabel.fieldType isEqualToString:kDateField]) {
                tempLabel.text = [date stringWithFormat:@"yyyy-MM-dd"];
                tempLabel.value = [date stringWithFormat:@"yyyy-MM-dd"];
            }else{
                tempLabel.text = [date stringWithFormat:@"HH:mm"];
                tempLabel.value = [date stringWithFormat:@"HH:mm"];
            }
        }];
        [alertController.view addSubview:picer];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
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
 
    for (int i=0;i<viewsArray.count;i++) {
        UIView *view = viewsArray[i];
        if ([view.labelname isEqualToString:textField.labelname]) {
            [viewsArray replaceObjectAtIndex:i withObject:textField];
        }
    }
}
- (void)textFieldDidChange:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    NSRange range={0,0};
    NSString *currentText = textField.text;
    BOOL flag = [currentText containsString:@"."];
    if (flag) {
        range = [currentText rangeOfString:@"."];
        if (range.location == currentText.length) {
            textField.text = [NSString stringWithFormat:@"%@00",currentText];
        }
    }
   
    return;
//    UITextField * textField = (UITextField *)obj.object;
//    NSString *toBeString = textField.text;
//    
//    // 键盘输入模式(判断输入模式的方法是iOS7以后用到的,如果想做兼容,另外谷歌)
//    NSArray *currentar = [UITextInputMode activeInputModes];
//    UITextInputMode * current = [currentar firstObject];
//    
//    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
//        UITextRange *selectedRange = [textField markedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position) {
//            
//            NSRange range={0,0};
//            BOOL flag = [toBeString containsString:@"."];
//            if (flag) {
//                range = [toBeString rangeOfString:@"."];
//            }
//            //            if (range.length == 1 && range.location == 0 && toBeString.length >3) {
//            //                textField.text = [toBeString substringToIndex:3];
//            //                return;
//            //            }
//            NSString *front = [toBeString substringToIndex:range.location];
//            if (front.length >0){
//                NSString *behind = [toBeString substringFromIndex:range.location+1];
//                
//                if (behind.length > 2) {
//                    behind = [behind substringToIndex:2];
//                    textField.text = [NSString stringWithFormat:@"%@.%@",front,behind];
//                    //此方法是我引入的第三方警告框.读者可以自己完成警告弹窗.
//                }
//            }
//        }
//        // 有高亮选择的字符串，则暂不对文字进行统计和限制
//        else{
//            
//        }
//    }
//    //    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//    //    else{
////            if (toBeString.length > 3) {
////                textField.text = [toBeString substringToIndex:3];
////    
////            }
//    //    }
//    
}

- (void)labelAction:(UITapGestureRecognizer *)sender{
  
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

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv{
    
    cbv.value = [NSString stringWithFormat:@"%d", cbv.checked];
    
}

- (void)uploadFileAction:(UIButton *)sender{
    
    UploadImageFileViewController *uploadImageFileViewController = [UploadImageFileViewController new];
    uploadImageFileViewController.imageArrays = imageArrays;
    uploadImageFileViewController.imageFileIds = imageFileIds;
    [uploadImageFileViewController setResultImageBlock:^(NSArray *fileIds,NSArray *images) {
        imageFileIds = [NSArray arrayWithArray:fileIds];
        imageArrays = [NSArray arrayWithArray:images];
        sender.value = [fileIds componentsJoinedByString:@","];
        [sender setTitle:[NSString stringWithFormat:@"有%@张照片",@(fileIds.count)] forState:UIControlStateNormal];

    }];
    [self.navigationController pushViewController:uploadImageFileViewController animated:YES];
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
    
    for (int i=0;i<viewsArray.count;i++) {
        UIView *view = viewsArray[i];
        if ([view isEqual:popListView.label]){
            [viewsArray replaceObjectAtIndex:i withObject:view];
            break;
        }
    }
}

- (void)commitAction:(id)sender{
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    int ct=0;
    NSString *displayValue;
    for (UIView *view in viewsArray) {
        
        if (view.value && view.Id) {
            NSString *value = view.value;
            if (view.newValue) {
                value = [NSString stringWithFormat:@"%@,%@",value,view.newValue];
            }
            [info setObject:value forKey:view.Id];
            
            if (self.isSelfFlag){
                for (NSMutableDictionary *data in _infoBean.formfields) {
                    NSMutableDictionary *formfield = data[@"formfield"];
//                     NSLog(@"view.value:%@ view.Id:%@",view.value,view.Id);
                    if ([formfield[@"id"] isEqual:view.Id]){
                        [data setObject:value forKey:@"defaultvalue"];
                        
                        if ([view.fieldType isEqualToString:kSingleListField]||
                            [view.fieldType isEqualToString:kMoreListField] ||
                            [view.fieldType isEqualToString:kSelectListField]) {
                            UILabel *tempLabel = (UILabel *)view;
                            [data setObject:tempLabel.text forKey:@"displayValue"];
                        }
                    }
                }
                
                NSString *tempValue = view.value;
                if ([view.fieldType isEqualToString:kSingleListField]||
                    [view.fieldType isEqualToString:kMoreListField] ||
                    [view.fieldType isEqualToString:kSelectListField]) {
                    UILabel *tempLabel = (UILabel *)view;
                    tempValue = tempLabel.text;
                }
                
                if ([view.fieldType isEqualToString:kUploadFileField] && tempValue.length >0) {
                    tempValue = @"有上传图片";
                }
                
                if (tempValue.length == 0) {
                    continue;
                }
                
                if (ct==0) {
                    displayValue = [NSString stringWithFormat:@"%@:%@",view.labelname,tempValue];
                }else{
                    displayValue = [NSString stringWithFormat:@"%@\n%@:%@",displayValue,view.labelname,tempValue];
                }
                ct++;
            }
        }
       
        if ([view.must isEqualToString:@"1"] && !view.value){
            NSString *title = [NSString stringWithFormat:@"%@:必须有值",view.labelname];
            [MBProgressHUD showError:title toView:ShareAppDelegate.window];
            return;
        }
    }
    
    //工作台过来的数据需要提交处理
//    if (self.type == 1) {
////         [info setObject:[self uuid] forKey:@"id"];
//        [self workStationCommit:info];
//        return;
//    }
    
    if (self.isSelfFlag) {
        if (displayValue.length > 0) {
            [info setObject:[self uuid] forKey:@"id"];
            self.block(info,displayValue,_infoBean,imageArrays,imageFileIds,viewsArray);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:info,@"maintable",@{},@"detailtables",nil];
    
    if (subtablesInfos.count >0 || self.type == 1) {
        
        NSMutableDictionary *subs = [NSMutableDictionary dictionary];
        for (NSString *key in subtablesInfos.allKeys) {
            NSArray *arary = subtablesInfos[key];
            
            for (NSDictionary *dic in arary) {
                AddFormDataBean *bean = dic[@"bean"];
                NSMutableArray *tArray = subs[bean.formid];
                if (!tArray) {
                    tArray = [NSMutableArray array];
                }
                NSDictionary *d = dic[@"info"];
                [tArray addObject:d];
                [subs setObject:tArray forKey:bean.formid];
            }
        }
        
        data = [NSDictionary dictionaryWithObjectsAndKeys:info,@"maintable",subs,@"detailtables",nil];
        
        NSString *str = [self toJSONWithObject:data];
        
        NSString *postURL = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.FormAction",self.serviceIPInfo];
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:postURL]];
        [request addPostValue:@"createformdata" forKey:@"action"];
        
        [request addPostValue:str forKey:@"datas"];
        [request addPostValue:_infoBean.dowid forKey:@"dowid"];
        [request addPostValue:_infoBean.type forKey:@"type"];
        
        __block ASIFormDataRequest *weakRequest = request;
        [request setCompletionBlock:^{
            [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
            
            NSError *err=nil;
            NSData *responseData = [weakRequest responseData];
//            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
//            NSLog(@"responseString:%@",responseString);
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
            
            if ([dic[@"success"] integerValue] ==1){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
            }
        }];
        
        [request setFailedBlock:^{
            [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
            
            [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
            
        }];
        
        [request startSynchronous];
        
        
    }
    else{
    
    NSString *json=[self toJSONWithObject:data];
    NSString *urlStr = [NSString stringWithFormat:kURL_AddCommitData,self.serviceIPInfo,json,_infoBean.dowid,_infoBean.type];
//    http://123.57.205.36:8080/ext/com.cinsea.action.FormAction?action=createformdata&datas={"maintable":{"ut_demo_xingming":"ddd"},"detailtables":{}}&dowid=297e9e7950cb02a50150d1aed505010b&type=2
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] ==1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:ShareAppDelegate.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
        
        [MBProgressHUD showError:@"网络不给力" toView:ShareAppDelegate.window];
        
    }];
    
    [request startAsynchronous];
        
    }
}

- (void)tableAction:(id)sender{
    
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
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL :url];
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
    
    NSInteger tag = sender.tag - 900;
    NSInteger index = tag/100;
    
    FormFieldsBean *bean = formfieldsArray[index];
    bean.fieldname = @"";
    [formfieldsArray replaceObjectAtIndex:index withObject:bean];
    [mainformDictionary setValue:@"" forKey:bean.Id];
    [self setUIWithAnimation:NO];
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

- (void)addButtonAction:(UIButton *)sender{
    
    [self keepInputValue];
    
    NSUInteger index = sender.tag -12200;
    NSArray *tempArray = [self getSubtableData];
    __block __typeof(AddFormDataBean *)weakBean = tempArray[index];
    
    if (weakBean.formfields.count >0) {
        AddFormDataViewController *addFormDataViewController = [[AddFormDataViewController alloc] init];
        addFormDataViewController.isSelfFlag = YES;
        addFormDataViewController.infoBean = weakBean;
        addFormDataViewController.title = weakBean.objname;
        [addFormDataViewController setReturnDataBlock:^(NSDictionary *info,NSString *displayValue,id bn,NSArray *images,NSArray *imageFiles,NSArray *viewSArray) {

            NSUInteger tag = sender.tag -12200;
            
            AddFormDataBean *myBean = [self replaceObjectWith:viewSArray bean:bn];
            NSArray *array = [subtablesInfos objectForKey:@(tag)];
            NSMutableArray *tArray = [NSMutableArray arrayWithArray:array?array:@[]];
            
            [tArray addObject:@{@"info":info,@"display":displayValue,@"bean":bn,@"images":images?images:@[],@"files":imageFiles?imageFiles:@[]}];
            
           [subtablesInfos setObject:tArray forKey:@(tag)];
            
            weakBean = myBean;
        
            [self setUIWithAnimation:NO];
//            for (NSMutableDictionary *info in b.formfields) {
//                NSLog(@"--info:%@",info);
//                
//            }
        }];
        [self.navigationController pushViewController:addFormDataViewController animated:YES];
    }
}

- (void)setReturnDataBlock:(ReturnDataBlock)block{
    self.block = block;
}

- (UIView *)addViewWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag index:(NSInteger)index{
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 120)];
    tempLabel.font = [UIFont fontWithName:kFontName size:14];
    tempLabel.numberOfLines = 0;
    tempLabel.text = title;
    CGSize size = CGSizeMake(self.viewWidth,2000);
    CGSize labelsize = [tempLabel sizeThatFits:size];
    [tempLabel setFrame:CGRectMake(5,5,200, labelsize.height)];
    [view addSubview:tempLabel];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [deleteButton setBackgroundColor:[UIColor redColor]];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.frame = CGRectMake(self.viewWidth -80,(labelsize.height -30)/2,60,30);
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
    deleteButton.layer.borderColor = [UIColor redColor].CGColor;
    deleteButton.layer.borderWidth = .5;
    deleteButton.layer.cornerRadius = 5;
    deleteButton.value = [NSString stringWithFormat:@"%@",@(index)];
    deleteButton.Id = [NSString stringWithFormat:@"%@",@(tag)];
    [view addSubview:deleteButton];
    
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editAction:)];
    [view addGestureRecognizer:viewTapGesture];
    view.value = [NSString stringWithFormat:@"%@",@(index)];
    view.Id = [NSString stringWithFormat:@"%@",@(tag)];
    
    frame.size.height =labelsize.height +5;
    view.frame = frame;
    
    return view;
}

- (void)deleteButtonClicked:(UIButton *)sender{
    
    [self keepInputValue];
    
    NSInteger tag = [sender.Id integerValue] -12200;
    NSInteger index = [sender.value integerValue];
    
    NSArray *array = [subtablesInfos objectForKey:@(tag)];
    NSMutableArray *tArray = [NSMutableArray arrayWithArray:array];
    if (array.count >0) {
        [tArray removeObjectAtIndex:index];
        [subtablesInfos setObject:tArray forKey:@(tag)];
    }
   
    [self setUIWithAnimation:NO];
}

- (void)editAction:(UITapGestureRecognizer *)sender{
    
    [self keepInputValue];
    
    NSInteger tag = [sender.view.Id integerValue] -12200;
    NSInteger index = [sender.view.value integerValue];
    
    NSMutableArray *array = [subtablesInfos objectForKey:@(tag)];
    NSMutableDictionary *info = array[index];
    NSArray *subImageArray = info[@"images"];
    NSArray *subImageFileId = info[@"files"];

    __block AddFormDataBean *bean = info[@"bean"];
    
    
    if (bean.formfields.count >0) {
        AddFormDataViewController *addFormDataViewController = [AddFormDataViewController new];
        addFormDataViewController.isSelfFlag = YES;
        addFormDataViewController.infoBean = bean;
        addFormDataViewController.title = bean.objname;
        addFormDataViewController.subImageArrays = subImageArray;
        addFormDataViewController.subImageFileIds = subImageFileId;
        [addFormDataViewController setReturnDataBlock:^(NSDictionary *info,NSString *displayValue,id bean,NSArray *images,NSArray *imageFiles,NSArray *viewSArray) {
         
            NSInteger tag = [sender.view.Id integerValue] -12200;
            NSInteger index = [sender.view.value integerValue];
            
            [self replaceObjectWith:viewSArray bean:bean];
            
            NSMutableArray *tArray = [subtablesInfos objectForKey:@(tag)];
//            NSMutableArray *tArray = [NSMutableArray arrayWithArray:array_];
            NSDictionary *dic = @{@"info":info,@"display":displayValue,@"bean":bean,@"images":images?images:@[],@"files":imageFiles?imageFiles:@[]};
            [tArray replaceObjectAtIndex:index withObject:dic];
       
            [subtablesInfos setObject:tArray forKey:@(tag)];
            
            [self setUIWithAnimation:NO];
        }];
        [self.navigationController pushViewController:addFormDataViewController animated:YES];
    }
    
}

- (void)setSubImageFileIds:(NSArray *)subImageFileIds{
    if (self.isSelfFlag){
        imageFileIds = subImageFileIds;
    }
}

- (void)setSubImageArrays:(NSArray *)subImageArrays{
    
    if (self.isSelfFlag){
        imageArrays = subImageArrays;
    }
}

- (AddFormDataBean *)replaceObjectWith:(NSArray *)_viewArray bean:(AddFormDataBean *)bean{
    
    AddFormDataBean *myBean = [bean copy];
    for (UIView *view in _viewArray) {
        if (view.value && view.Id) {
            for (NSMutableDictionary *fields in [myBean.formfields mutableCopy]){
                NSDictionary *data = fields[@"formfield"];
                if ([data[@"id"] isEqualToString:view.Id])
                {
                    if ([view.fieldType isEqualToString:kSingleListField]||
                        [view.fieldType isEqualToString:kMoreListField] ||
                        [view.fieldType isEqualToString:kSelectListField]) {
                        UILabel *tempLabel = (UILabel *)view;
                        [fields setObject:tempLabel.text forKey:@"displayvalue"];
                    }else{
                        if (![view.fieldType isEqualToString:kUploadFileField]) {
                            [fields setObject:view.value forKey:@"displayvalue"];
                        }
                    }
                }
            }
        }
    }
    
    return myBean;
}

- (NSArray *)getSubtableData{
    
    NSData *data =[strSubtables dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *info in content) {
        AddFormDataBean *bean = [AddFormDataBean new];
        bean.dowid = info[@"dowid"];
        bean.objname = info[@"objname"];
        bean.formfields = info[@"formfields"];
        bean.formid = info[@"formid"];
        bean.type = info[@"type"];
        [tempArray addObject:bean];
    }
    
    return tempArray;
}
#pragma mark 增加子表单时，保持主表单数据
- (void)keepInputValue{
    for (UIView *view in viewsArray) {
        if (view.value && view.Id) {
//            NSLog(@"view.value:%@ view.Id:%@",view.value,view.Id);
            for (int i=0;i<formfieldsArray.count;i++){
                MyFormFieldsBean *bean = formfieldsArray[i];
                if ([view.Id isEqualToString:bean.Id]) {
                    
                    NSString *tempValue = view.value;
                    
                    if ([view.fieldType isEqualToString:kSingleListField]||
                        [view.fieldType isEqualToString:kMoreListField] ||
                        [view.fieldType isEqualToString:kSelectListField]) {
                        UILabel *tempLabel = (UILabel *)view;
                        bean.defaultvalue = tempValue;
                        tempValue = tempLabel.text;
                    }
                    
                     bean.displayvalue = tempValue;
                    [formfieldsArray replaceObjectAtIndex:i withObject:bean];
                }
            }
        }
    }
}

@end
