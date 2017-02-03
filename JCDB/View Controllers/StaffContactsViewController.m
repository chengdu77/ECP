//
//  StaffContactsViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/2.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "StaffContactsViewController.h"
#import "StaffContactBean.h"
#import "StaffContactsCell.h"
#import "OAChineseToPinyin.h"
#import "NSString+URL.h"
#import "BATableView.h"
#import "BATableViewIndex.h"

#import "StaffContactDetailViewController.h"

@interface StaffContactsViewController ()<BATableViewDelegate>{
    BATableView *_tableView;
    
    NSMutableArray *infosArray;
    UIWebView *_webViewTel;
    
    // A-Z段落列表
    NSMutableArray *mAzArray;
    // 原始部门数据
//    NSArray        *arraySourceDept;
    // 原始联系人数据
//    NSArray        *arraySourceContact;
    // 联系人查询条件
    NSString       *sqlDeptId;
    // 综合查询条件
    NSString       *sqlDeptIdAndSerach;
    // UI实际填充-二维
    NSMutableArray *mUIdataArray;
    //存首字母
    NSMutableArray  * firstPYs;
    //重新排序
    NSMutableArray *sortByPY;

}

@end

@implementation StaffContactsViewController

- (void)viewDidLoad {
    self.flag = YES;
    [super viewDidLoad];
    
    infosArray = [NSMutableArray array];
//    arraySourceDept      = [NSArray array];
    mAzArray             = [NSMutableArray array];
    mUIdataArray         = [NSMutableArray array];
    firstPYs    =[NSMutableArray array];
    sortByPY =[NSMutableArray array];
    self.title = @"通讯录";
    
    [self getData];
    
    _tableView = [[BATableView alloc] initWithFrame:CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
//    _tableView.dataSource = self;
    [self.scrollView addSubview:_tableView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetHeight(_tableView.frame) +10);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)getData{
    
     dispatch_async(dispatch_get_main_queue(), ^{
         [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
     });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/com.cinsea.action.HrmAction?action=gethumanlist",self.serviceIPInfo];
        NSURL *url = [NSURL URLWithString:serviceStr];
        [self setCookie:url];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        __weak ASIHTTPRequest *weakRequest = request;
        [request setCompletionBlock:^{
            NSError *err=nil;
            NSData *responseData = [weakRequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
            if ([dic[@"success"] integerValue] ==1){
                    if (infosArray.count >0) {
                        [infosArray removeAllObjects];
                    }
                    NSArray *result = dic[@"result"];
                    for (NSDictionary *info in result) {
                        StaffContactBean *bean=[StaffContactBean new];
                        bean._id = info[@"id"];
                        bean.name = info[@"name"];
                        bean.tel = info[@"cell"];
                        bean.gender = info[@"gender"];
                        bean.duty = info[@"duty"];
                        bean.email = @"";
                        if (info[@"emil"]) {
                            bean.email = info[@"emil"];
                        }
                        bean.org = info[@"org"];
                        bean.photoId = info[@"photoId"];
                        bean.photoURL = info[@"photoZN"];
                        bean.processid = info[@"processid"];
                        NSDictionary *wfprocess =info[@"wfprocess"];
                        bean.daiban = [wfprocess[@"daiban"] integerValue];
                        bean.qqwwc = [wfprocess[@"qqwwc"] integerValue];
                        bean.yiban = [wfprocess[@"yiban"] integerValue];
                        
                        bean.NAME_PINYIN = [bean.name convertCNToPinyin];
                        if (bean.NAME_PINYIN.length > 0) {
                            bean.NAME_HEAD   = [bean.NAME_PINYIN substringWithRange:NSMakeRange(0, 1)];
                        }
                        
                        [infosArray addObject:bean];
                    }
                  dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                     if (infosArray.count >0) {
                             infosArray = [self fillHeadArray:infosArray];
                         _tableView.delegate = self;
                         [_tableView reloadData];
                     }else{
                       [MBProgressHUD showError:dic[@"msg"] toView:self.view.window];
                     }
                     
                });
            }
        }];
        
        [request setFailedBlock:^{
             dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
            [MBProgressHUD showError:@"请求失败" toView:self.view.window];
             });
        }];
        
        [request startAsynchronous];

    });
}

