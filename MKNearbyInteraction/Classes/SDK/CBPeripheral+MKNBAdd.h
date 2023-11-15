//
//  CBPeripheral+MKNBAdd.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKNBAdd)

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *nb_scCharacteristic;

/// WriteWithoutResponse/Write
@property (nonatomic, strong, readonly)CBCharacteristic *nb_rxCharacteristic;

/// N
@property (nonatomic, strong, readonly)CBCharacteristic *nb_txCharacteristic;

- (void)nb_updateCharacterWithService:(CBService *)service;

- (void)nb_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)nb_connectSuccess;

- (void)nb_setNil;

@end

NS_ASSUME_NONNULL_END
