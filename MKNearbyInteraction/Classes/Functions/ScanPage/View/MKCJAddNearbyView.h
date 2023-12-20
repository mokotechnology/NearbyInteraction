//
//  MKCJAddNearbyView.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/27.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKCJAddNearbyView : UIView

- (void)showViewWithConnectBlock:(void (^)(CBPeripheral *peripheral, NSString *deviceName))connectBlock;

/// 让pickView消失
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
