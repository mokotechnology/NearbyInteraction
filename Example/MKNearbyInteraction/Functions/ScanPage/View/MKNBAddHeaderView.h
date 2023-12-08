//
//  MKNBAddHeaderView.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKNBAddHeaderViewDelegate <NSObject>

- (void)nb_addHeaderCloseMethod;

@end

@interface MKNBAddHeaderView : UIView

@property (nonatomic, weak)id <MKNBAddHeaderViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
