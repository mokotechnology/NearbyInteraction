//
//  MKNBAddHeaderView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBAddHeaderView.h"

#import "MKMacroDefines.h"

#import "MKNBCommonTools.h"

#import "MKNBWaterWaveView.h"
#import "MKNBLoadingLabel.h"

@interface MKNBAddHeaderView ()

@property (nonatomic, strong)MKNBWaterWaveView *waveView;

@property (nonatomic, strong)MKNBLoadingLabel *msgLabel;

@property (nonatomic, strong)UIButton *closeButton;

@end

@implementation MKNBAddHeaderView

- (void)dealloc {
    NSLog(@"MKNBAddHeaderView销毁");
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.waveView];
        
        [self.waveView addSubview:self.msgLabel];
        [self.waveView addSubview:self.closeButton];
        
        [self.msgLabel showLoadingInView:self.waveView text:@"Scanning..."];
    }
    return self;
}

#pragma mark - event method
- (void)closeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(nb_addHeaderCloseMethod)]) {
        [self.delegate nb_addHeaderCloseMethod];
    }
}

#pragma mark - Private method



#pragma mark - getter
- (MKNBLoadingLabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[MKNBLoadingLabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 120.f) / 2, 20.f, 85.f, [MKNBCommonTools font:25.f].lineHeight)];
    }
    return _msgLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.frame.size.width - 10.f - 20.f, 20.f, 20.f, 20.f);
        [_closeButton setImage:LOADIMAGE(@"close_icon", @"png") forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(closeButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (MKNBWaterWaveView *)waveView {
    if (!_waveView) {
        _waveView = [[MKNBWaterWaveView alloc] initWithFrame:self.bounds];
    }
    return _waveView;
}

@end