- (NSMutableArray *)fillHeadArray:(NSArray *)array{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *resultArray     = [NSMutableArray array];
    NSMutableArray *headArray     = [NSMutableArray array];
    for (StaffContactBean *bean in array)
    {
        if ([headArray indexOfObject:bean.NAME_HEAD]==NSNotFound) {
            [headArray addObject:bean.NAME_HEAD];
        }
    }
    
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    
    for (NSString *indexTitle in headArray){
        [dict setObject:array forKey:indexTitle];
    }
    
    NSComparator sort2 = ^(StaffContactBean *obj1,StaffContactBean *obj2)
    {
        return [obj1.name compare:obj1.name];
    };
    
    for (int i=0;i<dict.allKeys.count; i++) {
        NSString *indexTitle =dict.allKeys[i];
        NSMutableArray* index = dict[indexTitle];
        NSMutableArray* data = [NSMutableArray array];
        for(int i=0;i<index.count; i++){
            StaffContactBean *bean= index[i];
            if ([bean.NAME_HEAD isEqualToString:indexTitle]) {
                [data addObject:bean];
            }
        }
        data = (NSMutableArray*)[data sortedArrayUsingComparator:sort2];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:indexTitle forKey:@"indexTitle"];
        [info setObject:data forKey:@"data"];
        [resultArray addObject:info];
    }
    
    NSComparator sort3 = ^(NSDictionary *obj1,NSDictionary *obj2)
    {
        NSString *indexTitle1 = obj1[@"indexTitle"];
        NSString *indexTitle2 = obj2[@"indexTitle"];
        
        NSRange range = NSMakeRange(0,indexTitle1.length);
        return [indexTitle1 compare:indexTitle2 options:comparisonOptions range:range];
        
    };
    
    return (NSMutableArray*)[resultArray sortedArrayUsingComparator:sort3];
    
}

#pragma mark - UITableViewDataSource
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    if (infosArray.count <=0) {
        return nil;
    }
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in infosArray) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return infosArray[section][@"indexTitle"];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return infosArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [infosArray[section][@"data"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"StaffContactsCell";
    StaffContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    StaffContactBean *bean = infosArray[indexPath.section][@"data"][indexPath.row];
    
    cell.nameLabel.text = bean.name;
    cell.nameLabel.font = [UIFont fontWithName:kFontName size:14];
    cell.orgLabel.text = bean.org;
    cell.orgLabel.font = [UIFont fontWithName:kFontName size:12];
    NSString *urlStr = bean.photoId;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    [self roundImageView:cell.imageView withColor:kALLBUTTON_COLOR];
    
    cell.telButton.tag = indexPath.row;
    cell.telButton.section = indexPath.section;
    cell.smsButton.tag = indexPath.row;
    cell.smsButton.section = indexPath.section;
    
    if (bean.tel.length >0) {
        [cell.telButton addTarget:self action:@selector(telActoin:) forControlEvents:UIControlEventTouchUpInside];
        [cell.smsButton addTarget:self action:@selector(smsActoin:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSString *serviceUrl = [NSString stringWithFormat:@"%@/filedownload.do?attachid=%@",self.serviceIPInfo,urlStr];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:serviceUrl] placeholderImage:[UIImage imageNamed:@"img_user_default"]];
    
    [self roundImageView:cell.photoImageView withColor:kALLBUTTON_COLOR];
   
    return  cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StaffContactBean *bean = infosArray[indexPath.section][@"data"][indexPath.row];
    StaffContactDetailViewController *staffContactDetailViewController = [StaffContactDetailViewController new];
    [staffContactDetailViewController setBeanInfo:bean];
    
    [self.navigationController pushViewController:staffContactDetailViewController animated:YES];
}

- (void)telActoin:(id)sender{
    
    SLButton *btn = sender;
    StaffContactBean *bean =  (StaffContactBean *)infosArray[btn.section][@"data"][btn.tag];
    
    if (bean.tel.length <=0 || !bean.tel.length) {
        return;
    }
    
    if (!_webViewTel) {
        _webViewTel =[[UIWebView alloc] init];
        [self.view addSubview:_webViewTel];
    }
    
    NSString *urlLink = [NSString stringWithFormat:@"tel:%@",bean.tel];
    [_webViewTel loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlLink]]];

}

- (void)smsActoin:(id)sender{
    
    SLButton *btn = sender;
    StaffContactBean *bean =  (StaffContactBean *)infosArray[btn.section][@"data"][btn.tag];
    if (bean.tel.length <=0 || !bean.tel.length) {
        return;
    }
    NSString *str = [NSString stringWithFormat:@"sms://%@",bean.tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}


@end
