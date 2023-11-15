//
//  MKNBCentralManager.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKNBCentralManager.h"

#import "MKBLEBaseCentralManager.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseLogManager.h"

#import "MKNBPeripheral.h"
#import "CBPeripheral+MKNBAdd.h"

NSString *const mk_nb_peripheralConnectStateChangedNotification = @"mk_nb_peripheralConnectStateChangedNotification";
NSString *const mk_nb_centralManagerStateChangedNotification = @"mk_nb_centralManagerStateChangedNotification";

NSString *const mk_nb_deviceDisconnectTypeNotification = @"mk_nb_deviceDisconnectTypeNotification";

static MKNBCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKNBCentralManager ()

@property (nonatomic, copy)void (^sucBlock)(CBPeripheral *peripheral);

@property (nonatomic, copy)void (^failedBlock)(NSError *error);

@property (nonatomic, assign)mk_nb_centralConnectStatus connectStatus;

@end

@implementation MKNBCentralManager

- (void)dealloc {
    NSLog(@"MKNBCentralManager销毁");
}

- (instancetype)init {
    if (self = [super init]) {
        [[MKBLEBaseCentralManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKNBCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKNBCentralManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    [MKBLEBaseCentralManager singleDealloc];
    manager = nil;
    onceToken = 0;
}

+ (void)removeFromCentralList {
    [[MKBLEBaseCentralManager shared] removeDataManager:manager];
    manager = nil;
    onceToken = 0;
}

#pragma mark - MKBLEBaseScanProtocol
- (void)MKBLEBaseCentralManagerDiscoverPeripheral:(CBPeripheral *)peripheral
                                advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                                             RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%@",advertisementData);
        NSDictionary *dataModel = [self parseModelWithRssi:RSSI advDic:advertisementData peripheral:peripheral];
        if (!MKValidDict(dataModel)) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(mk_nb_receiveDevice:)]) {
                [self.delegate mk_nb_receiveDevice:dataModel];
            }
        });
    });
}

- (void)MKBLEBaseCentralManagerStartScan {
    if ([self.delegate respondsToSelector:@selector(mk_nb_startScan)]) {
        [self.delegate mk_nb_startScan];
    }
}

- (void)MKBLEBaseCentralManagerStopScan {
    if ([self.delegate respondsToSelector:@selector(mk_nb_stopScan)]) {
        [self.delegate mk_nb_stopScan];
    }
}

#pragma mark - MKBLEBaseCentralManagerStateProtocol
- (void)MKBLEBaseCentralManagerStateChanged:(MKCentralManagerState)centralManagerState {
    NSLog(@"蓝牙中心改变");
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_nb_centralManagerStateChangedNotification object:nil];
}

- (void)MKBLEBasePeripheralConnectStateChanged:(MKPeripheralConnectState)connectState {
    //连接成功的判断必须是发送密码成功之后
    if (connectState == MKPeripheralConnectStateUnknow) {
        self.connectStatus = mk_nb_centralConnectStatusUnknow;
    }else if (connectState == MKPeripheralConnectStateConnecting) {
        self.connectStatus = mk_nb_centralConnectStatusConnecting;
    }else if (connectState == MKPeripheralConnectStateConnectedFailed) {
        self.connectStatus = mk_nb_centralConnectStatusConnectedFailed;
    }else if (connectState == MKPeripheralConnectStateDisconnect) {
        self.connectStatus = mk_nb_centralConnectStatusDisconnect;
        
    }else if (connectState == MKPeripheralConnectStateConnected) {
        self.connectStatus = mk_nb_centralConnectStatusConnected;
        
    }
    NSLog(@"当前连接状态发生改变了:%@",@(connectState));
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_nb_peripheralConnectStateChangedNotification object:nil];
}

#pragma mark - MKBLEBaseCentralManagerProtocol
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++接收数据出错");
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2E939AF2-6A61-11ED-A1EB-0242AC120002"]]) {
        NSData *value = characteristic.value;
        NSString *cmd = [MKBLEBaseSDKAdopter hexStringFromData:[value subdataWithRange:NSMakeRange(0, 1)]];
        mk_nb_messageId messageId = [self fetchMessageId:cmd];
        if (messageId == mk_nb_messageIdUnknow) {
            return;
        }
        if ([self.dataDelegate respondsToSelector:@selector(mk_nb_accessorySharedData:messageId:peripheral:)]) {
            [self.dataDelegate mk_nb_accessorySharedData:[value subdataWithRange:NSMakeRange(1, value.length - 1)]
                                               messageId:messageId
                                              peripheral:peripheral];
        }
        return;
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++发送数据出错");
        return;
    }
    
}

