//
//  ABELTableView.m
//  ABELTableViewDemo
//
//  Created by abel on 14-4-28.
//  Copyright (c) 2014年 abel. All rights reserved.
//

#import "BATableView.h"
#import "BATableViewIndex.h"

@interface BATableView()<BATableViewIndexDelegate>
@property (nonatomic, strong) UILabel * flotageLabel;
@property (nonatomic, strong) BATableViewIndex * tableViewIndex;
@end

#undef	RGB
#define RGB(r,g,b,a)  [UIColor colorWithRed:(double)r/255.0f green:(double)g/255.0f blue:(double)b/255.0f alpha:a]

@implementation BATableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.tableView];
        
        self.tableViewIndex = [[BATableViewIndex alloc] initWithFrame:CGRectMake(300, 0, 20, self.tableViewIndex.bounds.size.height)];
        [self addSubview:self.tableViewIndex];
        
        self.flotageLabel = [[UILabel alloc] initWithFrame:(CGRect){(self.bounds.size.width - 64 ) / 2,(self.bounds.size.height - 64) / 2,64,64}];
        self.flotageLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flotageBackgroud"]];
        self.flotageLabel.hidden = YES;
        self.flotageLabel.textAlignment = NSTextAlignmentCenter;
        self.flotageLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.flotageLabel];
    }
    return self;
}

- (void)setDelegate:(id<BATableViewDelegate>)delegate
{
    _delegate = delegate;
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForABELTableView:self];
    CGRect rect = self.tableViewIndex.frame;
    rect.size.height = self.tableViewIndex.indexes.count * 16;
    rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    self.tableViewIndex.frame = rect;
    
    self.tableViewIndex.tableViewIndexDelegate = self;
}

- (void)reloadData
{
    [self.tableView reloadData];
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForABELTableView:self];
    CGRect rect = self.tableViewIndex.frame;
    rect.size.height = self.tableViewIndex.indexes.count * 20;
    rect.origin.y = edgeInsets.top ;
    self.tableViewIndex.frame = rect;
    self.tableViewIndex.tableViewIndexDelegate = self;
}


#pragma mark -
- (void)tableViewIndex:(BATableViewIndex *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title
{
    if ([self.tableView numberOfSections] > index && index > -1){   // for safety, should always be YES
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        self.flotageLabel.text = title;
    }
//    tableViewIndex.backgroundColor=[UIColor blackColor];
    NSArray* layers=   tableViewIndex.layer.sublayers;
    for (CALayer* la in layers) {
//        la.backgroundColor=[[UIColor clearColor]CGColor];
        if (![la  isKindOfClass:[CAShapeLayer class]]) {
            CATextLayer* tl=(CATextLayer*)la;
//            tl.foregroundColor=[[UIColor grayColor]CGColor];
            tl.foregroundColor=RGB(168, 168, 168, 1).CGColor;
        }
    }
    CALayer* layer=[layers objectAtIndex:index];
    CATextLayer* tl=(CATextLayer*)layer;
    tl.foregroundColor=[UIColor colorWithRed:64/255.0 green:155/255.0 blue:228/255.0 alpha:1.0].CGColor;
//    layer.backgroundColor=[[UIColor blueColor]CGColor];
        self.tableViewIndex.alpha=0.5;
}

- (void)tableViewIndexTouchesBegan:(BATableViewIndex *)tableViewIndex
{
    self.flotageLabel.hidden = NO;
}

- (void)tableViewIndexTouchesEnd:(BATableViewIndex *)tableViewIndex
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.flotageLabel.layer addAnimation:animation forKey:nil];
    
    self.flotageLabel.hidden = YES;
    self.tableViewIndex.backgroundColor =[UIColor clearColor];
    self.tableViewIndex.alpha=1.0;
}

- (NSArray *)tableViewIndexTitle:(BATableViewIndex *)tableViewIndex
{
    return [self.delegate sectionIndexTitlesForABELTableView:self];
}
@end
