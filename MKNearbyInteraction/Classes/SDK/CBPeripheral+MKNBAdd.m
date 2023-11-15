//
//  CBPeripheral+MKNBAdd.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "CBPeripheral+MKNBAdd.h"

#import <objc/runtime.h>

static const char *nb_scCharacteristicKey = "nb_scCharacteristicKey";
static const char *nb_rxCharacteristicKey = "nb_rxCharacteristicKey";
static const char *nb_txCharacteristicKey = "nb_txCharacteristicKey";

static const char *nb_txCharacteristicNotifySuccessKey = "nb_txCharacteristicNotifySuccessKey";

@implementation CBPeripheral (MKNBAdd)

- (void)nb_updateCharacterWithService:(CBService *)service {
    NSArray *characteristicList = service.characteristics;
    
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"2E938FD0-6A61-11ED-A1EB-0242AC120002"]]) {
        return;
    }
    //自定义
    for (CBCharacteristic *characteristic in characteristicList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E93941C-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &nb_scCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E93998A-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &nb_rxCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]]) {
            objc_setAssociatedObject(self, &nb_txCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)nb_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]]) {
        objc_setAssociatedObject(self, &nb_txCharacteristicNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)nb_connectSuccess {
    if (![objc_getAssociatedObject(self, &nb_txCharacteristicNotifySuccessKey) boolValue]) {
        return NO;
    }
    if (!self.nb_scCharacteristic || !self.nb_rxCharacteristic || !self.nb_txCharacteristic) {
        return NO;
    }
    
    return YES;
}

- (void)nb_setNil {
    objc_setAssociatedObject(self, &nb_scCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &nb_rxCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &nb_txCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &nb_txCharacteristicNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (CBCharacteristic *)nb_scCharacteristic {
    return objc_getAssociatedObject(self, &nb_scCharacteristicKey);
}

- (CBCharacteristic *)nb_rxCharacteristic {
    return objc_getAssociatedObject(self, &nb_rxCharacteristicKey);
}

- (CBCharacteristic *)nb_txCharacteristic {
    return objc_getAssociatedObject(self, &nb_txCharacteristicKey);
}

@end
