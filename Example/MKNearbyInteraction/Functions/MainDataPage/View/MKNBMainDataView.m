//
//  MKNBMainDataView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/30.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBMainDataView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKNBCommonTools.h"

#import "MKNBCirclePatternView.h"
#import "MKNBArrowView.h"
#import "MKNBErrorView.h"

CGFloat const titleLabelTopffset = 50.f;
CGFloat const titleLabelLeftffset = 30.f;
CGFloat const titleLabelHeight = 40.f;
CGFloat const closeButtonWidth = 60.f;
CGFloat const closeButtonHeight = 60.f;
CGFloat const distanceValueLabelHeight = 55.f;
CGFloat const distanceLabelHeight = 50.f;
CGFloat const degreeViewHeight = 55.f;

#define degreeViewOffsetY (titleLabelTopffset + titleLabelHeight + 10.f)

@interface MKNBDegreeLabel : UIView

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *valueLabel;

@end

@implementation MKNBDegreeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.icon];
        [self addSubview:self.valueLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(15.f);
        make.top.mas_equalTo(2.f);
        make.height.mas_equalTo(15.f);
    }];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(1.f);
        make.right.mas_equalTo(-1.f);
        make.top.mas_equalTo(self.icon.mas_bottom).mas_offset(3.f);
        make.height.mas_equalTo([MKNBCommonTools font:13.f].lineHeight);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(1.f);
        make.right.mas_equalTo(-1.f);
        make.top.mas_equalTo(self.valueLabel.mas_bottom).mas_offset(3.f);
        make.height.mas_equalTo([MKNBCommonTools font:13.f].lineHeight);
    }];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = COLOR_WHITE_MACROS;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [MKNBCommonTools font:13.f];
    }
    return _msgLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = COLOR_WHITE_MACROS;
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [MKNBCommonTools font:13.f];
    }
    return _valueLabel;
}

@end



@interface MKNBMainDataView ()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UIView *degreeView;

@property (nonatomic, strong)MKNBDegreeLabel *azimuthLabel;

@property (nonatomic, strong)MKNBDegreeLabel *elevationLabel;

@property (nonatomic, strong)UILabel *distanceLabel;

@property (nonatomic, strong)UILabel *distanceValueLabel;

@property (nonatomic, strong)MKNBCirclePatternView *circleView;

@property (nonatomic, strong)MKNBArrowView *arrowView;

@property (nonatomic, strong)MKNBErrorView *errorView;

@property (nonatomic, strong)UILabel *errorLabel;

@property (nonatomic, strong)UIButton *closeButton;

@end

@implementation MKNBMainDataView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.degreeView];
        [self.degreeView addSubview:self.azimuthLabel];
        [self.degreeView addSubview:self.elevationLabel];
        
        [self addSubview:self.errorView];
        [self addSubview:self.circleView];
        [self addSubview:self.arrowView];
        
        [self.errorView addSubview:self.errorLabel];
        
        [self addSubview:self.distanceValueLabel];
        [self addSubview:self.distanceLabel];
        
        [self addSubview:self.closeButton];
        
        [self.errorView showSnow];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.right.mas_equalTo(-titleLabelLeftffset);
        make.top.mas_equalTo(titleLabelTopffset);
        make.height.mas_equalTo([MKNBCommonTools font:25.f].lineHeight);
    }];
    
    [self.degreeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.right.mas_equalTo(-titleLabelLeftffset);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(degreeViewHeight);
    }];
    [self.azimuthLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.width.mas_equalTo(60.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.elevationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.azimuthLabel.mas_right).mas_offset(titleLabelLeftffset);
        make.width.mas_equalTo(60.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.errorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.degreeView.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(kViewWidth);
    }];
    [self.circleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.errorView);
    }];
    [self.arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.errorView);
    }];
    
    [self.errorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.errorView.mas_centerX);
        make.width.mas_equalTo(200.f);
        make.centerY.mas_equalTo(self.errorView.mas_centerY);
        make.height.mas_equalTo(120.f);
    }];
    
    [self.distanceValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.right.mas_equalTo(-titleLabelLeftffset);
        make.top.mas_equalTo(self.errorView.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo([MKNBCommonTools font:40.f].lineHeight);
    }];
    [self.distanceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.right.mas_equalTo(-titleLabelLeftffset);
        make.top.mas_equalTo(self.distanceValueLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo([MKNBCommonTools font:50.f].lineHeight);
    }];
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabelLeftffset);
        make.width.mas_equalTo(closeButtonWidth);
        make.top.mas_equalTo(self.distanceLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(closeButtonHeight);
    }];
}

