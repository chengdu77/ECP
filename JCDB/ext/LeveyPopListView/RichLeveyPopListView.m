//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "RichLeveyPopListView.h"
#import "LeveyPopListViewCell.h"

#define POPLISTVIEW_SCREENINSET 40.
#define POPLISTVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.

@interface RichLeveyPopListView (private)<UISearchBarDelegate>
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation RichLeveyPopListView {
    UITableView *_tableView;
    UISearchBar *_searchBar;
    NSString *_title;
    NSArray *_options;
    UIView *_backView;
    BOOL   *bSelState;
    NSInteger maxRow;
    
    NSArray *_optionsAll;
    NSMutableDictionary *chooseValues;
}

#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions choosed:(NSArray *)defaultChoosed
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    
    if (self = [super initWithFrame:rect])
    {
        maxRow = [aOptions count];
        bSelState = (BOOL*)malloc(maxRow*sizeof(BOOL));
        memset(bSelState,0,maxRow);
        if (!_backView) {
            _backView = [[UIView alloc]init];
            _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        }
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            rect.size = CGSizeMake(rect.size.height, rect.size.width);
        }
        
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        _options = [aOptions copy];
        _optionsAll = _options;
        chooseValues = [NSMutableDictionary dictionary];
        for (int i=0;i<_optionsAll.count;i++) {
            NSString *value= _optionsAll[i];
            if ((!([defaultChoosed indexOfObject:value] ==NSNotFound)) && defaultChoosed) {
                [chooseValues setObject:@"1" forKey:value];
                bSelState[i]=!bSelState[i];
            }else
            [chooseValues setObject:@"0" forKey:value];
        }
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(POPLISTVIEW_SCREENINSET,
                                                                   POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT,
                                                                   rect.size.width - 2 * POPLISTVIEW_SCREENINSET,
                                                                   rect.size.height - 2 * POPLISTVIEW_SCREENINSET - 2*POPLISTVIEW_HEADER_HEIGHT - RADIUS)];
        _tableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
        
        if (aOptions.count > 9) {
            _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 44)];
            _tableView.tableHeaderView = _searchBar;
            _searchBar.showsScopeBar = YES;
            _searchBar.delegate = self;
            _searchBar.placeholder = @"请输入搜索...";
        }
       
        _btnNO = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnNO.frame = CGRectMake(POPLISTVIEW_SCREENINSET+(rect.size.width - 2 * POPLISTVIEW_SCREENINSET)/2,
                                  _tableView.frame.size.height+2*POPLISTVIEW_HEADER_HEIGHT,
                                  (rect.size.width - 2 * POPLISTVIEW_SCREENINSET)/2,
                                  POPLISTVIEW_SCREENINSET);
        [_btnNO setTitle:@"取消" forState:UIControlStateNormal];
        [_btnNO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnNO.backgroundColor = [UIColor whiteColor];
        [_btnNO addTarget:self action:@selector(clickBtnNO) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnNO];
        
        _btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnOK.frame = CGRectMake(POPLISTVIEW_SCREENINSET,
                                  _tableView.frame.size.height+2*POPLISTVIEW_HEADER_HEIGHT,
                                  (rect.size.width - 2 * POPLISTVIEW_SCREENINSET)/2,
                                  POPLISTVIEW_SCREENINSET);
        [_btnOK setTitle:@"确定" forState:UIControlStateNormal];
        [_btnOK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnOK addTarget:self action:@selector(clickBtnOK) forControlEvents:UIControlEventTouchUpInside];
        _btnOK.backgroundColor = [UIColor whiteColor];
        [self addSubview:_btnOK];
        
        UILabel *lineH = [[UILabel alloc]initWithFrame:CGRectMake(POPLISTVIEW_SCREENINSET, _tableView.frame.size.height+2*POPLISTVIEW_HEADER_HEIGHT-1, (rect.size.width - 2 * POPLISTVIEW_SCREENINSET), 1)];
        lineH.backgroundColor = [UIColor grayColor];
        [self addSubview:lineH];
        
        UILabel *linV  = [[UILabel alloc]initWithFrame:
                          CGRectMake(POPLISTVIEW_SCREENINSET+(rect.size.width - 2 * POPLISTVIEW_SCREENINSET)/2,
                                     _tableView.frame.size.height+2*POPLISTVIEW_HEADER_HEIGHT,
                                     1,
                                     RADIUS+POPLISTVIEW_SCREENINSET)];
        linV.backgroundColor = [UIColor grayColor];
        [self addSubview:linV];
    }
    return self;
}

