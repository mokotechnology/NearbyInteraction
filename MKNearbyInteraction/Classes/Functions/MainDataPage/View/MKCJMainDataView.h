//
//  MKCJMainDataView.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/30.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MKCJCirclePatternView,MKCJArrowView,MKCJErrorView;
@interface MKCJMainDataView : UIView

@property (nonatomic, strong, readonly)UILabel *titleLabel;

@property (nonatomic, strong, readonly)UIView *degreeView;

@property (nonatomic, strong, readonly)UILabel *distanceLabel;

@property (nonatomic, strong, readonly)UILabel *distanceValueLabel;

@property (nonatomic, strong, readonly)MKCJCirclePatternView *circleView;

@property (nonatomic, strong, readonly)MKCJArrowView *arrowView;

@property (nonatomic, strong, readonly)MKCJErrorView *errorView;

@property (nonatomic, strong, readonly)UIButton *closeButton;

- (void)updateErrorMsg:(NSString *)error;

- (void)updateAzimuth:(NSString *)azimuth elevation:(NSString *)elevation;

@end

NS_ASSUME_NONNULL_END
