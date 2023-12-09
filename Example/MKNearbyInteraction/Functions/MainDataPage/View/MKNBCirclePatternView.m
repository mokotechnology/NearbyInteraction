#import "MKNBCirclePatternView.h"

#import <QuartzCore/QuartzCore.h>

#import "MKNBArrowView.h"

@interface MKNBCirclePatternView ()

@property (nonatomic, strong) CAShapeLayer *ringLayer;

@end

@implementation MKNBCirclePatternView

- (void)dealloc {
    NSLog(@"MKNBCirclePatternView销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAnimation)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
        
    // 获取绘制上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    // 绘制白色实心圆点
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddArc(context, center.x, center.y, 75.f, 0, 2 * M_PI, YES);
    CGContextFillPath(context);
}

#pragma mark - Public method
- (void)startAnimation {
    [self stopAnimation];
    [self createAnimation];
}
- (void)stopAnimation {
    if (!self.ringLayer) {
        return;
    }
    [self.ringLayer removeAllAnimations];
    [self.ringLayer removeFromSuperlayer];
    self.ringLayer = nil;
}

#pragma mark - Private method
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    [self createAnimation];
}

- (void)createAnimation {
    // Create the ring layer
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    CGFloat radius = 75.0;
        
    self.ringLayer = [CAShapeLayer layer];
    self.ringLayer.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    self.ringLayer.position = CGPointMake(centerX, centerY);
    self.ringLayer.fillColor = [UIColor clearColor].CGColor;
    self.ringLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.ringLayer.lineWidth = 1.0;
    self.ringLayer.opacity = 1.0;
    self.ringLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius * 2, radius * 2)].CGPath;
    [self.layer addSublayer:self.ringLayer];
    
    // Create the ring animation
    CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    widthAnimation.fromValue = @(1.0);
    widthAnimation.toValue = @(300.0);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[widthAnimation, opacityAnimation];
    animationGroup.duration = 1.5;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.ringLayer addAnimation:animationGroup forKey:@"ringAnimation"];
}

@end
