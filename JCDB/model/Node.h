//
//  Node.h
//  TreeTableView
//
//  Created by yixiang on 15/7/3.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  每个节点类型
 */
@interface Node : NSObject

@property (nonatomic , assign) NSInteger parentId;//父节点的id，如果为-1表示该节点为根节点
@property (nonatomic , assign) NSInteger nodeId;//本节点的id
@property (nonatomic , strong) NSString *name;//本节点的名称
@property (nonatomic , assign) NSInteger depth;//该节点的深度
@property (nonatomic , assign) BOOL expand;//该节点是否处于展开状态
@property (nonatomic , assign) BOOL checked;//选中状态：1选中，0未选中
@property (nonatomic , strong) NSString *Id;//本节点ID
@property (nonatomic , assign) BOOL leaf;//
@property (nonatomic , assign) BOOL requested;//

/**
 *快速实例化该对象模型
 */
- (instancetype)initWithParentId:(int)parentId nodeId:(int)nodeId name:(NSString *)name depth:(int)depth expand:(BOOL)expand Id:(NSString *)Id leaf:(BOOL)leaf checked:(BOOL)checked;

@end
