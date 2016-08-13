//
//  RichLeveyPopListView.h
//  xsgj
//
//  Created by linw on 14/11/17.
//  Copyright (c) 2014年 ilikeido. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RichLeveyPopListViewDelegate;
@interface RichLeveyPopListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<RichLeveyPopListViewDelegate> delegate;
@property (copy, nonatomic) void(^handlerBlock)(NSInteger anIndex);
@property (nonatomic,strong) UIButton *btnOK;
@property (nonatomic,strong) UIButton *btnNO;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSArray *nameArray;
@property (strong, nonatomic) NSArray *processidArray;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions choosed:(NSArray *)defaultChoosed;
- (id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions
            handler:(void (^)(NSInteger))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;
@end

@protocol RichLeveyPopListViewDelegate <NSObject>
@optional
- (void)RichLeveyPopListView:(RichLeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex;

- (void)RichLeveyPopListViewDidCancel;
- (void)RichLeveyPopListView:(RichLeveyPopListView *)popListView clickOK:(NSArray*)res;
- (void)RichLeveyPopListViewClickNO;
@end
