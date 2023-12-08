//
//  MKNBAddNearbyView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/27.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBAddNearbyView.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>

#import "MKMacroDefines.h"
#import "NSObject+MKModel.h"

#import "MKBaseTableView.h"

#import "MKNBCentralManager.h"

#import "MKNBAddHeaderView.h"
#import "MKNBAddNearbyCell.h"

static NSTimeInterval const animationDuration = .3f;
static CGFloat const kDatePickerH = 500.f;
#define kBottomViewWidth [UIScreen mainScreen].bounds.size.width - 2 * 10

@interface MKNBAddNearbyView ()<UITableViewDelegate, 
UITableViewDataSource,
mk_nb_centralManagerScanDelegate,
MKNBAddNearbyCellDelegate,
MKNBAddHeaderViewDelegate>

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)MKNBAddHeaderView *headerView;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)NSMutableDictionary *deviceCache;

@property (nonatomic, copy)void (^connectBlock)(CBPeripheral *peripheral, NSString *deviceName);


@end

@implementation MKNBAddNearbyView

- (void)dealloc {
    NSLog(@"MKDeviceSettingPickView销毁");
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.tableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNBAddNearbyCell *cell = [MKNBAddNearbyCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - mk_nb_centralManagerScanDelegate

- (void)mk_nb_receiveDevice:(NSDictionary *)deviceModel {
    NSString *identify = deviceModel[@"identify"];
    if (!ValidStr(identify)) {
        return;
    }
    NSNumber *index = self.deviceCache[identify];
    if (ValidNum(index)) {
        //已经添加到列表了
        if (ValidStr(deviceModel[@"deviceName"])) {
            MKNBAddNearbyCellModel *cellModel = self.dataList[[index integerValue]];
            cellModel.deviceName = deviceModel[@"deviceName"];
            [self.tableView reloadData];
        }
        return;
    }
    [self.deviceCache setObject:@(self.dataList.count) forKey:identify];
    MKNBAddNearbyCellModel *cellModel = [MKNBAddNearbyCellModel mk_modelWithJSON:deviceModel];
    if (!ValidStr(cellModel.deviceName)) {
        cellModel.deviceName = @"N/A";
    }
    [self.dataList addObject:cellModel];
    [self.tableView reloadData];
    
}

#pragma mark - MKNBAddNearbyCellDelegate
- (void)nb_connectPeripheral:(CBPeripheral *)peripheral deviceName:(nonnull NSString *)deviceName{
    [self dismiss];
    if (self.connectBlock) {
        self.connectBlock(peripheral,deviceName);
    }
}

#pragma mark - MKNBAddHeaderViewDelegate
- (void)nb_addHeaderCloseMethod {
    [self dismiss];
}

#pragma mark - event Method

- (void)dismiss {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[MKNBCentralManager shared] stopScan];
}

#pragma mark - Public Method

- (void)showViewWithConnectBlock:(void (^)(CBPeripheral *peripheral, NSString *deviceName))connectBlock {
    [MKNBCentralManager shared].delegate = self;
    [kAppWindow addSubview:self];
    self.connectBlock = nil;
    self.connectBlock = connectBlock;
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -kDatePickerH - 10.f);
    } completion:^(BOOL finished) {
        [[MKNBCentralManager shared] startScan];
    }];
}



#pragma mark - setter & getter
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                               [UIScreen mainScreen].bounds.size.height,
                                                               kBottomViewWidth,
                                                               kDatePickerH)];
        _bottomView.backgroundColor = COLOR_WHITE_MACROS;
        _bottomView.layer.masksToBounds = YES;
        _bottomView.layer.cornerRadius = 30.f;
    }
    return _bottomView;
}

- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectMake(0, 0, kBottomViewWidth, kDatePickerH) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (MKNBAddHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[MKNBAddHeaderView alloc] initWithFrame:CGRectMake(0, 0, kBottomViewWidth, 185.f)];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableDictionary *)deviceCache {
    if (!_deviceCache) {
        _deviceCache = [NSMutableDictionary dictionary];
    }
    return _deviceCache;
}

@end
