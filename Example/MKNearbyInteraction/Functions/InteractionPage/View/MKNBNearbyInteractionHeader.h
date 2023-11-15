//
//  MKNBNearbyInteractionHeader.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/11.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKNBNearbyInteractionHeaderModel : NSObject

@property (nonatomic, copy)NSString *distance;

@property (nonatomic, copy)NSString *azimuth;

@property (nonatomic, copy)NSString *elevation;

@end

@protocol MKNBNearbyInteractionHeaderDelegate <NSObject>

- (void)feedbackStatusChanged:(BOOL)isOn;

@end

@interface MKNBNearbyInteractionHeader : UIView

@property (nonatomic, strong)MKNBNearbyInteractionHeaderModel *dataModel;

@property (nonatomic, weak)id <MKNBNearbyInteractionHeaderDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
