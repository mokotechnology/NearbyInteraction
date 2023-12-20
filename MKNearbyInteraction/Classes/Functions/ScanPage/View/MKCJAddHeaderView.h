//
//  MKCJAddHeaderView.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKCJAddHeaderViewDelegate <NSObject>

- (void)cg_addHeaderCloseMethod;

@end

@interface MKCJAddHeaderView : UIView

@property (nonatomic, weak)id <MKCJAddHeaderViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
