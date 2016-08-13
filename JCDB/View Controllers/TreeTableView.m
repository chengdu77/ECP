//
//  TreeTableView.m
//  TreeTableView
//
//  Created by yixiang on 15/7/3.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import "TreeTableView.h"
#import "Node.h"
#import "TreeTableViewCell.h"
#import "UIView+BindValues.h"

#define kCellHeight 35

@interface TreeTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) NSMutableArray *data;//传递过来已经组织好的数据（全量数据）

@property (nonatomic , strong) NSMutableArray *expandData;//用于存储数据源（需要展开的部分数据）


@end

@implementation TreeTableView

-(instancetype)initWithFrame:(CGRect)frame withData :(NSMutableArray *)data{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.data = data;
        _expandData = [self createTempData:data];
    }
    return self;
}

/**
 * 初始化数据源
 */
-(NSMutableArray *)createTempData : (NSArray *)data{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<data.count; i++) {
        Node *node = [_data objectAtIndex:i];
        if (node.expand) {
            [tempArray addObject:node];
        }
    }
    return tempArray;
}


#pragma mark - UITableViewDataSource

#pragma mark - Required

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _expandData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *NODE_CELL_ID = @"TreeTableViewCell";
    
    TreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
    if (!cell) {
        cell = [[TreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID];
    }
    
    Node *node = [_expandData objectAtIndex:indexPath.row];
    
    cell.checkButton.frame = CGRectMake(tableView.frame.size.width -50,(kCellHeight-32)/2, 32, 32);
    cell.moreDeptImageView.frame = CGRectMake(tableView.frame.size.width -35,0, 35, 35);
    cell.moreDeptImageView.hidden = node.leaf;

    // cell有缩进的方法
    cell.indentationLevel = node.depth; //缩进级别
    cell.indentationWidth = 30.f; //每个缩进级别的距离
    
    cell.textLabel.text = node.name;
//    if (node.depth >0) {
//        CGRect frame = cell.guideImgView.frame;
//        frame.origin.x = 10 + node.depth *30.f;
//        frame.origin.y = -8;
//        cell.guideImgView.frame = frame;
//        
//    }else{
//        cell.guideImgView.image = nil;
//    }
    
    if (node.checked){
        [cell.checkButton setImage:[UIImage imageNamed:@"CheckBox1_Selected"]forState:UIControlStateNormal];
    }
    else{
        [cell.checkButton setImage:[UIImage imageNamed:@"CheckBox1_unSelected"]forState:UIControlStateNormal];
    }
    
    cell.checkButton.node = node;
    cell.checkButton.Id = [NSString stringWithFormat:@"%@",@(indexPath.row)];
    [cell.checkButton addTarget:self action:@selector(checkCliecked:) forControlEvents:UIControlEventTouchUpInside];

    if (node.depth==0) {
        cell.checkButton.hidden = (node.depth==0);
        cell.moreDeptImageView.hidden = (node.depth==0);
        
    }
    
//    cell.guideImgView.hidden = (node.depth==0);
    
    return cell;
}


#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Node *parentNode = [_expandData objectAtIndex:indexPath.row];
    
    if (!parentNode.requested && !parentNode.leaf){
    //先修改数据源
        if (_treeTableCellDelegate && [_treeTableCellDelegate respondsToSelector:@selector(cellClick:)]) {
            [_treeTableCellDelegate cellClick:parentNode];
        }
    }
    
//    NSUInteger startPosition = indexPath.row+1;
//    NSUInteger endPosition = startPosition;
//    BOOL expand = NO;
//    for (int i=0; i<_data.count; i++) {
//        Node *node = [_data objectAtIndex:i];
//        if (node.parentId == parentNode.nodeId) {
//            node.expand = !node.expand;
//            if (node.expand) {
//                [_expandData insertObject:node atIndex:endPosition];
//                expand = YES;
//                endPosition++;
//            }else{
//                expand = NO;
//                endPosition = [self removeAllNodesAtParentNode:parentNode];
//                break;
//            }
//        }
//    }
//    
//    //获得需要修正的indexPath
//    NSMutableArray *indexPathArray = [NSMutableArray array];
//    for (NSUInteger i=startPosition; i<endPosition; i++) {
//        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        [indexPathArray addObject:tempIndexPath];
//    }
//    
    //插入或者删除相关节点
//    if (expand) {
//        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
//    }else{
//        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
//    }
}

/**
 *  删除该父节点下的所有子节点（包括孙子节点）
 *
 *  @param parentNode 父节点
 *
 *  @return 该父节点下一个相邻的统一级别的节点的位置
 */
-(NSUInteger)removeAllNodesAtParentNode:(Node *)parentNode{
    NSUInteger startPosition = [_expandData indexOfObject:parentNode];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_expandData.count; i++) {
        Node *node = [_expandData objectAtIndex:i];
        endPosition++;
        if (node.depth <= parentNode.depth) {
            break;
        }
        if(endPosition == _expandData.count-1){
            endPosition++;
            node.expand = NO;
            break;
        }
        node.expand = NO;
    }
    if (endPosition>startPosition) {
        [_expandData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    return endPosition;
}


- (void)checkCliecked:(UIButton *)sender{
    
    
    Node *parentNode = sender.node;
    parentNode.checked = !parentNode.checked;
        
    NSInteger row = [sender.Id integerValue];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

@end
