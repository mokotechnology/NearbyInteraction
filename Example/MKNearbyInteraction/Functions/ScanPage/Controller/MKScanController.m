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

#import "MKNBCentralManager.h"

#import "MKNBMainDataController.h"

#import "MKNBAddNearbyView.h"


@interface MKScanController ()

@property (nonatomic, strong)SDCycleScrollView *scrollView;

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
    self.titleLabel.text = @"Nearby Interaction";
    self.leftButton.hidden = YES;
    [self.rightButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0.f);
        make.right.mas_equalTo(0.f);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
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

- (NSArray *)imageList {
    return @[LOADIMAGE(@"nearbyApplication1", @"png"),
             LOADIMAGE(@"nearbyApplication2", @"png"),
             LOADIMAGE(@"nearbyApplication3", @"png"),
             LOADIMAGE(@"nearbyApplication4", @"png"),
             LOADIMAGE(@"nearbyApplication5", @"png")];
}

@end
