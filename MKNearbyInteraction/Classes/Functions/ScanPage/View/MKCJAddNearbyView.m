//
//  MKCJAddNearbyView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/27.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKCJAddNearbyView.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>

#import "MKMacroDefines.h"
#import "NSObject+MKModel.h"

#import "MKBaseTableView.h"

#import "MKCJCentralManager.h"

#import "MKCJAddHeaderView.h"
#import "MKCJAddNearbyCell.h"

static NSTimeInterval const animationDuration = .3f;
static CGFloat const kDatePickerH = 500.f;
#define kBottomViewWidth [UIScreen mainScreen].bounds.size.width - 2 * 10

@interface MKCJAddNearbyView ()<UITableViewDelegate, 
UITableViewDataSource,
mk_cg_centralManagerScanDelegate,
MKCJAddNearbyCellDelegate,
MKCJAddHeaderViewDelegate>

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)MKCJAddHeaderView *headerView;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)NSMutableDictionary *deviceCache;

@property (nonatomic, copy)void (^connectBlock)(CBPeripheral *peripheral, NSString *deviceName);


@end

@implementation MKCJAddNearbyView

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
    MKCJAddNearbyCell *cell = [MKCJAddNearbyCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - mk_cg_centralManagerScanDelegate

- (void)mk_cg_receiveDevice:(NSDictionary *)deviceModel {
    NSString *identify = deviceModel[@"identify"];
    if (!ValidStr(identify)) {
        return;
    }
    NSNumber *index = self.deviceCache[identify];
    if (ValidNum(index)) {
        //已经添加到列表了
        if (ValidStr(deviceModel[@"deviceName"])) {
            MKCJAddNearbyCellModel *cellModel = self.dataList[[index integerValue]];
            cellModel.deviceName = deviceModel[@"deviceName"];
            [self.tableView reloadData];
        }
        return;
    }
    [self.deviceCache setObject:@(self.dataList.count) forKey:identify];
    MKCJAddNearbyCellModel *cellModel = [MKCJAddNearbyCellModel mk_modelWithJSON:deviceModel];
    if (!ValidStr(cellModel.deviceName)) {
        cellModel.deviceName = @"N/A";
    }
    [self.dataList addObject:cellModel];
    [self.tableView reloadData];
    
}

#pragma mark - MKCJAddNearbyCellDelegate
- (void)cg_connectPeripheral:(CBPeripheral *)peripheral deviceName:(nonnull NSString *)deviceName{
    [self dismiss];
    if (self.connectBlock) {
        self.connectBlock(peripheral,deviceName);
    }
}

#pragma mark - MKCJAddHeaderViewDelegate
- (void)cg_addHeaderCloseMethod {
    [self dismiss];
}

#pragma mark - event Method

- (void)dismiss {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[MKCJCentralManager shared] stopScan];
}

#pragma mark - Public Method

- (void)showViewWithConnectBlock:(void (^)(CBPeripheral *peripheral, NSString *deviceName))connectBlock {
    [MKCJCentralManager shared].delegate = self;
    [kAppWindow addSubview:self];
    self.connectBlock = nil;
    self.connectBlock = connectBlock;
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -kDatePickerH - 10.f);
    } completion:^(BOOL finished) {
        [[MKCJCentralManager shared] startScan];
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

- (MKCJAddHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[MKCJAddHeaderView alloc] initWithFrame:CGRectMake(0, 0, kBottomViewWidth, 185.f)];
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
