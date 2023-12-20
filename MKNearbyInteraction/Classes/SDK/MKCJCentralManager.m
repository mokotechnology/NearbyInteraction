//
//  MKCJCentralManager.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/07.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKCJCentralManager.h"

#import "MKBLEBaseCentralManager.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseLogManager.h"

#import "MKCJPeripheral.h"
#import "CBPeripheral+MKCJAdd.h"

NSString *const mk_cg_peripheralConnectStateChangedNotification = @"mk_cg_peripheralConnectStateChangedNotification";
NSString *const mk_cg_centralManagerStateChangedNotification = @"mk_cg_centralManagerStateChangedNotification";

static MKCJCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKCJCentralManager ()

@property (nonatomic, copy)void (^sucBlock)(CBPeripheral *peripheral);

@property (nonatomic, copy)void (^failedBlock)(NSError *error);

@property (nonatomic, assign)mk_cg_centralConnectStatus connectStatus;

@end

@implementation MKCJCentralManager

- (void)dealloc {
    NSLog(@"MKCJCentralManager销毁");
}

- (instancetype)init {
    if (self = [super init]) {
        [[MKBLEBaseCentralManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKCJCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKCJCentralManager new];
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
            if ([self.delegate respondsToSelector:@selector(mk_cg_receiveDevice:)]) {
                [self.delegate mk_cg_receiveDevice:dataModel];
            }
        });
    });
}

- (void)MKBLEBaseCentralManagerStartScan {
    if ([self.delegate respondsToSelector:@selector(mk_cg_startScan)]) {
        [self.delegate mk_cg_startScan];
    }
}

- (void)MKBLEBaseCentralManagerStopScan {
    if ([self.delegate respondsToSelector:@selector(mk_cg_stopScan)]) {
        [self.delegate mk_cg_stopScan];
    }
}

#pragma mark - MKBLEBaseCentralManagerStateProtocol
- (void)MKBLEBaseCentralManagerStateChanged:(MKCentralManagerState)centralManagerState {
    NSLog(@"蓝牙中心改变");
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_cg_centralManagerStateChangedNotification object:nil];
}

- (void)MKBLEBasePeripheralConnectStateChanged:(MKPeripheralConnectState)connectState {
    //连接成功的判断必须是发送密码成功之后
    if (connectState == MKPeripheralConnectStateUnknow) {
        self.connectStatus = mk_cg_centralConnectStatusUnknow;
    }else if (connectState == MKPeripheralConnectStateConnecting) {
        self.connectStatus = mk_cg_centralConnectStatusConnecting;
    }else if (connectState == MKPeripheralConnectStateConnectedFailed) {
        self.connectStatus = mk_cg_centralConnectStatusConnectedFailed;
    }else if (connectState == MKPeripheralConnectStateDisconnect) {
        self.connectStatus = mk_cg_centralConnectStatusDisconnect;
        
    }else if (connectState == MKPeripheralConnectStateConnected) {
        self.connectStatus = mk_cg_centralConnectStatusConnected;
        
    }
    NSLog(@"当前连接状态发生改变了:%@",@(connectState));
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_cg_peripheralConnectStateChangedNotification object:nil];
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
        mk_cg_messageId messageId = [self fetchMessageId:cmd];
        if (messageId == mk_cg_messageIdUnknow) {
            return;
        }
        if ([self.dataDelegate respondsToSelector:@selector(mk_cg_accessorySharedData:messageId:peripheral:)]) {
            [self.dataDelegate mk_cg_accessorySharedData:[value subdataWithRange:NSMakeRange(1, value.length - 1)]
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

- (mk_cg_centralManagerStatus )centralStatus {
    return ([MKBLEBaseCentralManager shared].centralStatus == MKCentralManagerStateEnable)
    ? mk_cg_centralManagerStatusEnable
    : mk_cg_centralManagerStatusUnable;
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
                                            characteristic:self.peripheral.cg_rxCharacteristic
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
    MKCJPeripheral *trackerPeripheral = [[MKCJPeripheral alloc] initWithPeripheral:peripheral];
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
        @"identify":peripheral.identifier.UUIDString,
        @"deviceName":(advDic[CBAdvertisementDataLocalNameKey] ? advDic[CBAdvertisementDataLocalNameKey] : @""),
        @"connectable":advDic[CBAdvertisementDataIsConnectable],
    };
}

- (mk_cg_messageId)fetchMessageId:(NSString *)cmd {
    if ([cmd isEqualToString:@"01"]) {
        return mk_cg_accessoryConfigurationData;
    }
    if ([cmd isEqualToString:@"02"]) {
        return mk_cg_accessoryUwbDidStart;
    }
    if ([cmd isEqualToString:@"03"]) {
        return mk_cg_accessoryUwbDidStop;
    }
    if ([cmd isEqualToString:@"04"]) {
        return mk_cg_accessoryPaired;
    }
    if ([cmd isEqualToString:@"0a"]) {
        return mk_cg_initialize;
    }
    if ([cmd isEqualToString:@"0b"]) {
        return mk_cg_configureAndStart;
    }
    if ([cmd isEqualToString:@"0c"]) {
        return mk_cg_stop;
    }
    if ([cmd isEqualToString:@"20"]) {
        return mk_cg_getDeviceStruct;
    }
    if ([cmd isEqualToString:@"21"]) {
        return mk_cg_setDeviceStruct;
    }
    if ([cmd isEqualToString:@"2f"]) {
        return mk_cg_iOSNotify;
    }
    return mk_cg_messageIdUnknow;
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
