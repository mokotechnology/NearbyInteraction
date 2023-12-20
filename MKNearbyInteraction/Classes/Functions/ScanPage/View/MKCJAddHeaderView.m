//
//  MKCJAddHeaderView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKCJAddHeaderView.h"

#import "MKMacroDefines.h"

#import "MKCJWaterWaveView.h"
#import "MKCJLoadingLabel.h"

@interface MKCJAddHeaderView ()

@property (nonatomic, strong)MKCJWaterWaveView *waveView;

@property (nonatomic, strong)MKCJLoadingLabel *msgLabel;

@property (nonatomic, strong)UIButton *closeButton;

@end

@implementation MKCJAddHeaderView

- (void)dealloc {
    NSLog(@"MKCJAddHeaderView销毁");
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
    if ([self.delegate respondsToSelector:@selector(cg_addHeaderCloseMethod)]) {
        [self.delegate cg_addHeaderCloseMethod];
    }
}

#pragma mark - Private method



#pragma mark - getter
- (MKCJLoadingLabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[MKCJLoadingLabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 120.f) / 2, 20.f, 85.f, MKFont(25.f).lineHeight)];
    }
    return _msgLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.frame.size.width - 10.f - 20.f, 20.f, 20.f, 20.f);
        [_closeButton setImage:LOADICON(@"MKNearbyInteraction", @"MKCJAddHeaderView", @"cj_close_icon.png") forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(closeButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (MKCJWaterWaveView *)waveView {
    if (!_waveView) {
        _waveView = [[MKCJWaterWaveView alloc] initWithFrame:self.bounds];
    }
    return _waveView;
}

@end
