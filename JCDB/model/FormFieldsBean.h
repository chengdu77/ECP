//
//  FormFieldsBean.h
//  JCDB
//
//  Created by WangJincai on 16/1/5.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileData : NSObject

@property (nonatomic,strong) NSString *pid;
@property (nonatomic,strong) NSString *name;

@end

@interface DetailformsBean : NSObject
@property (nonatomic,strong) NSArray *tabledata;
@property (nonatomic,strong) NSString *tabledesc;
@property (nonatomic,strong) NSString *tablename;
@end

@interface FormFieldsBean : NSObject

@property (nonatomic,strong) NSString *Id;
@property (nonatomic,strong) NSNumber *bedefault;
@property (nonatomic,strong) NSNumber *bemoney;
@property (nonatomic,strong) NSNumber *beunique;
@property (nonatomic,strong) NSString *browserid;
@property (nonatomic,strong) NSString *dataproperty;
@property (nonatomic,strong) NSString *datatype;
@property (nonatomic,strong) NSNumber *deleted;
@property (nonatomic,strong) NSString *displaymode;
@property (nonatomic,strong) NSString *displaytype;
@property (nonatomic,strong) NSNumber *divcolspan;
@property (nonatomic,strong) NSNumber *divorder;
@property (nonatomic,strong) NSNumber *divsrow;
@property (nonatomic,strong) NSString *docsavedir;
@property (nonatomic,strong) NSString *fieldname;
@property (nonatomic,strong) NSArray *fileData;
@property (nonatomic,strong) NSString *formdiv;
@property (nonatomic,strong) NSString *formid;
@property (nonatomic,strong) NSString *labelname;
@property (nonatomic,strong) NSNumber *logged;
@property (nonatomic,strong) NSNumber *prompt;
@property (nonatomic,strong) NSString *validateexpr;
@property (nonatomic) NSString *bemulti;
@property (nonatomic,strong) NSString *tablename;
@property (nonatomic,strong) NSString *fileName;

@end

