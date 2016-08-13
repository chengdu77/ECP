//
//  SketchpadView.h
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface SketchpadView : UIView

//保存
- (UIImage *)getImageInfo;
//清屏
- (void)clearAll;

- (NSInteger)count;

@end
