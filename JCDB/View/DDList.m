//
//  DDList.m
//  DropDownList
//
//  Created by kingyee on 11-9-19.
//  Copyright 2011 Kingyee. All rights reserved.
//

#import "DDList.h"
#import <QuartzCore/QuartzCore.h>



#define kCellRowHeight 30

@implementation DDList


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.layer.borderWidth = 1;
	self.tableView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    _isExpansionFlag = NO;
    
    [self.view setHidden:YES];

}

- (void)reloadData:(NSArray *)data {
    _resultList = [NSMutableArray arrayWithArray:data];
    [self.view setHidden:NO];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_resultList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [_resultList objectAtIndex:row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setDDListHidden:YES];
    NSString *_selectedText = [_resultList objectAtIndex:[indexPath row]];
    self.block(_selectedText);
}

-(void)setDefectsTypeBlock:(DefectsTypeBlock) block {
    self.block = block;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
   
}

- (void)setDDListHidden:(BOOL)hidden {
    
    NSInteger height = hidden ? 0 : kCellRowHeight*_resultList.count;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [self.view setFrame:CGRectMake(_position.x, _position.y, 150, height)];
    [UIView commitAnimations];
    
    _isExpansionFlag = !hidden;
}

- (void)setUpDisplay:(BOOL)hidden {
    
    NSInteger height = hidden ? 0 : kCellRowHeight*_resultList.count;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    if (hidden) {
        [self.view setFrame:CGRectMake(_position.x, _position.y, 150, height)];
    } else {
        [self.view setFrame:CGRectMake(_position.x, _position.y - height, 150, height)];
    }
     [UIView commitAnimations];
    
    _isExpansionFlag = !hidden;
}


@end

