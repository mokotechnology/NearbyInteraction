//
//  MKNearbyInteractionController.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNearbyInteractionController.h"


#import <CoreBluetooth/CoreBluetooth.h>

#import <NearbyInteraction/NearbyInteraction.h>

#import <SceneKit/SceneKit.h>

#import <ARKit/ARKit.h>
#import <RealityKit/RealityKit.h>
#import <CoreHaptics/CoreHaptics.h>

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"
#import "NirKxMenu.h"

#import "MKBLEBaseSDKAdopter.h"

#import "MKNBCentralManager.h"

#import "MKNBNearbyInteractionHeader.h"
#import "MKNBSceneView.h"
#import "MKNBARView.h"

// Messages from the accessory.
NSString *const accessoryConfigurationData = @"01";
NSString *const accessoryUwbDidStart = @"02";
NSString *const accessoryUwbDidStop = @"03";
NSString *const accessoryPaired = @"04";

// Messages to the accessory.
NSString *const initialize = @"0a";
NSString *const configureAndStart = @"0b";
NSString *const stop = @"0c";

// User defined Message IDs
NSString *const getDeviceStruct = @"20";
NSString *const setDeviceStruct = @"21";

@interface MKNearbyInteractionController ()<NISessionDelegate,
mk_nb_accessorySharedDataDelegate,
MKNBNearbyInteractionHeaderDelegate>

@property (nonatomic, strong)MKNBNearbyInteractionHeader *headerView;

@property (nonatomic, strong)MKNBNearbyInteractionHeaderModel *headerModel;



@property (nonatomic, strong)NISession *session;

@property (nonatomic, strong)NINearbyAccessoryConfiguration *configuration;



@property (nonatomic, strong)MKNBSceneView *sceneView;


// The AR Session to be shared with all devices, to enable camera assistance
@property (nonatomic, strong)MKNBARView *arView;



@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) CHHapticEngine *hapticEngine;
@property (nonatomic, assign) BOOL feedbackDisabled;
@property (nonatomic, assign) NSInteger feedbackLevel;
@property (nonatomic, assign) NSInteger feedbackLevelOld;
@property (nonatomic, strong) NSArray<NSDictionary *> *feedbackPar;
@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, strong)dispatch_source_t feedbackTimer;

@end

@implementation MKNearbyInteractionController

