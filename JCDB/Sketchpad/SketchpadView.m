//
//  SketchpadView.m
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//


#import "SketchpadView.h"

@interface SketchpadView (){
    CGPoint _start;
    CGPoint _move;
    CGMutablePathRef _path;
    NSMutableArray *_pathArray;
    CGFloat _lineWidth;
    UIColor *_color;
}
@property (nonatomic,assign)CGFloat lineWidth;
@property (nonatomic,strong)UIColor *color;
@property (nonatomic,strong)NSMutableArray *pathArray;

@end

@implementation SketchpadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        _move = CGPointMake(0, 0);
        _start = CGPointMake(0, 0);
        _lineWidth = 2;
        _color = [UIColor blackColor];
        _pathArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // 获取图形上下文
   CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawPicture:context]; //画图
}

- (void)drawPicture:(CGContextRef)context{
  
    for (NSArray * attribute in _pathArray) {
        //将路径添加到上下文中
        CGPathRef pathRef = (__bridge CGPathRef)(attribute[0]);
        CGContextAddPath(context, pathRef);
        //设置上下文属性
        [attribute[1] setStroke];
        CGContextSetLineWidth(context, [attribute[2] floatValue]);
        //绘制线条
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    _path = CGPathCreateMutable(); //创建路径
    
    NSArray *attributeArry = @[(__bridge id)(_path),_color,[NSNumber numberWithFloat:_lineWidth]];

    [_pathArray addObject:attributeArry]; //路径及属性数组数组
    _start = [touch locationInView:self]; //起始点
   CGPathMoveToPoint(_path, NULL,_start.x, _start.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //    释放路径
    CGPathRelease(_path);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    _move = [touch locationInView:self];
    //将点添加到路径上
    CGPathAddLineToPoint(_path, NULL, _move.x, _move.y);

    [self setNeedsDisplay];
}

- (UIImage *)getImageInfo{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    //从上下文中获取图片
    [self.layer renderInContext:ctx];
    UIImage * image =UIGraphicsGetImageFromCurrentImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    return image;
}
//清屏
- (void)clearAll {
    [self.pathArray removeAllObjects];
    [self setNeedsDisplay]; //删除所有线条
    
}

- (NSInteger)count{
    
    return self.pathArray.count;
}

@end
