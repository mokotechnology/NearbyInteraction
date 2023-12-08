//
//  MKNBLoadingLabel.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBLoadingLabel.h"

#import "MKNBCommonTools.h"

@implementation MKNBLoadingLabel

+ (MKNBLoadingLabel *)loadingLabel
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textColor = [UIColor blueColor];
        self.font = [MKNBCommonTools font:25.f];
    }
    return self;
}


- (void)showLoadingInView:(UIView *)view text:(NSString *)text
{
    [view addSubview:self];
 
    if (text) {
        self.text = text;
    }
    
    
    [self sizeToFit];
    
    // 创建渐变效果的layer
    CAGradientLayer *graLayer = [CAGradientLayer layer];
    graLayer.frame = self.bounds;
    graLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor,
                        (__bridge id)[UIColor yellowColor].CGColor,
                        (__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor];
    
    graLayer.startPoint = CGPointMake(0, 0.1);//设置渐变方向起点
    graLayer.endPoint = CGPointMake(1, 0);  //设置渐变方向终点
    graLayer.locations = @[@(0.0), @(0.0), @(0.1)]; //colors中各颜色对应的初始渐变点
    
    // 创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.duration = 1.0f;
    animation.toValue = @[@(0.9), @(1.0), @(1.0)];
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    animation.fillMode = kCAFillModeForwards;
    [graLayer addAnimation:animation forKey:@"xindong"];
    
    // 将graLayer设置成textLabel的遮罩
    self.layer.mask = graLayer;
}

- (void)hide
{
    [self removeFromSuperview];
}

@end
