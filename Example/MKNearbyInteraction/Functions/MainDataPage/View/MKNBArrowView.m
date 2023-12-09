//
//  MKNBArrowView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/4.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBArrowView.h"

#import "MKMacroDefines.h"

static const CGFloat imageSize = 200.f;

typedef NS_ENUM(NSInteger, MKNBAnimationType) {
    MKNBAnimationType_arc,      //圆弧
    MKNBAnimationType_point,    //缩放
};

@interface MKNBArrowView ()

@property (nonatomic, strong)UIImageView *arrowIcon;

@property (nonatomic, assign) CGFloat arcAngle;

@property (nonatomic, strong) CAShapeLayer *ringLayer;

/// 当弧度夹角位于-10°~10°之间时，不显示圆弧，显示缩放动画
@property (nonatomic, assign)MKNBAnimationType animationType;

@end

@implementation MKNBArrowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupArrowImageView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.animationType == MKNBAnimationType_arc) {
        //默认为圆弧
        [self drawCircle:rect];
        return;
    }
    //绘制缩放动画
    [self drawPoint:rect];
}

#pragma mark - Private method

#pragma mark - 绘制圆弧
- (void)drawCircle:(CGRect)rect {
    // 获取当前视图的上下文
    
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    
    CGPoint center = CGPointMake(centerX, centerY);
        
    // 计算圆弧的半径
    CGFloat radius = self.bounds.size.width / 2 - 30.0f;
    
    // 设置圆弧的起点和终点角度
    CGFloat startAngle = -M_PI_2;  // 正上方
    
    CGFloat arcStartAngle = startAngle;
    CGFloat arcEndAngle = startAngle;
    BOOL clockwise = NO;
    if (self.arcAngle >= 0) {
        arcStartAngle = startAngle + 0.1f;
        arcEndAngle = startAngle + self.arcAngle - 0.1f;
        
        clockwise = (self.arcAngle - 0.2f >= 0);
        
    }else {
        arcStartAngle = startAngle - 0.1;
        arcEndAngle = startAngle + self.arcAngle + 0.1f;
        
        clockwise = (self.arcAngle + 0.2f >= 0);
    }
    
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:arcStartAngle
                                                         endAngle:arcEndAngle
                                                        clockwise:clockwise];
    arcPath.lineWidth = 10.f;
    [[UIColor whiteColor] setStroke];
    arcPath.lineCapStyle = kCGLineCapRound;
    [arcPath stroke];
    
    // 计算起点和终点的圆心位置
    CGPoint startCenter = CGPointMake(centerX + radius * cos(startAngle), centerY + radius * sin(startAngle));
    CGPoint endCenter = CGPointMake(centerX + radius * cos(startAngle + self.arcAngle), centerY + radius * sin(startAngle + self.arcAngle));
    
    // 绘制起点的实心圆
    UIBezierPath *startCirclePath = [UIBezierPath bezierPathWithArcCenter:startCenter radius:10.0f startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [[UIColor whiteColor] setFill];
    [startCirclePath fill];
    
    // 绘制终点的实心圆
    UIBezierPath *endCirclePath = [UIBezierPath bezierPathWithArcCenter:endCenter radius:10.0f startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [endCirclePath fill];
}

- (CGPoint)pointOnArcWithCenter:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    CGFloat x = center.x + radius * cos(angle);
    CGFloat y = center.y + radius * sin(angle);
    return CGPointMake(x, y);
}

#pragma mark - 圆形缩放动画
- (void)drawPoint:(CGRect)rect {
    // 获取绘制上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat radius = CGRectGetWidth(self.bounds) / 2 - 30.0f;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 计算起点和终点的角度
    CGFloat startAngle = -M_PI_2;
    
    CGPoint startPoint = [self pointOnArcWithCenter:center radius:radius angle:startAngle];
    
    // 绘制白色实心圆点
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddArc(context, startPoint.x, startPoint.y, 10.f, 0, 2 * M_PI, YES);
    CGContextFillPath(context);
}

- (void)startAnimation {
    [self stopAnimation];
    self.ringLayer = [self createRingLayer];
    [self.layer addSublayer:self.ringLayer];
}
- (void)stopAnimation {
    if (!self.ringLayer) {
        return;
    }
    [self.ringLayer removeAllAnimations];
    [self.ringLayer removeFromSuperlayer];
    self.ringLayer = nil;
}

#pragma mark - Public method
- (void)setArrowRotationAngle:(CGFloat)angle {
    self.arcAngle = angle;
    self.arrowIcon.transform = CGAffineTransformMakeRotation(angle);
    
    BOOL smallAngle = NO;
    if (angle >= -0.2 && angle <= 0.2) {
        smallAngle = YES;
    }
    
    if (smallAngle && (self.animationType == MKNBAnimationType_arc)) {
        //需要圆点缩放
        [self setNeedsDisplay];
        [self startAnimation];
    }else if (!smallAngle && (self.animationType == MKNBAnimationType_point)) {
        //需要圆弧
        [self stopAnimation];
    }
    
    self.animationType = (smallAngle ? MKNBAnimationType_point : MKNBAnimationType_arc);
    
    if (self.animationType == MKNBAnimationType_arc) {
        [self setNeedsDisplay];
    }
}

#pragma mark - UI
- (void)setupArrowImageView {
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    
    self.arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(centerX - imageSize / 2, centerY - imageSize / 2, imageSize, imageSize)];
    self.arrowIcon.image = LOADIMAGE(@"white_Arrow", @"png");
    [self addSubview:self.arrowIcon];
}

#pragma mark - getter
- (CAShapeLayer *)createRingLayer {
    // Create the ring layer
    CGFloat radius = CGRectGetWidth(self.bounds) / 2 - 30.0f;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 计算起点和终点的角度
    CGFloat startAngle = -M_PI_2;
    
    CGPoint startPoint = [self pointOnArcWithCenter:center radius:radius angle:startAngle];
            
    CAShapeLayer *ringLayer = [CAShapeLayer layer];
    ringLayer.bounds = CGRectMake(0, 0, 20, 20);
    ringLayer.position = CGPointMake(startPoint.x, startPoint.y);
    ringLayer.fillColor = [UIColor clearColor].CGColor;
    ringLayer.strokeColor = [UIColor whiteColor].CGColor;
    ringLayer.lineWidth = 1.0;
    ringLayer.opacity = 1.0;
    ringLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 20, 20)].CGPath;
    
    // Create the ring animation
    CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    widthAnimation.fromValue = @(1.0);
    widthAnimation.toValue = @(50.0);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[widthAnimation, opacityAnimation];
    animationGroup.duration = 1.5;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [ringLayer addAnimation:animationGroup forKey:@"ringAnimation"];
    return ringLayer;
}

@end
