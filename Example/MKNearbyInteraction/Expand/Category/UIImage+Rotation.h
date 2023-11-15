//
//  UIImage+Rotation.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/10.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Rotation)

+ (UIImage *)svgImageNamed:(NSString *)imageName;

- (UIImage *)rotateWithRadians:(float)radians;

@end

NS_ASSUME_NONNULL_END
