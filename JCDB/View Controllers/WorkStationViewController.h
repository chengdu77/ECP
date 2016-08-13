//
//  WorkStationViewController.h
//  JCDB
//
//  Created by WangJincai on 16/4/5.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"


@interface WorkStationBean : NSObject

@property (nonatomic,strong) NSString *imgUrl;
@property (nonatomic,strong) NSString *moduleObjname;
@property (nonatomic,strong) NSString *moduleid;
@property (nonatomic,strong) NSArray *directoryForList;

@end

@interface WorkStationViewController : HeadViewController

@end
