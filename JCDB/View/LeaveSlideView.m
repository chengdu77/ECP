//
//  SlideTabBarView.m
//  SlideTabBar
//
//  Created by Mr.LuDashi on 15/6/25.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import "LeaveSlideView.h"
#import "PullingRefreshTableView.h"
#import "Constants.h"

#import "MBProgressHUD.h"
#import "MBProgressHUD+Add.h"

#define TOPHEIGHT 45
@interface LeaveSlideView()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>{

    NSInteger pageNumber;
    NSInteger rows;
}
// 整个视图的大小
@property (assign) CGRect mViewFrame;
// 下方的ScrollView
@property (strong, nonatomic) UIScrollView *scrollView;
// 上方的按钮数组
@property (strong, nonatomic) NSMutableArray *topViews;
// 上方的按钮title数组
@property (strong, nonatomic) NSArray *topViewsTitles;
// 下方的表格数组
@property (strong, nonatomic) NSMutableArray *scrollTableViews;
// 当前选中页数
@property (assign) NSUInteger currentPage;
// 下面滑动的View
@property (strong, nonatomic) UIView *slideView;
// 上方的ScrollView
@property (strong, nonatomic) UIScrollView *topScrollView;
// 上方的view
@property (strong, nonatomic) UIView *topMainView;
@property (assign) NSInteger tabCount;
@property (nonatomic,strong) UIColor *slideColor;
@property (nonatomic) BOOL refreshing;
@end

@implementation LeaveSlideView

-(instancetype)initWithFrame:(CGRect)frame withTitles: (NSArray *)array slideColor:(UIColor *)color withObjects:(NSArray *)objects cellName:(NSString *)cellName{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _mViewFrame = frame;
        _tabCount = array.count;
        _topViews = [[NSMutableArray alloc] init];
        _scrollTableViews = [[NSMutableArray alloc] init];
        
        _topViewsTitles=[NSArray arrayWithArray:array];
        
        _dataSource = [[NSMutableDictionary alloc] init];
        if (objects) {
            [_dataSource setObject:objects forKey:@"0"];
        }
        
        
        _slideColor=color;
        pageNumber=1;
        rows=20;
        _currentPage=0;
        
        _cellName=cellName;
    
        
        [self initScrollView];
        [self initTopTabs];
        [self initDownTables];
        [self initSlideView];
        [self reloadData];
        
    }
    
    return self;
}


#pragma mark -- 初始化滑动的指示View
-(void) initSlideView{
    
    CGFloat width = _mViewFrame.size.width / self.tabCount;
    CGFloat x = (width-width*.7)/2.0;

    _slideView = [[UIView alloc] initWithFrame:CGRectMake(x, TOPHEIGHT - 2, width *.7, 2)];
    [_slideView setBackgroundColor:_slideColor];
    [_topScrollView addSubview:_slideView];
}


#pragma mark -- 实例化ScrollView
-(void) initScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,TOPHEIGHT, _mViewFrame.size.width, _mViewFrame.size.height - TOPHEIGHT)];
    _scrollView.contentSize = CGSizeMake(_mViewFrame.size.width * _tabCount, _mViewFrame.size.height - TOPHEIGHT +80);
    _scrollView.backgroundColor = [UIColor whiteColor];
    
    _scrollView.pagingEnabled = YES;
    
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
}

#pragma mark -- 实例化顶部的tab
-(void) initTopTabs{
    CGFloat width = _mViewFrame.size.width / 6;
    
    if(self.tabCount <=6){
        width = _mViewFrame.size.width / self.tabCount;
    }
    
    _topMainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mViewFrame.size.width, TOPHEIGHT)];
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _mViewFrame.size.width, TOPHEIGHT)];
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.showsVerticalScrollIndicator = YES;
    _topScrollView.bounces = NO;
    _topScrollView.delegate = self;
    
    if (_tabCount >= 6) {
        _topScrollView.contentSize = CGSizeMake(width * _tabCount, TOPHEIGHT);

    } else {
        _topScrollView.contentSize = CGSizeMake(_mViewFrame.size.width, TOPHEIGHT);
    }
    
    [self addSubview:_topMainView];
    
    [_topMainView addSubview:_topScrollView];
    
    for (int i = 0; i < _tabCount; i ++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * width, 0, width, TOPHEIGHT)];
        view.backgroundColor = [UIColor clearColor];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, TOPHEIGHT)];
        button.tag = i;
        NSString *title=(NSString *)_topViewsTitles[i];
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:title];

        [attriString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor blackColor]
                            range:NSMakeRange(0,attriString.length)];
        
        [attriString addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:kFontName size:16]
                            range:NSMakeRange(0,attriString.length)];
        
        [button setAttributedTitle:attriString forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tabButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        [_topViews addObject:view];
        [_topScrollView addSubview:view];
    }
}


#pragma mark --点击顶部的按钮所触发的方法
- (void)tabButton:(id)sender{
    UIButton *button = sender;
    pageNumber = 1;
    [_scrollView setContentOffset:CGPointMake(button.tag * _mViewFrame.size.width, 0) animated:YES];
}

#pragma mark --初始化下方的TableViews
-(void) initDownTables{
    
    for (int i=0; i<_tabCount; i++) {
        
        PullingRefreshTableView *tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(i * _mViewFrame.size.width,0, _mViewFrame.size.width, _mViewFrame.size.height - TOPHEIGHT) pullingDelegate:self];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = i;//就是Page号 pageNumber
        UINib *nib=[UINib nibWithNibName:_cellName bundle:[NSBundle mainBundle]];
        [tableView registerNib:nib forCellReuseIdentifier:_cellName];


        [_scrollTableViews addObject:tableView];
        [_scrollView addSubview:tableView];
    }
}


