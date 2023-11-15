//
//  MKNBNearbyInteractionHeader.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/11.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBNearbyInteractionHeader.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "UIImage+Rotation.h"

@implementation MKNBNearbyInteractionHeaderModel
@end

@interface MKNBNearbyInteractionHeaderSubView : UIView

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *valueLabel;

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKNBNearbyInteractionHeaderSubView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.valueLabel];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(30.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2.f);
        make.right.mas_equalTo(-2.f);
        make.top.mas_equalTo(self.icon.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2.f);
        make.right.mas_equalTo(-2.f);
        make.top.mas_equalTo(self.valueLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
}

#pragma mark - getter
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = DEFAULT_TEXT_COLOR;
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = MKFont(12.f);
        _valueLabel.text = @"-";
    }
    return _valueLabel;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(12.f);
    }
    return _msgLabel;
}

@end

@interface MKNBNearbyInteractionHeader ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)MKNBNearbyInteractionHeaderSubView *distanceView;

@property (nonatomic, strong)MKNBNearbyInteractionHeaderSubView *azimuthView;

@property (nonatomic, strong)MKNBNearbyInteractionHeaderSubView *elevationView;

@end

@implementation MKNBNearbyInteractionHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.switchButton];
        [self addSubview:self.distanceView];
        [self addSubview:self.azimuthView];
        [self addSubview:self.elevationView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.switchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(30.f);
    }];
    
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(self.switchButton.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.switchButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    
    [self.distanceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.width.mas_equalTo(80.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(100.f);
    }];
    [self.azimuthView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(80.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(100.f);
    }];
    [self.elevationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30.f);
        make.width.mas_equalTo(80.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(100.f);
    }];
}

#pragma mark - event method
- (void)switchButtonPressed {
    self.switchButton.selected = !self.switchButton.selected;
    UIImage *icon = (self.switchButton.selected ? LOADIMAGE(@"switchSelectedIcon", @"png") : LOADIMAGE(@"switchUnselectedIcon", @"png"));
    [self.switchButton setImage:icon forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(feedbackStatusChanged:)]) {
        [self.delegate feedbackStatusChanged:self.switchButton.selected];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKNBNearbyInteractionHeaderModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKNBNearbyInteractionHeaderModel.class]) {
        return;
    }
    if (ValidStr(_dataModel.distance)) {
        self.distanceView.valueLabel.text = _dataModel.distance;
    }else {
        self.distanceView.valueLabel.text = @"-";
    }
    if (ValidStr(_dataModel.azimuth)) {
        self.azimuthView.valueLabel.text = _dataModel.azimuth;
    }else {
        self.azimuthView.valueLabel.text = @"-";
    }
    if (ValidStr(_dataModel.elevation)) {
        self.elevationView.valueLabel.text = _dataModel.elevation;
    }else {
        self.elevationView.valueLabel.text = @"-";
    }
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Audio-haptic Feedback";
    }
    return _msgLabel;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:LOADIMAGE(@"switchUnselectedIcon", @"png") forState:UIControlStateNormal];
        [_switchButton addTarget:self
                          action:@selector(switchButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (MKNBNearbyInteractionHeaderSubView *)distanceView {
    if (!_distanceView) {
        _distanceView = [[MKNBNearbyInteractionHeaderSubView alloc] init];
        _distanceView.icon.image = [UIImage svgImageNamed:@"distance_icon.svg"];
        
        _distanceView.msgLabel.text = @"distance";
    }
    return _distanceView;
}

- (MKNBNearbyInteractionHeaderSubView *)azimuthView {
    if (!_azimuthView) {
        _azimuthView = [[MKNBNearbyInteractionHeaderSubView alloc] init];
        _azimuthView.icon.image = [UIImage svgImageNamed:@"azimuth_icon.svg"];
        _azimuthView.msgLabel.text = @"azimuth";
    }
    return _azimuthView;
}

- (MKNBNearbyInteractionHeaderSubView *)elevationView {
    if (!_elevationView) {
        _elevationView = [[MKNBNearbyInteractionHeaderSubView alloc] init];
        _elevationView.icon.image = [UIImage svgImageNamed:@"elevation_icon.svg"];
        _elevationView.msgLabel.text = @"elevation";
    }
    return _elevationView;
}

@end
