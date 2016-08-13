//
//  UIView+BindValues.m
//  JCDB
//
//  Created by WangJincai on 16/1/6.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "UIView+BindValues.h"
#import <objc/runtime.h>

@implementation UIView (BindValues)

@dynamic fieldType;

- (NSString *)Id{
    return objc_getAssociatedObject(self, @selector(Id));
}

- (void)setId:(NSString *)Id{
    objc_setAssociatedObject(self, @selector(Id), Id, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)value{
    return objc_getAssociatedObject(self, @selector(value));
}

- (void)setValue:(NSString *)value{
    objc_setAssociatedObject(self, @selector(value), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)newValue{
    return objc_getAssociatedObject(self, @selector(newValue));
}

- (void)setNewValue:(NSString *)newValue{
    objc_setAssociatedObject(self, @selector(newValue), newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)fieldType{
    return objc_getAssociatedObject(self, @selector(fieldType));
}

- (void)setFieldType:(NSString *)fieldType{
    objc_setAssociatedObject(self, @selector(fieldType), fieldType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSArray *)pulldownData{
    return objc_getAssociatedObject(self, @selector(pulldownData));
}

- (void)setPulldownData:(NSArray *)pulldownData{
    objc_setAssociatedObject(self, @selector(pulldownData), pulldownData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)viewListTitle{
    return objc_getAssociatedObject(self, @selector(viewListTitle));
}

- (void)setViewListTitle:(NSString *)viewListTitle{
    objc_setAssociatedObject(self, @selector(viewListTitle), viewListTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)tablename{
    return objc_getAssociatedObject(self, @selector(tablename));
}

- (void)setTablename:(NSString *)tablename{
    objc_setAssociatedObject(self, @selector(tablename), tablename, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)fieldname{
    return objc_getAssociatedObject(self, @selector(fieldname));
}

- (void)setFieldname:(NSString *)fieldname{
    objc_setAssociatedObject(self, @selector(fieldname), fieldname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)labelname{
    return objc_getAssociatedObject(self, @selector(labelname));
}

- (void)setLabelname:(NSString *)labelname{
    objc_setAssociatedObject(self, @selector(labelname), labelname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)must{
    return objc_getAssociatedObject(self, @selector(must));
}

- (void)setMust:(NSString *)must{
    objc_setAssociatedObject(self, @selector(must), must, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)bemulti{
    return objc_getAssociatedObject(self, @selector(bemulti));
}

- (void)setBemulti:(NSString *)bemulti{
    objc_setAssociatedObject(self, @selector(bemulti), bemulti, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)node{
    return objc_getAssociatedObject(self, @selector(node));
}

- (void)setNode:(id)node{
    objc_setAssociatedObject(self, @selector(node), node, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)browserid{
    return objc_getAssociatedObject(self, @selector(browserid));
}

- (void)setBrowserid:(NSString *)browserid{
    objc_setAssociatedObject(self, @selector(browserid), browserid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)datatype{
    return objc_getAssociatedObject(self, @selector(datatype));
}

- (void)setDatatype:(NSString *)datatype{
    objc_setAssociatedObject(self, @selector(datatype), datatype, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