#pragma mark --根据scrollView的滚动位置复用tableView，减少内存开支
-(void) updateTableWithPageNumber:(NSUInteger)pageNum{
//    NSUInteger tabviewTag = pageNum;
//    
//    CGRect tableNewFrame = CGRectMake(pageNumber * _mViewFrame.size.width,0, _mViewFrame.size.width, _mViewFrame.size.height - TOPHEIGHT);
    
//    PullingRefreshTableView *reuseTableView = _scrollTableViews[tabviewTag];

//    reuseTableView.frame = tableNewFrame;
//    [reuseTableView reloadData];
//    [self reloadData];
}

#pragma mark -- scrollView的代理方法
-(void) modifyTopScrollViewPositiong:(UIScrollView *)scrollView{
    if ([_topScrollView isEqual:scrollView]) {
        CGFloat contentOffsetX = _topScrollView.contentOffset.x;
        CGFloat width = _slideView.frame.size.width;
        int count = (int)contentOffsetX/(int)width;
        CGFloat step = (int)contentOffsetX%(int)width;
        CGFloat sumStep = width * count;
        if (step > width/2) {
            sumStep = width * (count + 1);
        }
        
        [_topScrollView setContentOffset:CGPointMake(sumStep, 0) animated:YES];
        return;
    }else if ([scrollView isKindOfClass:[PullingRefreshTableView class]]){
        
    }
}

///拖拽后调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [self modifyTopScrollViewPositiong:scrollView];
    
    PullingRefreshTableView *listTableView=_scrollTableViews[_currentPage];
    
    [listTableView tableViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
    
}
//左右滑动时，
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:_scrollView]) {
        
        NSInteger oldPage=_currentPage;
        for (PullingRefreshTableView *listTableView in _scrollTableViews) {
            if (CGRectContainsPoint(listTableView.frame,_scrollView.contentOffset)) {
                _currentPage=listTableView.tag;
                break;
            }
        }
        //左右滑动时，查询“审批状态”发生了改变，从而导致查询分页重新开始
        if (oldPage != _currentPage) {
            pageNumber = 1;
          
            NSMutableArray *tempArray=[_dataSource objectForKey:[NSString stringWithFormat:@"%ld",(long)_currentPage]];
            if (tempArray.count>0) {//清除数据
                [tempArray removeAllObjects];
                [_dataSource setObject:tempArray forKey:[NSString stringWithFormat:@"%ld",(long)_currentPage]];
            }
            
           [self reloadData];
        }

//        [self updateTableWithPageNumber:_currentPage];
        return;
    }
    
    [self modifyTopScrollViewPositiong:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_scrollView isEqual:scrollView]) {
        CGRect frame = _slideView.frame;
        
        CGFloat width = _mViewFrame.size.width / _tabCount;
        CGFloat x = (width-width*.7)/2.0;
        frame.origin.x = scrollView.contentOffset.x/_tabCount +x;
        _slideView.frame = frame;
    }
    
    PullingRefreshTableView *listTableView=_scrollTableViews[_currentPage];
    [listTableView tableViewDidScroll:scrollView];
}


#pragma mark -- talbeView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *tempArray=[_dataSource objectForKey:[NSString stringWithFormat:@"%ld",(long)_currentPage]];
    return tempArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}

BOOL nibsRegistered=NO;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (!nibsRegistered) {
//        UINib *nib=[UINib nibWithNibName:_cellName bundle:[NSBundle mainBundle]];
//        [tableView registerNib:nib forCellReuseIdentifier:_cellName];
//        nibsRegistered=YES;
//    }

    if (tableView.tag == _currentPage) {
        
        NSArray *array=[_dataSource objectForKey:[NSString stringWithFormat:@"%ld",(long)_currentPage]];
        id bean=array[indexPath.row];
        
        if (_delegate && [_delegate respondsToSelector:@selector(fillCellDataTableView:withObject:withPageTag:)]) {
           return [_delegate fillCellDataTableView:tableView withObject:bean withPageTag:_currentPage];
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: _cellName];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if (tableView.tag == _currentPage) {
        
        NSArray *array=[_dataSource objectForKey:[NSString stringWithFormat:@"%ld",(long)_currentPage]];
        id bean=array[indexPath.row];
        
        if (_delegate && [_delegate respondsToSelector:@selector(openInfoViewWith:withPageTag:)]) {
            return [_delegate openInfoViewWith:bean withPageTag:_currentPage];
        }
    }
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
   self.refreshing = YES;
    pageNumber++;
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1.f];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *currentDateStr = [df stringFromDate:[NSDate date]];
    NSDate *date = [df dateFromString:currentDateStr];
    return date;
}




- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    pageNumber++;
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1.f];
    
}

- (void)reloadData{
    
    if (_delegate && [_delegate respondsToSelector:@selector(reloadDataWithPageTag:withPageNumber:)]) {
        
         [_delegate reloadDataWithPageTag:_currentPage withPageNumber:pageNumber];
    }
}

- (void)getDataOver {
    
    PullingRefreshTableView *listTableView=_scrollTableViews[_currentPage];
    
    [listTableView reloadData];
    [listTableView tableViewDidFinishedLoading];
    listTableView.reachedTheEnd = NO;
    
}

- (void)defaultAction:(NSInteger)tag{
    pageNumber=1;
    [_scrollView setContentOffset:CGPointMake(tag * _mViewFrame.size.width, 0) animated:YES];
}



@end
