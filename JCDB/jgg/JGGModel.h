/*
 作者: 羊羊羊
 描述: 
 时间:
 文件名:  JGGModel.h
 */

#import <UIKit/UIKit.h>

@interface JGGModel : NSObject


@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, strong) NSString *url;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