- (void)dealloc {
    NSLog(@"MKNearbyInteractionController销毁");
    [[MKNBCentralManager shared] sendData:stop];
    [[MKNBCentralManager shared] disconnect];
    [self.arView pause];
    if (self.feedbackTimer) {
        dispatch_cancel(self.feedbackTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self setupParams];
}

#pragma mark - super method
- (void)rightButtonMethod {
    if (self.arView.isHidden) {
        [self.arView start];
        [UIView animateWithDuration:0.4 animations:^{
            self.arView.hidden = NO;
            self.headerView.hidden = YES;
            self.sceneView.hidden = YES;
        }];
    }
    else {
        [self.arView pause];
        [UIView animateWithDuration:0.4 animations:^{
            self.arView.hidden = YES;
            self.headerView.hidden = NO;
            self.sceneView.hidden = NO;
        }];
    }
}

#pragma mark - NISessionDelegate

- (void)session:(NISession *)session didGenerateShareableConfigurationData:(NSData *)shareableConfigurationData forObject:(NINearbyObject *)object {
    NSLog(@"Sent shareable configuration data.");
    NSString *sharedData = [MKBLEBaseSDKAdopter hexStringFromData:shareableConfigurationData];
    [[MKNBCentralManager shared] sendData:[configureAndStart stringByAppendingString:sharedData]];
    self.sceneView.hidden = NO;
}

- (void)session:(NISession *)session didUpdateNearbyObjects:(NSArray<__kindof NINearbyObject *> *)nearbyObjects {
    if (nearbyObjects.count == 0) {
        return;
    }
    NINearbyObject *object = nearbyObjects[0];
    float distance = object.distance;
    
    if (!self.arView.hidden) {
        simd_float4x4 transform = [session worldTransformForObject:object];
        [self.arView updateMatrix:SCNMatrix4FromMat4(transform)];
    }
    
    BOOL isDirectionEnable = NISession.deviceCapabilities.supportsDirectionMeasurement;
    
    double azimuthCheck = [self azimuth:object.direction];
    
    NSInteger azimuth = 0;
    if (isDirectionEnable) {
        azimuth = 90 * azimuthCheck;
    }else {
        azimuth = [self rad2deg:azimuthCheck];
    }
    NSInteger elevation = 90 * [self elevation:object.direction];
    
    self.headerModel.distance = [NSString stringWithFormat:@"%0.1f m", distance];
    self.headerModel.azimuth = [NSString stringWithFormat:@"%ld°", (long)azimuth];
    self.headerModel.elevation = [NSString stringWithFormat:@"%ld°", (long)elevation];
    [self.headerView setDataModel:self.headerModel];
    
    // Update Graphics
    [self.sceneView setArrowAngleWithNewElevation:elevation newAzimuth:azimuth];
    [self setFeedbackLvlWithDistance:distance];
}

- (void)session:(NISession *)session didRemoveNearbyObjects:(NSArray<__kindof NINearbyObject *> *)nearbyObjects withReason:(NINearbyObjectRemovalReason)reason {
    NSLog(@"2");
}

- (void)sessionWasSuspended:(NISession *)session {
    NSLog(@"3");
    [[MKNBCentralManager shared] sendData:stop];
}

- (void)sessionSuspensionEnded:(NISession *)session {
    NSLog(@"4");
    [[MKNBCentralManager shared] sendData:initialize];
}

- (void)session:(NISession *)session didInvalidateWithError:(NSError *)error {
    NSLog(@"5");
    if (![error.domain isEqualToString:NIErrorDomain]) {
        return;
    }
    switch (error.code) {
        case NIErrorCodeInvalidConfiguration:
            //Debug the accessory data to ensure an expected format.
            NSLog(@"The accessory configuration data is invalid. Please debug it and try again.");
            break;
        case NIErrorCodeUserDidNotAllow:
            [self handleUserDidNotAllow];
            break;
        case NIErrorCodeInvalidARConfiguration:
            NSLog(@"Check the ARConfiguration used to run the ARSession");
            break;
        default:
            NSLog(@"invalidated: %@", error);
            [self handleSessionInvalidation];
            break;
    }
}

#pragma mark - mk_nb_accessorySharedDataDelegate
- (void)mk_nb_accessorySharedData:(NSData *)data
                        messageId:(mk_nb_messageId)messageId
                       peripheral:(CBPeripheral *)peripheral {
    if (messageId == mk_nb_accessoryConfigurationData) {
        // Access the message data by skipping the message identifier.
        [self runBackgroundNISession:data peripheral:peripheral];
        return;
    }
    if (messageId == mk_nb_accessoryUwbDidStart) {
        //
        return;
    }
    if (messageId == mk_nb_accessoryUwbDidStop) {
        //
        [[MKNBCentralManager shared] disconnect];
        return;
    }
}

#pragma mark - MKNBNearbyInteractionHeaderDelegate
- (void)feedbackStatusChanged:(BOOL)isOn {
    self.feedbackDisabled = isOn;
}

#pragma mark - Interface
- (void)nearbyInitialize {
    [[MKNBCentralManager shared] sendData:initialize];
}

#pragma mark - Private method
- (void)setupParams {
    self.sceneView.hidden = YES;
    self.arView.hidden = YES;
        
    [MKNBCentralManager shared].dataDelegate = self;
    
    [self addFeedbackTimer];
    
    [self performSelector:@selector(nearbyInitialize)
               withObject:nil
               afterDelay:0.5f];
}

- (void)runBackgroundNISession:(NSData *)data peripheral:(CBPeripheral *)peripheral {
    NSError *error;
    self.configuration = [[NINearbyAccessoryConfiguration alloc] initWithData:data error:&error];
    self.configuration.cameraAssistanceEnabled = YES;
    
    self.session = [[NISession alloc] init];
    self.session.delegate = self;
    [self.session setARSession:[self.arView arSession]];
    [self.arView createARObject];
    [self.session runWithConfiguration:self.configuration];
}

- (void)addFeedbackTimer {
    self.feedbackTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.feedbackTimer, dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC),  0.2 * NSEC_PER_SEC, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.feedbackTimer, ^{
        @strongify(self);
        [self timerHandler];
    });
    dispatch_resume(self.feedbackTimer);
}

- (void)timerHandler {
    if (!self.feedbackDisabled) {
        return;
    }
    if (self.timerIndex != [self.feedbackPar[self.feedbackLevel][@"timerIndexRef"] integerValue]) {
        self.timerIndex += 1;
        return;
    }
    self.timerIndex = 0;
        
        // Play sound, if enabled
        SystemSoundID systemSoundID = 1052;
        AudioServicesPlaySystemSound(systemSoundID);
        
        // Play haptic, if enabled
    if (!self.hapticEngine || ![CHHapticEngine capabilitiesForHardware].supportsHaptics) {
        return;
    }
    NSError *hapticError = nil;
    CHHapticEvent *hapticEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous
                                                               parameters:@[]
                                                             relativeTime:0
                                                                 duration:[self.feedbackPar[self.feedbackLevel][@"hummDuration"] doubleValue]];
    CHHapticPattern *hapticPattern = [[CHHapticPattern alloc] initWithEvents:@[hapticEvent] parameters:@[] error:&hapticError];
    if (hapticError) {
        NSLog(@"Failed to create haptic pattern: %@", hapticError.localizedDescription);
        return;
    }
    NSError *playerError = nil;
    id<CHHapticPatternPlayer> player = [self.hapticEngine createPlayerWithPattern:hapticPattern error:&playerError];
    if (playerError) {
        NSLog(@"Failed to create haptic pattern player: %@", playerError.localizedDescription);
        return;
    }
    NSError *startError = nil;
    [player startAtTime:0 error:&startError];
    if (startError) {
        NSLog(@"Failed to start haptic pattern player: %@", startError.localizedDescription);
    }
}

