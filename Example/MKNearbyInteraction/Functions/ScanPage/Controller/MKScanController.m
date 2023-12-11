//
//  MKScanController.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKScanController.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "Masonry.h"

#import "SDCycleScrollView.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKBLEBaseSDKAdopter.h"

#import "MKNBCommonTools.h"

#import "MKNBCentralManager.h"

#import "MKNBMainDataController.h"
#import "MKNBAboutController.h"

#import "MKNBAddNearbyView.h"


@interface MKScanController ()

@property (nonatomic, strong)SDCycleScrollView *scrollView;

@property (nonatomic, strong)UIButton *startButton;

@end

@implementation MKScanController

- (void)dealloc {
    NSLog(@"MKScanController销毁");
    //移除runloop的监听
    [[MKNBCentralManager shared] stopScan];
    [MKNBCentralManager sharedDealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollView adjustWhenControllerViewWillAppera];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKNBAboutController *vc = [[MKNBAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - event method
- (void)startButtonPressed {
    MKNBAddNearbyView *view = [[MKNBAddNearbyView alloc] init];
    [view showViewWithConnectBlock:^(CBPeripheral * _Nonnull peripheral, NSString * _Nonnull deviceName) {
        [self connectPeriperal:peripheral deviceName:deviceName];
    }];
}

#pragma mark - 连接部分

- (void)connectPeriperal:(CBPeripheral *)peripheral deviceName:(NSString *)deviceName{
    [[MKHudManager share] showHUDWithTitle:@"Connect..." inView:self.view isPenetration:NO];
    [[MKNBCentralManager shared] connectPeripheral:peripheral sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        [[MKHudManager share] hide];
        MKNBMainDataController *vc = [[MKNBMainDataController alloc] init];
        vc.deviceName = deviceName;
        [self.navigationController pushViewController:vc animated:YES];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKNBCentralManager shared] disconnect];
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
- (void)loadSubViews {
    self.titleLabel.font = [MKNBCommonTools font:20.f];
    self.titleLabel.text = @"Nearby Interaction";
    self.leftButton.hidden = YES;
    [self.rightButton setImage:LOADIMAGE(@"rightAboutIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0.f);
        make.right.mas_equalTo(0.f);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    [self.view addSubview:self.startButton];
    [self.startButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(100.f);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-200.f);
        make.height.mas_equalTo(100.f);
    }];
}

#pragma mark - getter
- (SDCycleScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[SDCycleScrollView alloc] init];
        _scrollView.showPageControl = YES;
        _scrollView.localizationImageNamesGroup = [self imageList];
        _scrollView.pageDotColor = [UIColor grayColor];
        _scrollView.currentPageDotColor = [UIColor redColor];
    }
    return _scrollView;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.alpha = 0.8;
        [_startButton setImage:LOADIMAGE(@"startButtonIcon", @"png") forState:UIControlStateNormal];
        [_startButton setBackgroundColor:RGBCOLOR(201, 210, 216)];
        [_startButton addTarget:self
                         action:@selector(startButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        
        _startButton.layer.masksToBounds = YES;
        _startButton.layer.cornerRadius = 50.f;
    }
    return _startButton;
}

- (NSArray *)imageList {
    return @[LOADIMAGE(@"nearbyApplication1", @"png"),
             LOADIMAGE(@"nearbyApplication2", @"png"),
             LOADIMAGE(@"nearbyApplication3", @"png"),
             LOADIMAGE(@"nearbyApplication4", @"png"),
             LOADIMAGE(@"nearbyApplication5", @"png")];
}

@end
