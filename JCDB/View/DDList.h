//
//  DDList.h
//  DropDownList
//
//  Created by kingyee on 11-9-19.
//  Copyright 2011 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DefectsTypeBlock)(NSString *deviceName);

@interface DDList : UITableViewController {
	NSMutableArray	*_resultList;
}


@property (nonatomic,assign) BOOL isExpansionFlag;
@property (nonatomic,assign) CGPoint position;

@property (nonatomic,copy) DefectsTypeBlock block;
-(void)setDefectsTypeBlock:(DefectsTypeBlock) block;


- (void)reloadData:(NSArray *)data;

- (void)setDDListHidden:(BOOL)hidden ;

- (void)setUpDisplay:(BOOL)hidden;

@end
