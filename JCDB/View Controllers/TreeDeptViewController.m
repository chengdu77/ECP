//
//  TreeDeptViewController.m
//  JCDB
//
//  Created by WangJincai on 16/6/5.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "TreeDeptViewController.h"
#import "Node.h"
#import "TreeTableView.h"

@interface TreeDeptViewController ()<TreeTableCellDelegate>{
    
    NSMutableArray *deptInfoArray;
    TreeTableView *tableview;
    
    
}

@end

@implementation TreeDeptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"确认"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(commitAction:)];
    NSArray *buttonArray = [[NSArray alloc]initWithObjects:commitButton,nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    if (self.isRadioFlag) {
        self.title = @"单选部门";
    }else{
      self.title = @"多选部门";
    }
    
    [self initData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)initData{
    deptInfoArray = [NSMutableArray array];
    NSArray *deptInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDeptInfo];
    Node *node1 = [[Node alloc] initWithParentId:-1 nodeId:0 name:@"所有部门" depth:0 expand:YES Id:@"" leaf:NO checked:NO];
    [deptInfoArray addObject:node1];
    for (int i = 0;i<deptInfo.count;i++) {
        NSDictionary *info = deptInfo[i];
        NSString *name = info[@"text"];
        NSString *Id = info[@"id"];
        BOOL leaf = [info[@"leaf"] boolValue];
        BOOL checked = NO;
        if (self.defaultDepts.count >0) {
            checked = !([self.defaultDepts indexOfObject:name] == NSNotFound);
        }
        Node *node = [[Node alloc] initWithParentId:0 nodeId:i name:name depth:1 expand:YES Id:Id leaf:leaf checked:checked];
        [deptInfoArray addObject:node];
    }
    
    [self treeViewDataDisplay];
}

- (void)treeViewDataDisplay{
    
    if (tableview) {
        [tableview reloadInputViews];
    }
    tableview = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 0,self.viewWidth,self.viewHeight) withData:deptInfoArray];
    tableview.treeTableCellDelegate = self;
    tableview.isRadioFlag = self.isRadioFlag;
    [self.scrollView addSubview:tableview];
    
}

#pragma mark - TreeTableCellDelegate
-(void)cellClick:(Node *)node{
//    NSLog(@"%@----%@",node.name,@(node.nodeId));
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_DeptInfo,self.serviceIPInfo,node.Id];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    __weak Node *tempNode = node;
    [request setCompletionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        NSError *err=nil;
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        if ([dic[@"success"] integerValue] == kSuccessCode){
            
            NSInteger count = deptInfoArray.count;
            NSInteger index = [deptInfoArray indexOfObject:tempNode];
            NSArray *deptInfo = dic[@"result"];
            for (NSInteger i = 0;i<deptInfo.count;i++) {
                NSDictionary *info = deptInfo[i];
                NSString *name = info[@"text"];
                NSString *Id = info[@"id"];
                BOOL leaf = [info[@"leaf"] boolValue];
                BOOL checked = NO;
                if (self.defaultDepts.count >0) {
                    checked = !([self.defaultDepts indexOfObject:name] == NSNotFound);
                }
                
                Node *node = [[Node alloc] initWithParentId:tempNode.nodeId nodeId:count+i name:name depth:(tempNode.depth+1) expand:YES Id:Id leaf:leaf checked:checked];
                [deptInfoArray insertObject:node atIndex:index+i+1];
            }
            tempNode.requested = YES;
            [self treeViewDataDisplay];
            
            
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        [MBProgressHUD showError:@"请求失败" toView:self.view.window];
    }];
    
    [request startAsynchronous];
}



- (void)commitAction:(id)sender{
    
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableArray *names = [NSMutableArray array];
 
    for (Node *node in deptInfoArray) {
        
        if (node.checked) {
            [ids addObject:node.Id];
            [names addObject:node.name];
        }
    }
    
    if (self.isRadioFlag && ids.count >1) {
        [MBProgressHUD showError:@"只能选一个部门" toView:self.view.window];
        return;
    }
    
    self.block(ids,names);
    [self backAction];
    
}

- (void)setTreeDeptBlock:(TreeDeptBlock)block{
    self.block = block;
}

@end
