
typedef NS_ENUM(NSInteger, mk_cg_centralConnectStatus) {
    mk_cg_centralConnectStatusUnknow,                                           //未知状态
    mk_cg_centralConnectStatusConnecting,                                       //正在连接
    mk_cg_centralConnectStatusConnected,                                        //连接成功
    mk_cg_centralConnectStatusConnectedFailed,                                  //连接失败
    mk_cg_centralConnectStatusDisconnect,
};

typedef NS_ENUM(NSInteger, mk_cg_centralManagerStatus) {
    mk_cg_centralManagerStatusUnable,                           //不可用
    mk_cg_centralManagerStatusEnable,                           //可用状态
};


// An example messaging protocol for communications between the app and the
// accessory. In your app, modify or extend this enumeration to your app's
// user experience and conform the accessory accordingly.

typedef NS_ENUM(NSInteger, mk_cg_messageId) {
    mk_cg_messageIdUnknow,
    // Messages from the accessory.
    mk_cg_accessoryConfigurationData = 0x1,
    mk_cg_accessoryUwbDidStart = 0x2,
    mk_cg_accessoryUwbDidStop = 0x3,
    mk_cg_accessoryPaired = 0x4,
    
    // Messages to the accessory.
    mk_cg_initialize = 0xA,
    mk_cg_configureAndStart = 0xB,
    mk_cg_stop = 0xC,
    
    // User defined Message IDs
    mk_cg_getDeviceStruct = 0x20,
    mk_cg_setDeviceStruct = 0x21,
    
    mk_cg_iOSNotify = 0x2F,
};


@protocol mk_cg_centralManagerScanDelegate <NSObject>

/// Scan to new device.
/// @param deviceModel device
- (void)mk_cg_receiveDevice:(NSDictionary *)deviceModel;

@optional

/// Starts scanning equipment.
- (void)mk_cg_startScan;

/// Stops scanning equipment.
- (void)mk_cg_stopScan;

@end


@class CBPeripheral;
@protocol mk_cg_accessorySharedDataDelegate <NSObject>

- (void)mk_cg_accessorySharedData:(NSData *)data
                        messageId:(mk_cg_messageId)messageId
                       peripheral:(CBPeripheral *)peripheral;

@end
