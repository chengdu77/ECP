//
//  Node.m
//  TreeTableView
//
//  Created by yixiang on 15/7/3.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)initWithParentId : (NSInteger)parentId nodeId : (NSInteger)nodeId name : (NSString *)name depth : (NSInteger)depth expand : (BOOL)expand Id:(NSString *)Id leaf:(BOOL)leaf checked:(BOOL)checked{
    self = [self init];
    if (self) {
        self.parentId = parentId;
        self.nodeId = nodeId;
        self.name = name;
        self.depth = depth;
        self.expand = expand;
        self.Id = Id;
        self.leaf = leaf;
        self.checked = checked;
    }
    return self;
}

@end
