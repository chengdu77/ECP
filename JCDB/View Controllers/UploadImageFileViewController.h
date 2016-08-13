//
//  UploadImageFileViewController.h
//  JCDB
//
//  Created by WangJincai on 16/4/28.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"


typedef void (^ResultImageBlock)(NSArray *fileIds,NSArray *images);

@interface UploadImageFileViewController : HeadViewController

@property (nonatomic,strong) NSArray *imageFileIds;
@property (nonatomic,strong) NSArray *imageArrays;
@property (nonatomic,copy) ResultImageBlock block;

- (void)setResultImageBlock:(ResultImageBlock)block;

@end
