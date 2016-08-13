//
//  SelectionModuleViewController.m
//  JCDB
//
//  Created by WangJincai on 16/3/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "SelectionModuleViewController.h"
#import "TypeMattersViewController.h"



@implementation SelectionModuleBean
@end

@interface SelectionModuleViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}

@end

@implementation SelectionModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kBackgroundColor;
    [self.scrollView addSubview:_tableView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(_tableView.frame) +10);
   
  [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 36;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.listData.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *tableViewIdentifier = @"TableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    SelectionModuleBean *bean = self.listData[indexPath.row];
    cell.textLabel.text = bean.objname;
    cell.textLabel.font = [UIFont fontWithName:kFontName size:14];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     SelectionModuleBean *bean = self.listData[indexPath.row];
    
    NSString *serviceStr = [NSString stringWithFormat:kURL_TypeMatters,self.serviceIPInfo,bean.objid];
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSMutableArray *array = [NSMutableArray array];
            NSArray *result = dic[@"result"];
            for (NSDictionary *info in result) {
                TypeMattersBean *bean = [TypeMattersBean new];
                bean.formid = info[@"formid"];
                bean.objid = info[@"id"];
                bean.objname = info[@"objname"];
                bean.ismobile = info[@"ismobile"];
                bean.listsize = info[@"listsize"];
                bean.title = info[@"title"];
                bean.type = info[@"type"];
                [array addObject:bean];
            }
            
            if (array.count >0) {
                TypeMattersViewController *typeMattersViewController = [TypeMattersViewController new];
                typeMattersViewController.listData = array;
                typeMattersViewController.title = @"事项类型";
                [self.navigationController pushViewController:typeMattersViewController animated:YES];
            }else {
                [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
            }
        }else{
            [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD showError:kErrorInfomation toView:self.view.window];
    }];
    
    
    [request startAsynchronous];
    
}

@end
