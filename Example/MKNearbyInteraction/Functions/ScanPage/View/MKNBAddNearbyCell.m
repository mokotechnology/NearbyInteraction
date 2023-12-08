//
//  MKNBAddNearbyCell.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBAddNearbyCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKNBAddNearbyCellModel
@end

@interface MKNBAddNearbyCell ()

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UIButton *connectButton;

@end

@implementation MKNBAddNearbyCell

+ (MKNBAddNearbyCell *)initCellWithTableView:(UITableView *)tableView {
    MKNBAddNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKNBAddNearbyCellIdenty"];
    if (!cell) {
        cell = [[MKNBAddNearbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKNBAddNearbyCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.connectButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-3.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.connectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(20.f);
    }];
}

#pragma mark - event method
- (void)connectButtonPressed {
    if ([self.delegate respondsToSelector:@selector(nb_connectPeripheral:deviceName:)]) {
        [self.delegate nb_connectPeripheral:self.dataModel.peripheral deviceName:self.dataModel.deviceName];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKNBAddNearbyCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKNBAddNearbyCellModel.class]) {
        return;
    }
    self.nameLabel.text = _dataModel.deviceName;
}

#pragma mark - getter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = DEFAULT_TEXT_COLOR;
        _nameLabel.font = MKFont(13.f);
    }
    return _nameLabel;
}

- (UIButton *)connectButton {
    if (!_connectButton) {
        _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_connectButton setTitle:@"connect" forState:UIControlStateNormal];
        [_connectButton.titleLabel setFont:MKFont(13.f)];
        [_connectButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
        [_connectButton addTarget:self
                           action:@selector(connectButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectButton;
}

@end