#pragma mark - Public method
- (void)updateErrorMsg:(NSString *)error {
    NSString *msg = (ValidStr(error) ? error : @"The signal is weak, please move your phone or device.");
    self.errorLabel.text = msg;
}

- (void)updateAzimuth:(NSString *)azimuth elevation:(NSString *)elevation {
    self.azimuthLabel.valueLabel.text = azimuth;
    self.elevationLabel.valueLabel.text = elevation;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_WHITE_MACROS;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        
        _titleLabel.font = [MKNBCommonTools font:25.f];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIView *)degreeView {
    if (!_degreeView) {
        _degreeView = [[UIView alloc] init];
    }
    return _degreeView;
}

- (MKNBDegreeLabel *)azimuthLabel {
    if (!_azimuthLabel) {
        _azimuthLabel = [[MKNBDegreeLabel alloc] init];
        _azimuthLabel.msgLabel.text = @"azimuth";
        _azimuthLabel.icon.image = LOADIMAGE(@"azimuth_icon", @"png");
        _azimuthLabel.valueLabel.text = @"-";
    }
    return _azimuthLabel;
}

- (MKNBDegreeLabel *)elevationLabel {
    if (!_elevationLabel) {
        _elevationLabel = [[MKNBDegreeLabel alloc] init];
        _elevationLabel.msgLabel.text = @"elevation";
        _elevationLabel.icon.image = LOADIMAGE(@"elevation_icon", @"png");
        _elevationLabel.valueLabel.text = @"-";
    }
    return _elevationLabel;
}

- (MKNBCirclePatternView *)circleView {
    if (!_circleView) {
        _circleView = [[MKNBCirclePatternView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewWidth)];
        _circleView.hidden = YES;
    }
    return _circleView;
}

- (MKNBArrowView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[MKNBArrowView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewWidth)];
        _arrowView.hidden = YES;
    }
    return _arrowView;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.textColor = COLOR_WHITE_MACROS;
        _errorLabel.font = [MKNBCommonTools font:20.f];
        _errorLabel.numberOfLines = 0;
    }
    return _errorLabel;
}

- (MKNBErrorView *)errorView {
    if (!_errorView) {
        _errorView = [[MKNBErrorView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kViewWidth)];
        _errorView.snowImage  = LOADIMAGE(@"snow_white_icon", @"png");
        _errorView.birthRate  = 20.f;
        _errorView.gravity    = 5.f;
        _errorView.snowColor  = [UIColor whiteColor];
        
        CALayer *layer    = [CALayer layer];
        layer.anchorPoint = CGPointMake(0, 0);                          // 重置锚点
        layer.bounds      = CGRectMake(0, 0, kViewWidth, kViewWidth);  // 设置尺寸
        UIImage *image = LOADIMAGE(@"snow_black_icon", @"png");
        if (image) {
            layer.contents = (__bridge id)(image.CGImage);
        }
        
        _errorView.layer.mask = layer;
    }
    return _errorView;
}

- (UILabel *)distanceValueLabel {
    if (!_distanceValueLabel) {
        _distanceValueLabel = [[UILabel alloc] init];
        _distanceValueLabel.textColor = COLOR_WHITE_MACROS;
        _distanceValueLabel.textAlignment = NSTextAlignmentLeft;
        _distanceValueLabel.font = [MKNBCommonTools font:40.f];
    }
    return _distanceValueLabel;
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textColor = COLOR_WHITE_MACROS;
        _distanceLabel.textAlignment = NSTextAlignmentLeft;
        _distanceLabel.font = [MKNBCommonTools font:50.f];
    }
    return _distanceLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:LOADIMAGE(@"closeIcon", @"png") forState:UIControlStateNormal];
        [_closeButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_closeButton.titleLabel setFont:MKFont(13.f)];
    }
    return _closeButton;
}

@end
