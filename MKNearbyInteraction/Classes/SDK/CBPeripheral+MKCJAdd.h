//
//  CBPeripheral+MKCJAdd.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKCJAdd)

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *cg_scCharacteristic;

/// WriteWithoutResponse/Write
@property (nonatomic, strong, readonly)CBCharacteristic *cg_rxCharacteristic;

/// N
@property (nonatomic, strong, readonly)CBCharacteristic *cg_txCharacteristic;

- (void)cg_updateCharacterWithService:(CBService *)service;

- (void)cg_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)cg_connectSuccess;

- (void)cg_setNil;

@end

NS_ASSUME_NONNULL_END
