//
//  MKNBLoadingLabel.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKNBLoadingLabel : UILabel

// 创建Label
+ (MKNBLoadingLabel *)loadingLabel;

// 显示加载动画
- (void)showLoadingInView:(UIView *)view text:(NSString *)text;

// 隐藏
- (void)hide;

@end

NS_ASSUME_NONNULL_END
