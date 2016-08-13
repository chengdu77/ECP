//
//  AddFormDataViewController.h
//  JCDB
//
//  Created by WangJincai on 16/3/30.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"
#import "FormFieldsBean.h"

typedef void (^ReturnDataBlock)(NSDictionary *info,NSString *displayValue,id bean,NSArray *images,NSArray *imageFiles,NSArray *viewsArray);

@interface MyFormFieldsBean : FormFieldsBean
@property (nonatomic,strong) NSString *defaultvalue;
@property (nonatomic,strong) NSString *displayvalue;

@end

@interface AddFormDataBean : NSObject

@property (nonatomic) NSString *dowid;
@property (nonatomic) NSMutableArray *formfields;
@property (nonatomic) NSString *formid;
@property (nonatomic) NSString *objname;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSArray *subtables;

@end

@interface AddFormDataViewController : HeadViewController

@property (nonatomic,assign) BOOL canEditFlag;
@property (nonatomic,assign) BOOL isSelfFlag;
@property (nonatomic,copy) ReturnDataBlock block;

@property (nonatomic,strong) NSArray *subImageFileIds;
@property (nonatomic,strong) NSArray *subImageArrays;

@property (nonatomic,strong) AddFormDataBean *infoBean;

@property (nonatomic,assign) NSUInteger type;//1工作台;其它type=2;

- (void)setReturnDataBlock:(ReturnDataBlock)block;

@end
