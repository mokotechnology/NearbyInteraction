//
//  CBPeripheral+MKCJAdd.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "CBPeripheral+MKCJAdd.h"

#import <objc/runtime.h>

static const char *cg_scCharacteristicKey = "cg_scCharacteristicKey";
static const char *cg_rxCharacteristicKey = "cg_rxCharacteristicKey";
static const char *cg_txCharacteristicKey = "cg_txCharacteristicKey";

static const char *cg_txCharacteristicNotifySuccessKey = "cg_txCharacteristicNotifySuccessKey";

@implementation CBPeripheral (MKCJAdd)

- (void)cg_updateCharacterWithService:(CBService *)service {
    NSArray *characteristicList = service.characteristics;
    
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"2E938FD0-6A61-11ED-A1EB-0242AC120002"]]) {
        return;
    }
    //自定义
    for (CBCharacteristic *characteristic in characteristicList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E93941C-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &cg_scCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E93998A-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &cg_rxCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &cg_txCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)cg_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]]) {
        objc_setAssociatedObject(self, &cg_txCharacteristicNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)cg_connectSuccess {
    if (![objc_getAssociatedObject(self, &cg_txCharacteristicNotifySuccessKey) boolValue]) {
        return NO;
    }
    if (!self.cg_scCharacteristic || !self.cg_rxCharacteristic || !self.cg_txCharacteristic) {
        return NO;
    }
    
    return YES;
}

- (void)cg_setNil {
    objc_setAssociatedObject(self, &cg_scCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cg_rxCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cg_txCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cg_txCharacteristicNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (CBCharacteristic *)cg_scCharacteristic {
    return objc_getAssociatedObject(self, &cg_scCharacteristicKey);
}

- (CBCharacteristic *)cg_rxCharacteristic {
    return objc_getAssociatedObject(self, &cg_rxCharacteristicKey);
}

- (CBCharacteristic *)cg_txCharacteristic {
    return objc_getAssociatedObject(self, &cg_txCharacteristicKey);
}

@end
