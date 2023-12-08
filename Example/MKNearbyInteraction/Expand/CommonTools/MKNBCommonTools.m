//
//  MKNBCommonTools.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBCommonTools.h"

#import "MKMacroDefines.h"

@implementation MKNBCommonTools

+ (UIFont *)font:(CGFloat)size {
    UIFont *customFont = [UIFont fontWithName:@"Helvetica-Bold" size:size];
    if (customFont) {
        return customFont;
    }
    return MKFont(size);
}

@end
