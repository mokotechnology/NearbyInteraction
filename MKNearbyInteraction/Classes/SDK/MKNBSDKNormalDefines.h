
typedef NS_ENUM(NSInteger, mk_nb_centralConnectStatus) {
    mk_nb_centralConnectStatusUnknow,                                           //未知状态
    mk_nb_centralConnectStatusConnecting,                                       //正在连接
    mk_nb_centralConnectStatusConnected,                                        //连接成功
    mk_nb_centralConnectStatusConnectedFailed,                                  //连接失败
    mk_nb_centralConnectStatusDisconnect,
};

typedef NS_ENUM(NSInteger, mk_nb_centralManagerStatus) {
    mk_nb_centralManagerStatusUnable,                           //不可用
    mk_nb_centralManagerStatusEnable,                           //可用状态
};


// An example messaging protocol for communications between the app and the
// accessory. In your app, modify or extend this enumeration to your app's
// user experience and conform the accessory accordingly.

typedef NS_ENUM(NSInteger, mk_nb_messageId) {
    mk_nb_messageIdUnknow,
    // Messages from the accessory.
    mk_nb_accessoryConfigurationData = 0x1,
    mk_nb_accessoryUwbDidStart = 0x2,
    mk_nb_accessoryUwbDidStop = 0x3,
    mk_nb_accessoryPaired = 0x4,
    
    // Messages to the accessory.
    mk_nb_initialize = 0xA,
    mk_nb_configureAndStart = 0xB,
    mk_nb_stop = 0xC,
    
    // User defined Message IDs
    mk_nb_getDeviceStruct = 0x20,
    mk_nb_setDeviceStruct = 0x21,
    
    mk_nb_iOSNotify = 0x2F,
};


@protocol mk_nb_centralManagerScanDelegate <NSObject>

/// Scan to new device.
/// @param deviceModel device
- (void)mk_nb_receiveDevice:(NSDictionary *)deviceModel;

@optional

/// Starts scanning equipment.
- (void)mk_nb_startScan;

/// Stops scanning equipment.
- (void)mk_nb_stopScan;

@end


@class CBPeripheral;
@protocol mk_nb_accessorySharedDataDelegate <NSObject>

- (void)mk_nb_accessorySharedData:(NSData *)data
                        messageId:(mk_nb_messageId)messageId
                       peripheral:(CBPeripheral *)peripheral;

@end
