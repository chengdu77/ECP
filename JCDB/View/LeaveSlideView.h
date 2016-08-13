//
//  SlideTabBarView.h
//  SlideTabBar
//
//  Created by Mr.LuDashi on 15/6/25.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeaveSlideViewDelegate <NSObject>

@required
- (UITableViewCell *)fillCellDataTableView:(UITableView *)tableView withObject:(id)object withPageTag:(NSInteger)page;

- (void)reloadDataWithPageTag:(NSInteger)page withPageNumber:(NSInteger)pagenum;

- (void)openInfoViewWith:(id)object withPageTag:(NSInteger)page;

@end

@interface LeaveSlideView : UIView
-(instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)array slideColor:(UIColor *)color withObjects:(NSArray *)objects cellName:(NSString *)cellName;

- (void)defaultAction:(NSInteger)tag;
- (void)getDataOver;

// TableViews的数据源
@property (strong, nonatomic) NSMutableDictionary *dataSource;

@property (nonatomic,assign) id delegate;
@property (nonatomic,strong) NSString *cellName;
@property (nonatomic,assign) CGFloat cellHeight;

@end



