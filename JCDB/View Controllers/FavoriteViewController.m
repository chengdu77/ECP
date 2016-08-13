//
//  FavoriteViewController.m
//  JCDB
//
//  Created by WangJincai on 16/5/14.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "FavoriteViewController.h"
#import "WorkOrderDetailsViewController.h"
#import "WorkOrderCell.h"
#import "WorkOrderBean.h"

@interface FavoriteViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;
    UISearchBar *_searchBar;

    NSArray *_options;
    NSMutableArray *findArray;
}


@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重点关注";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = kBackgroundColor;
    UINib *nib=[UINib nibWithNibName:@"WorkOrderCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"WorkOrderCell"];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 44)];
    _tableView.tableHeaderView = _searchBar;
    //            _searchBar.showsScopeBar = YES;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入搜索...";
    
    _options = [NSArray arrayWithArray:self.listData];
    findArray = [NSMutableArray array];
    for (WorkOrderBean *bean in self.listData) {
        [findArray addObject:bean.title];
    }
    
    
//    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(_tableView.frame) +10);
    
    [_tableView reloadData];
    
//    [self.scrollView set];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _options.count;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *tableViewIdentifier = @"WorkOrderCell";
    
    WorkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[WorkOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    WorkOrderBean *bean = _options[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.titleLabel.text = bean.title;
    cell.titleLabel.font = [UIFont fontWithName:kFontName size:14.0];
    cell.createdateLabel.text = bean.createdate;
    cell.createdateLabel.font = [UIFont fontWithName:kFontName size:12.0];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
    cell.photoImageView.image = [UIImage imageNamed:@"img_daiban"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkOrderBean *bean = self.listData[indexPath.row];
    
    WorkOrderDetailsViewController *details=[WorkOrderDetailsViewController new];
    details.canEditFlag = YES;
    details.hasFavorite = NO;
    details.processid = bean.processid;
    details.currentnode = bean.currentnode;
    [details setSuccessRefreshViewBlock:^{
//        [self reloadDataWithPageTag:0 withPageNumber:0];
    }];
    [self.navigationController pushViewController:details animated:YES];
    
    
}

/**
 *  通过搜索条件过滤得到搜索结果
 *
 *  @param searchText 关键词
 *
 */
- (void)filterContentForSearchText:(NSString*)searchText{
    
    if (searchText.length >0) {
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
        NSArray *find = [findArray filteredArrayUsingPredicate:resultPredicate];
        NSMutableArray *data = [NSMutableArray array];
        for (WorkOrderBean *bean in self.listData) {
            for (NSString *title in find) {
                if ([bean.title isEqualToString:title]) {
                    [data addObject:bean];
                }
            }
        }
      _options = [NSArray arrayWithArray:data];
        
    }else {
        _options = [NSArray arrayWithArray:self.listData];
    }
    
    
    [_tableView reloadData];
}

#pragma -mark -searchbar
//点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self filterContentForSearchText:@""];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    NSString *text = [searchBar text];
    [self filterContentForSearchText:text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //搜索内容随着输入及时地显示出来
    [self filterContentForSearchText:searchText];
}

@end
