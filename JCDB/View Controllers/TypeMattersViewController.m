//
//  TypeMattersViewController.m
//  JCDB
//
//  Created by WangJincai on 16/3/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "TypeMattersViewController.h"
#import "AddFormDataViewController.h"


@implementation TypeMattersBean
@end

@interface TypeMattersViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}


@end

@implementation TypeMattersViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.scrollView addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 36;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.listData.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *tableViewIdentifier = @"TableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    TypeMattersBean *bean = self.listData[indexPath.row];
    cell.textLabel.text = bean.objname;
    cell.textLabel.font = [UIFont fontWithName:kFontName size:14];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TypeMattersBean *myBean = self.listData[indexPath.row];
 
    NSString *serviceStr = [NSString stringWithFormat:kURL_AddFormData,self.serviceIPInfo,myBean.objid];
    if ([myBean.type integerValue] >0){
        //1表示目录，2表示流程，3表示文档
        serviceStr = [NSString stringWithFormat:@"%@&type=%@",serviceStr,myBean.type];
    }else{
        serviceStr = [NSString stringWithFormat:@"%@&type=2",serviceStr];
    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    [self setCookie:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *weakRequest = request;
    [request setCompletionBlock:^{
        
        NSError *err=nil;
        
        NSData *responseData = [weakRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
        
        if ([dic[@"success"] integerValue] == kSuccessCode){
            NSDictionary *info = dic[@"result"];
//            NSLog(@"result:%@",info);
         
            AddFormDataBean *bean = [AddFormDataBean new];
            bean.formid = info[@"formid"];
            bean.type = info[@"type"];
            bean.objname = info[@"objname"];
            bean.dowid = info[@"dowid"];
            bean.formfields = info[@"formfields"];
            bean.subtables = info[@"subtables"];
         
            if (bean.formfields.count >0) {
                AddFormDataViewController *addFormDataViewController = [AddFormDataViewController new];
                addFormDataViewController.infoBean = bean;
                addFormDataViewController.title = myBean.objname;
                [self.navigationController pushViewController:addFormDataViewController animated:YES];
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
