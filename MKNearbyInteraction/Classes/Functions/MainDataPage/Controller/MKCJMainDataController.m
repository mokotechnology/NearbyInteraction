//
//  MKCJMainDataController.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/30.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKCJMainDataController.h"

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

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKBLEBaseSDKAdopter.h"

#import "MKCJCentralManager.h"

#import "MKCJMainDataView.h"
#import "MKCJCirclePatternView.h"
#import "MKCJArrowView.h"
#import "MKCJErrorView.h"

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



static float const maxDistance = 0.1;

@interface MKCJMainDataController ()<NISessionDelegate,
ARSessionDelegate,
mk_cg_accessorySharedDataDelegate>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong)MKCJMainDataView *dataView;

@property (nonatomic, assign)NSInteger errorCount;

@property (nonatomic, assign)BOOL showError;

@property (nonatomic, assign)BOOL isConverged;

@property (nonatomic, copy)NSString *errorMsg;



@property (nonatomic, strong)NISession *session;

@property (nonatomic, strong)NINearbyAccessoryConfiguration *configuration;



@property (nonatomic, strong) CHHapticEngine *hapticEngine;
@property (nonatomic, assign) BOOL feedbackEnabled;
@property (nonatomic, assign) NSInteger feedbackLevel;
@property (nonatomic, assign) NSInteger feedbackLevelOld;
@property (nonatomic, strong) NSArray<NSDictionary *> *feedbackPar;
@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, strong)dispatch_source_t feedbackTimer;

@end

@implementation MKCJMainDataController

- (void)dealloc {
    NSLog(@"MKCJMainDataController销毁");
    [self.session invalidate];
    [self.hapticEngine stoppedHandler];
    [[MKCJCentralManager shared] sendData:stop];
    [[MKCJCentralManager shared] disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.feedbackTimer) {
        dispatch_cancel(self.feedbackTimer);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self loadSubViews];
    [self setupParams];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deviceConnectStatusChanged)
                                                 name:mk_cg_peripheralConnectStateChangedNotification 
                                               object:nil];
}

#pragma mark - super method

#pragma mark - NISessionDelegate
- (void)session:(NISession *)session didUpdateAlgorithmConvergence:(NIAlgorithmConvergence *)convergence forObject:(NINearbyObject * _Nullable)object {
    if (!object) {
        return;
    }
    if (convergence.status == NIAlgorithmConvergenceStatusConverged) {
        self.isConverged = YES;
        return;
    }
    if (convergence.status == NIAlgorithmConvergenceStatusNotConverged) {
        NSLog(@"%@",convergence.reasons);
        NSArray<NIAlgorithmConvergenceStatusReason>* reasons = [convergence reasons];
        
        if ([reasons containsObject:NIAlgorithmConvergenceStatusReasonInsufficientLighting]) {
            self.errorMsg = @"More light required.";
        }else if ([reasons containsObject:NIAlgorithmConvergenceStatusReasonInsufficientMovement]) {
            self.errorMsg = @"More Movement required.";
        }else {
            self.errorMsg = @"Try moving in a different direction...";
        }
        
        self.isConverged = NO;
        return;
    }
}

- (void)session:(NISession *)session didGenerateShareableConfigurationData:(NSData *)shareableConfigurationData forObject:(NINearbyObject *)object {
    NSLog(@"Sent shareable configuration data.");
    NSString *sharedData = [MKBLEBaseSDKAdopter hexStringFromData:shareableConfigurationData];
    [[MKCJCentralManager shared] sendData:[configureAndStart stringByAppendingString:sharedData]];
}

- (void)session:(NISession *)session didUpdateNearbyObjects:(NSArray<__kindof NINearbyObject *> *)nearbyObjects {
    if (nearbyObjects.count == 0) {
        return;
    }
    NINearbyObject *object = nearbyObjects[0];
    float distance = object.distance;
    
    simd_float3 direction = object.direction;
    if ((direction.x == 0.0 && direction.y == 0.0 && direction.z == 0.0) && self.isConverged) {
        direction = [self getDirectionFromHorizontalAngleWithRad:object.horizontalAngle];
        NSLog(@"simd_float3 vector: (%f, %f, %f)", direction.x, direction.y, direction.z);
    }
    
    
    if (direction.x == 0.0 && direction.y == 0.0 && direction.z == 0.0) {
        self.errorCount ++;
        if (self.errorCount >= 5) {
            self.errorCount = 5;
            self.showError = YES;
        }
        
    }else {
        self.errorCount --;
        if (self.errorCount <= 0) {
            self.errorCount = 0;
            self.showError = NO;
        }
    }
    
    if (self.showError) {
        //报错
        self.dataView.degreeView.hidden = YES;
        self.dataView.circleView.hidden = YES;
        self.dataView.arrowView.hidden = YES;
        self.dataView.errorView.hidden = NO;
        [self.dataView updateErrorMsg:self.errorMsg];
        self.feedbackEnabled = NO;
        self.dataView.distanceValueLabel.hidden = NO;
        self.dataView.distanceValueLabel.text = [NSString stringWithFormat:@"%.1f m",distance];
        self.dataView.distanceLabel.hidden = NO;
        self.dataView.distanceLabel.text = @"Nearby";
        return;
    }
    [self setFeedbackLvlWithDistance:distance];
    self.dataView.errorView.hidden = YES;
    self.dataView.degreeView.hidden = NO;
    
    if (distance < maxDistance) {
        self.dataView.circleView.hidden = NO;
        self.dataView.arrowView.hidden = YES;
    }else {
        self.dataView.circleView.hidden = YES;
        self.dataView.arrowView.hidden = NO;
    }
    
    BOOL isDirectionEnable = NISession.deviceCapabilities.supportsDirectionMeasurement;
    
    double azimuthCheck = [self azimuth:direction];
    
    NSString *elevationString = [NSString stringWithFormat:@"%ld",(long)(90 * [self elevation:direction])];
    NSInteger azimuth = 0;
    if (isDirectionEnable) {
        azimuth = 90 * azimuthCheck;
    }else {
        azimuth = [self rad2deg:azimuthCheck];
        elevationString = [self getElevationFromInt:object.verticalDirectionEstimate];
    }
    
    NSString *azimuthString = [NSString stringWithFormat:@"%ld°",(long)azimuth];
    [self.dataView updateAzimuth:azimuthString elevation:elevationString];
    
    if (distance < 0.03) {
        //
        self.dataView.distanceValueLabel.hidden = YES;
        
        self.dataView.distanceLabel.hidden = NO;
        self.dataView.distanceLabel.text = @"Here";
        
        self.feedbackEnabled = NO;
    }else if (distance < maxDistance) {
        self.feedbackEnabled = YES;
        
        self.dataView.distanceValueLabel.hidden = NO;
        self.dataView.distanceValueLabel.text = [NSString stringWithFormat:@"%.1f m",distance];
        
        self.dataView.distanceLabel.hidden = NO;
        self.dataView.distanceLabel.text = @"Nearby";
    }else {
        self.dataView.distanceLabel.hidden = YES;
        
        self.dataView.distanceValueLabel.hidden = NO;
        self.dataView.distanceValueLabel.text = [NSString stringWithFormat:@"%.1f m",distance];
        
        CGFloat radians = (CGFloat)azimuth * (M_PI / 180);
        
        NSLog(@"%.1f",radians);
        if (radians >= -0.2 && radians <= 0.2) {
            self.feedbackEnabled = YES;
        }else {
            self.feedbackEnabled = NO;
        }
        [self.dataView.arrowView setArrowRotationAngle:radians];
    }
}