-(void)clickBtnOK
{
    NSMutableArray *boolArr = [[NSMutableArray alloc]initWithCapacity:maxRow];
    for (int i = 0 ; i< maxRow; i++){
        NSString *key =  _optionsAll[i];
        NSString *value = [chooseValues objectForKey:key];
//        BOOL state = NO;
        if ([value isEqualToString:@"1"]) {
//            state = YES;
            [boolArr addObject:key];
        }
//        [boolArr addObject:[NSNumber numberWithBool:bSelState[i]]];
//        [boolArr addObject:[NSNumber numberWithBool:state]];
    }
    if ([_delegate respondsToSelector:@selector(RichLeveyPopListView:clickOK:)])
        [_delegate RichLeveyPopListView:self clickOK:boolArr];
    [self fadeOut];
}
-(void)clickBtnNO
{
    if ([_delegate respondsToSelector:@selector(RichLeveyPopListViewClickNO)])
        [_delegate RichLeveyPopListViewClickNO];
    [self fadeOut];
}
- (id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions
            handler:(void (^)(NSInteger anIndex))aHandlerBlock {
    
    if(self = [self initWithTitle:aTitle options:aOptions choosed:nil])
        self.handlerBlock = aHandlerBlock;
    
    return self;
}




#pragma mark - Private Methods
- (void)fadeIn:(UIView *)view {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    
    _backView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
        _backView.alpha = 1;
    }];
}

- (void) orientationDidChange: (NSNotification *) not {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    [self setFrame:rect];
    [self setNeedsDisplay];
}

- (void)fadeOut {
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
        _backView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
            [_backView removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    if ([aView viewWithTag:11000011]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                               object: nil];
    _backView.tag = 11000011;
    _backView.frame = aView.frame;
    [_backView addSubview:self];
    [aView addSubview:_backView];
    if (animated) {
        [self fadeIn:aView];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"PopListViewCell";
    LeveyPopListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (!cell)
    {
        cell = [[LeveyPopListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.gImgView.hidden=NO;
    }
   
    if (bSelState[indexPath.row])
    {
        cell.gImgView.image = [UIImage imageNamed:@"CheckBox1_Selected"];
    }
    else
    {
       cell.gImgView.image = [UIImage imageNamed:@"CheckBox1_unSelected"];
    }
    if ([_options[indexPath.row] respondsToSelector:@selector(objectForKey:)])
    {
        cell.imageView.image = _options[indexPath.row][@"img"];
        cell.textLabel.text = _options[indexPath.row][@"text"];
    }
    else
    {
        cell.textLabel.text = _options[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    bSelState[indexPath.row] = !bSelState[indexPath.row];
    NSString *value = _options[indexPath.row];
    for(NSString *key in chooseValues.allKeys){
        if ([key isEqualToString:value]) {
            NSString *myValue = [chooseValues objectForKey:key];
            if ([myValue isEqualToString:@"0"]) {
                [chooseValues setObject:@"1" forKey:key];
            }else{
                [chooseValues setObject:@"0" forKey:key];
            }
        }
    }
    
    // tell the delegate the selection
    if ([_delegate respondsToSelector:@selector(RichLeveyPopListView:didSelectedIndex:)])
        [_delegate RichLeveyPopListView:self didSelectedIndex:[indexPath row]];
    if (_handlerBlock)
        _handlerBlock(indexPath.row);
    
//    chooseValues
    [tableView reloadData];
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // tell the delegate the cancellation
    if ([_delegate respondsToSelector:@selector(RichLeveyPopListViewDidCancel)])
        [_delegate RichLeveyPopListViewDidCancel];
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect
{
    CGRect bgRect = CGRectInset(rect, POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET);
    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, POPLISTVIEW_SCREENINSET + 10 + 5,
                                  rect.size.width -  2 * (POPLISTVIEW_SCREENINSET + 10), 30);
    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT - 2,
                                      rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.75].CGColor);
    [[UIColor colorWithWhite:1 alpha:1.0] setFill];
    
    
    float x = POPLISTVIEW_SCREENINSET;
    float y = POPLISTVIEW_SCREENINSET;
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y + RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    // Draw the title and the separator with shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor clearColor].CGColor);
    [[UIColor colorWithRed:0    green:155.0/255 blue:230.0/255 alpha:1.] setFill];
    [_title drawInRect:titleRect withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.],NSFontAttributeName,nil]];
    CGContextFillRect(ctx, separatorRect);
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
        _options = [_optionsAll filteredArrayUsingPredicate:resultPredicate];
    }else {
        _options = [NSArray arrayWithArray:_optionsAll];
    }
    
    memset(bSelState,0,maxRow);
    for(NSString *key in chooseValues.allKeys){
        [chooseValues setObject:@"0" forKey:key];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{   //搜索内容随着输入及时地显示出来
    [self filterContentForSearchText:searchText];
}


@end