#pragma mark - public method
- (CBCentralManager *)centralManager {
    return [MKBLEBaseCentralManager shared].centralManager;
}

- (CBPeripheral *)peripheral {
    return [MKBLEBaseCentralManager shared].peripheral;
}

- (mk_nb_centralManagerStatus )centralStatus {
    return ([MKBLEBaseCentralManager shared].centralStatus == MKCentralManagerStateEnable)
    ? mk_nb_centralManagerStatusEnable
    : mk_nb_centralManagerStatusUnable;
}

- (void)startScan {
    [[MKBLEBaseCentralManager shared] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"2E938FD0-6A61-11ED-A1EB-0242AC120002"]] options:nil];
}

- (void)stopScan {
    [[MKBLEBaseCentralManager shared] stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
                 sucBlock:(void (^)(CBPeripheral * _Nonnull))sucBlock
              failedBlock:(void (^)(NSError * error))failedBlock {
    if (!peripheral) {
        [MKBLEBaseSDKAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self connectPeripheral:peripheral successBlock:^(CBPeripheral *peripheral) {
        __strong typeof(self) sself = weakSelf;
        sself.sucBlock = nil;
        sself.failedBlock = nil;
        if (sucBlock) {
            sucBlock(peripheral);
        }
    } failedBlock:^(NSError *error) {
        __strong typeof(self) sself = weakSelf;
        sself.sucBlock = nil;
        sself.failedBlock = nil;
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)disconnect {
    [[MKBLEBaseCentralManager shared] disconnect];
}

- (void)sendData:(NSString *)data {
    [[MKBLEBaseCentralManager shared] sendDataToPeripheral:data
                                            characteristic:self.peripheral.nb_rxCharacteristic
                                                      type:CBCharacteristicWriteWithResponse];
}

#pragma mark - password method
- (void)connectPeripheral:(CBPeripheral *)peripheral
             successBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    self.sucBlock = nil;
    self.sucBlock = sucBlock;
    self.failedBlock = nil;
    self.failedBlock = failedBlock;
    MKNBPeripheral *trackerPeripheral = [[MKNBPeripheral alloc] initWithPeripheral:peripheral];
    [[MKBLEBaseCentralManager shared] connectDevice:trackerPeripheral
                                           sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        if (self.sucBlock) {
            self.sucBlock(peripheral);
        }
    }
                                        failedBlock:failedBlock];
}

#pragma mark - task method

#pragma mark - private method
- (NSDictionary *)parseModelWithRssi:(NSNumber *)rssi
                              advDic:(NSDictionary *)advDic
                          peripheral:(CBPeripheral *)peripheral {
    if ([rssi integerValue] == 127 || !MKValidDict(advDic) || !peripheral) {
        return @{};
    }
    return @{
        @"rssi":rssi,
        @"peripheral":peripheral,
        @"deviceName":(advDic[CBAdvertisementDataLocalNameKey] ? advDic[CBAdvertisementDataLocalNameKey] : @""),
        @"connectable":advDic[CBAdvertisementDataIsConnectable],
    };
}

- (mk_nb_messageId)fetchMessageId:(NSString *)cmd {
    if ([cmd isEqualToString:@"01"]) {
        return mk_nb_accessoryConfigurationData;
    }
    if ([cmd isEqualToString:@"02"]) {
        return mk_nb_accessoryUwbDidStart;
    }
    if ([cmd isEqualToString:@"03"]) {
        return mk_nb_accessoryUwbDidStop;
    }
    if ([cmd isEqualToString:@"04"]) {
        return mk_nb_accessoryPaired;
    }
    if ([cmd isEqualToString:@"0a"]) {
        return mk_nb_initialize;
    }
    if ([cmd isEqualToString:@"0b"]) {
        return mk_nb_configureAndStart;
    }
    if ([cmd isEqualToString:@"0c"]) {
        return mk_nb_stop;
    }
    if ([cmd isEqualToString:@"20"]) {
        return mk_nb_getDeviceStruct;
    }
    if ([cmd isEqualToString:@"21"]) {
        return mk_nb_setDeviceStruct;
    }
    if ([cmd isEqualToString:@"2f"]) {
        return mk_nb_iOSNotify;
    }
    return mk_nb_messageIdUnknow;
}

- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.NBCentralManager"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKBLEBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

@end
