//
//  Target_NearbyInteraction_Module.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/2/16.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "Target_NearbyInteraction_Module.h"

#import "MKCJScanController.h"

@implementation Target_NearbyInteraction_Module

- (UIViewController *)Action_NearbyInteraction_ScanPage:(NSDictionary *)params {
    MKCJScanController *vc = [[MKCJScanController alloc] init];
    return vc;
}

@end
