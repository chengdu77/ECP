//
//  MyView.m
//  九宫格
//
//  Created by mj on 14-9-9.
//  Copyright (c) 2014年 Mr.Li. All rights reserved.
//

#import "JGGView.h"
#import "JGGModel.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"

@interface JGGView ()
{
    JGGButtonBlock _myButtonBlock;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation JGGView

- (id)initWithFrame:(CGRect)frame Model:(JGGModel *)model MyButtonBlock:(JGGButtonBlock)myButtonBlock
{
    _myButtonBlock = myButtonBlock;
    _model = model;
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat W = 60;
        
        _imageView = [[UIImageView alloc] init];
        CGFloat imageViewX = 0;
        CGFloat imageViewY = 0;
        CGFloat imageViewW = W;
        CGFloat imageViewH = W;
        _imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
//        _imageView.contentMode = UIViewContentModeCenter;
        if (model.icon && !model.url) {
            _imageView.image = [UIImage imageNamed:model.icon];
        }else{
            [_imageView sd_setImageWithURL:[NSURL URLWithString:model.url]];
        }
        [self roundImageView:_imageView withColor:kALLBUTTON_COLOR];
        
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        CGFloat labelX = 0;
        CGFloat labelY = CGRectGetMaxY(_imageView.frame) + 10;
        CGFloat labelW = W;
        CGFloat labelH = 10;
        _label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        _label.font = [UIFont fontWithName:kFontName size:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.text = model.name;
        
        if (model.url) {
            CGSize size = [_label sizeThatFits:CGSizeMake(labelW, 1000)];
            
            CGRect sFrame =_label.frame;
            sFrame.size = size;
            _label.frame = sFrame;
            
            //计算出自适应的高度
             frame.size.height = size.height+40;
        }
        self.tag = model.id_;
        
        self.redPountLabel = [[UILabel alloc] init];
        self.redPountLabel.frame = CGRectMake((_imageView.frame.size.width-20)/2,(_imageView.frame.size.height-20)/2, 20, 20);
        [self.redPountLabel bringSubviewToFront:self];
        [self addSubview:self.redPountLabel];
        
        [self addSubview:_label];

    }
    return self;
}

// 定义成方法方便多个label调用 增加代码的复用性
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(320, 8000)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

- (void)tapButton
{
    if ([_button.titleLabel.text isEqualToString:@"已安装"]) {
        return;
    }
    [_button setTitle:@"已安装" forState:UIControlStateNormal];

    _myButtonBlock();
    
}

- (void)roundImageView:(UIImageView *)imageView withColor:(UIColor *)color{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
    imageView.layer.borderWidth = 1.0;
    if (!color) {
        color = [UIColor whiteColor];
    }
    imageView.layer.borderColor = color.CGColor;
}

@end
