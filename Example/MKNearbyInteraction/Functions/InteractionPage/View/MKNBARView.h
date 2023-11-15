//
//  MKNBARView.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/13.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ARSession;
@interface MKNBARView : UIView

- (ARSession *)arSession;

- (void)createARObject;

- (void)updateMatrix:(SCNMatrix4)matrix;

- (void)start;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
