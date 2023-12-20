//
//  MKCJPeripheral.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKCJPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "CBPeripheral+MKCJAdd.h"

@interface MKCJPeripheral ()

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

@implementation MKCJPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)discoverServices {
    NSArray *services = @[[CBUUID UUIDWithString:@"2E938FD0-6A61-11ED-A1EB-0242AC120002"]]; //自定义
    [self.peripheral discoverServices:services];
}

- (void)discoverCharacteristics {
    for (CBService *service in self.peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"2E938FD0-6A61-11ED-A1EB-0242AC120002"]]) {
            NSArray *characteristics = @[[CBUUID UUIDWithString:@"2E93941C-6A61-11ED-A1EB-0242AC120002"],
                                         [CBUUID UUIDWithString:@"2E93998A-6A61-11ED-A1EB-0242AC120002"],
                                         [CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]];
            [self.peripheral discoverCharacteristics:characteristics forService:service];
        }
    }
}

- (void)updateCharacterWithService:(CBService *)service {
    [self.peripheral cg_updateCharacterWithService:service];
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    [self.peripheral cg_updateCurrentNotifySuccess:characteristic];
}

- (BOOL)connectSuccess {
    return [self.peripheral cg_connectSuccess];
}

- (void)setNil {
    [self.peripheral cg_setNil];
}

@end
