//
//  MKNBScanCell.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBScanCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"

@implementation MKNBScanCellModel
@end

@interface MKNBScanCell ()

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UILabel *rssiLabel;

@property (nonatomic, strong)UIButton *connectButton;

@property (nonatomic, strong)UILabel *locationLabel;

@end

@implementation MKNBScanCell

+ (MKNBScanCell *)initCellWithTableView:(UITableView *)tableView {
    MKNBScanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKNBScanCellIdenty"];
    if (!cell) {
        cell = [[MKNBScanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKNBScanCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.rssiLabel];
        [self.contentView addSubview:self.connectButton];
        [self.contentView addSubview:self.locationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.connectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(90.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(90.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.connectButton.mas_left).mas_offset(-15.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rssiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.connectButton.mas_left).mas_offset(-15.f);
        make.bottom.mas_equalTo(-10.f);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)connectButtonPressed {
    if ([self.delegate respondsToSelector:@selector(nb_connectPeriperal:)]) {
        [self.delegate nb_connectPeriperal:self.dataModel.peripheral];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKNBScanCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKNBScanCellModel.class]) {
        return;
    }
    self.deviceNameLabel.text = (ValidStr(_dataModel.deviceName) ? _dataModel.deviceName : @"N/A");
    self.rssiLabel.text = [NSString stringWithFormat:@"Rssi:%@%@",_dataModel.rssi,@" dBm"];
    self.connectButton.hidden = !_dataModel.connectable;
    self.locationLabel.hidden = _dataModel.connectable;
    self.locationLabel.text = SafeStr(_dataModel.location);
}

#pragma mark - getter
- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textColor = DEFAULT_TEXT_COLOR;
        _deviceNameLabel.font = MKFont(15.f);
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _deviceNameLabel;
}

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [[UILabel alloc] init];
        _rssiLabel.textColor = DEFAULT_TEXT_COLOR;
        _rssiLabel.font = MKFont(13.f);
        _rssiLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _rssiLabel;
}

- (UIButton *)connectButton {
    if (!_connectButton) {
        _connectButton = [MKCustomUIAdopter customButtonWithTitle:@"CONNECT"
                                                           target:self
                                                           action:@selector(connectButtonPressed)];
        _connectButton.titleLabel.font = MKFont(15.f);
    }
    return _connectButton;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = DEFAULT_TEXT_COLOR;
        _locationLabel.font = MKFont(13.f);
        _locationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _locationLabel;
}

@end