- (void)setFeedbackLvlWithDistance:(float)distance {
    if (distance > 4.0) {
        self.feedbackLevel = 0;
    } else if (distance > 2.0) {
        self.feedbackLevel = 1;
    } else {
        self.feedbackLevel = 2;
    }
    
    if (self.feedbackLevel != self.feedbackLevelOld) {
        self.timerIndex = 0;
        self.feedbackLevelOld = self.feedbackLevel;
    }
}



// Provides the azimuth from an argument 3D directional.
- (float)azimuth:(simd_float3)direction {
    if (NISession.deviceCapabilities.supportsDirectionMeasurement) {
        //Check if direction is enable (iPhone 14)
        return asinf(direction.x);
    } else {
        return atan2f(direction.x, direction.z);
    }
}

// Provides the elevation from the argument 3D directional.
- (float)elevation:(simd_float3)direction {
    return atan2f(direction.z, direction.y) + M_PI / 2;
}

// TODO: Refactor
- (double)rad2deg:(double)number {
    return number * 180 / M_PI;
}

- (simd_float3)getDirectionFromHorizontalAngleWithRad:(float)rad {
    NSLog(@"Horizontal Angle in deg = %f", [self rad2deg:rad]);
    return simd_make_float3(sinf(rad), 0, cosf(rad));
}

- (NSString *)getElevationFromInt:(NSNumber *)elevation {
    if (elevation == nil) {
        return @"UNKNOWN";
    }
    // TODO: Use Localizable String
    switch ([elevation intValue]) {
        case NINearbyObjectVerticalDirectionEstimateAbove:
            return @"ABOVE";
        case NINearbyObjectVerticalDirectionEstimateBelow:
            return @"BELOW";
        case NINearbyObjectVerticalDirectionEstimateSame:
            return @"SAME";
        case NINearbyObjectVerticalDirectionEstimateAboveOrBelow:
        case NINearbyObjectVerticalDirectionEstimateUnknown:
            return @"UNKNOWN";
        default:
            return @"UNKNOWN";
    }
}

- (void)handleUserDidNotAllow {
    // Create an alert to request the user go to Settings.
    UIAlertController *accessAlert = [UIAlertController alertControllerWithTitle:@"Access Required"
                                                                         message:@"NIAccessory requires access to Nearby Interactions for this sample app. Use this string to explain to users which functionality will be enabled if they change Nearby Interactions access in Settings."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [accessAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [accessAlert addAction:[UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Navigate the user to the app's settings.
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
        }
    }]];
    
    // Present the access alert.
    [self presentViewController:accessAlert animated:YES completion:nil];
}

- (void)handleSessionInvalidation {
    [[MKNBCentralManager shared] sendData:stop];
    
    self.session = nil;
    self.session = [[NISession alloc] init];
    self.session.delegate = self;
    
    [[MKNBCentralManager shared] sendData:initialize];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Nearby Interaction";
    [self.rightButton setTitle:@"AR" forState:UIControlStateNormal];
    [self.view addSubview:self.headerView];
    
    [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0.0f);
        make.right.mas_equalTo(0.0f);
        make.top.mas_equalTo(defaultTopInset + 30);
        make.height.mas_equalTo(150.f);
    }];
    [self.view addSubview:self.sceneView];
    [self.sceneView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(100.f);
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(100.f);
    }];
    [self.view addSubview:self.arView];
    [self.arView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - getter
- (MKNBNearbyInteractionHeader *)headerView {
    if (!_headerView) {
        _headerView = [[MKNBNearbyInteractionHeader alloc] init];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (MKNBNearbyInteractionHeaderModel *)headerModel {
    if (!_headerModel) {
        _headerModel = [[MKNBNearbyInteractionHeaderModel alloc] init];
    }
    return _headerModel;
}

- (MKNBSceneView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[MKNBSceneView alloc] init];
    }
    return _sceneView;
}

- (MKNBARView *)arView {
    if (!_arView) {
        _arView = [[MKNBARView alloc] init];
    }
    return _arView;
}

- (AVAudioEngine *)audioEngine {
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}

- (CHHapticEngine *)hapticEngine {
    if (!_hapticEngine) {
        _hapticEngine = [[CHHapticEngine alloc] initAndReturnError:nil];
        [_hapticEngine startWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to start haptic engine: %@", error.localizedDescription);
            }
        }];
    }
    return _hapticEngine;
}

- (NSArray<NSDictionary *> *)feedbackPar {
    if (!_feedbackPar) {
        _feedbackPar = @[@{@"hummDuration": @1.0, @"timerIndexRef": @8},
                         @{@"hummDuration": @0.5, @"timerIndexRef": @4},
                         @{@"hummDuration": @0.1, @"timerIndexRef": @1}];
    }
    return _feedbackPar;
}


@end