- (void)session:(NISession *)session didRemoveNearbyObjects:(NSArray<__kindof NINearbyObject *> *)nearbyObjects withReason:(NINearbyObjectRemovalReason)reason {
    NSLog(@"2");
}

- (void)sessionWasSuspended:(NISession *)session {
    NSLog(@"3");
    [[MKCJCentralManager shared] sendData:stop];
    self.feedbackEnabled = NO;
}

- (void)sessionSuspensionEnded:(NISession *)session {
    NSLog(@"4");
    [[MKCJCentralManager shared] sendData:initialize];
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

#pragma mark - ARSessionDelegate
- (BOOL)sessionShouldAttemptRelocalization:(ARSession *)session {
    return NO;
}

#pragma mark - mk_cg_accessorySharedDataDelegate
- (void)mk_cg_accessorySharedData:(NSData *)data
                        messageId:(mk_cg_messageId)messageId
                       peripheral:(CBPeripheral *)peripheral {
    if (messageId == mk_cg_accessoryConfigurationData) {
        // Access the message data by skipping the message identifier.
        [self runBackgroundNISession:data peripheral:peripheral];
        return;
    }
    if (messageId == mk_cg_accessoryUwbDidStart) {
        //
        return;
    }
    if (messageId == mk_cg_accessoryUwbDidStop) {
        //
//        [[MKCJCentralManager shared] disconnect];
        return;
    }
}

#pragma mark - note
- (void)deviceConnectStatusChanged {
    if ([MKCJCentralManager shared].connectStatus != mk_cg_centralConnectStatusConnected) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - event method
- (void)closeButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Interface
- (void)nearbyInitialize {
    [[MKCJCentralManager shared] sendData:initialize];
}

#pragma mark - Private method
- (void)setupParams {
    [MKCJCentralManager shared].dataDelegate = self;
    
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
    if (!self.feedbackEnabled) {
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
    if (distance > 0.1) {
        self.feedbackLevel = 0;
    } else if (distance > 0.03) {
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
        return asin(direction.x);
    }
    return atan2(direction.x, direction.z);
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

- (NSString *)getElevationFromInt:(NINearbyObjectVerticalDirectionEstimate)elevation {
    // TODO: Use Localizable String
    switch (elevation) {
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
    [[MKCJCentralManager shared] sendData:stop];
    
    self.session = nil;
    self.session = [[NISession alloc] init];
    self.session.delegate = self;
    
    [[MKCJCentralManager shared] sendData:initialize];
}

#pragma mark - UI
- (void)loadSubViews {
    // 将渐变图层插入到视图的最底层
    [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
//    self.view.backgroundColor = RGBCOLOR(0, 252, 55);
    [self.view addSubview:self.dataView];
    [self.dataView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.dataView.titleLabel.text = SafeStr(self.deviceName);
}

#pragma mark - getter
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = [UIScreen mainScreen].bounds;
        _gradientLayer.colors = @[(id)[UIColor colorWithRed:56/255.0 green:51/255.0 blue:62/255.0 alpha:1.0].CGColor,
                                          (id)[UIColor colorWithRed:106/255.0 green:92/255.0 blue:89/255.0 alpha:1.0].CGColor,
                                          (id)[UIColor colorWithRed:34/255.0 green:29/255.0 blue:35/255.0 alpha:1.0].CGColor];
        _gradientLayer.locations = @[@0.0, @0.5, @1.0];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    }
    return _gradientLayer;
}

- (MKCJMainDataView *)dataView {
    if (!_dataView) {
        _dataView = [[MKCJMainDataView alloc] init];
        [_dataView.closeButton addTarget:self
                                  action:@selector(closeButtonPressed)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    return _dataView;
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
