/*
 作者: 羊羊羊
 描述: 
 时间:
 文件名: JGGModel.m
 */

#import "JGGModel.h"

@implementation JGGModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.id_ =  [dict[@"id"] integerValue];
        self.icon = dict[@"icon"];
        self.name = dict[@"name"];
        self.alias = dict[@"alias"];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

@end
