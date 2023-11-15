//
//  UIImage+Rotation.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/10.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "UIImage+Rotation.h"

#import <SVGKit/SVGKit.h>

@implementation UIImage (Rotation)

+ (UIImage *)svgImageNamed:(NSString *)imageName {
    SVGKImage *svgImage = [SVGKImage imageNamed:imageName];
    return svgImage.UIImage;
}

- (UIImage *)rotateWithRadians:(float)radians {
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0, 0, self.size.width, self.size.height), CGAffineTransformMakeRotation(0));
    CGSize newSize = CGSizeMake(floor(newRect.size.width), floor(newRect.size.height));

    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Move origin to middle
    CGContextTranslateCTM(context, newSize.width / 2, newSize.height / 2);
    // Rotate around middle
    CGContextRotateCTM(context, radians);
    // Draw the image at its center
    [self drawInRect:CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
