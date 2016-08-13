//
//  TreeTableView.h
//  TreeTableView
//
//  Created by yixiang on 15/7/3.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Node;

@protocol TreeTableCellDelegate <NSObject>

-(void)cellClick : (Node *)node;

@end

@interface TreeTableView : UITableView

@property (nonatomic,weak) id<TreeTableCellDelegate> treeTableCellDelegate;
@property (nonatomic,assign) BOOL isRadioFlag;//YES表示单选，NO表示多选

- (instancetype)initWithFrame:(CGRect)frame withData:(NSMutableArray *)data;

@end
