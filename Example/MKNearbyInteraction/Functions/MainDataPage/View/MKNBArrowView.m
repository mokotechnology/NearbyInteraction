//
//  MKNBArrowView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/4.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBArrowView.h"

#import "MKMacroDefines.h"

@interface MKNBArrowView ()

@property (nonatomic, strong)UIImageView *arrowIcon;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

@end

@implementation MKNBArrowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupArrowImageView];
    }
    return self;
}

- (void)setupArrowImageView {
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    CGFloat imageSize = 200.f;
    
    self.arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(centerX - imageSize / 2, centerY - imageSize / 2, imageSize, imageSize)];
    self.arrowIcon.image = LOADIMAGE(@"white_Arrow", @"png");
    [self addSubview:self.arrowIcon];
}

- (void)setArrowRotationAngle:(CGFloat)angle {
    self.arrowIcon.transform = CGAffineTransformMakeRotation(angle);
}

@end
