//
//  MKNBAboutCell.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/9.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBAboutCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKAboutCellModel.h"

@implementation MKNBAboutCellModel
@end

@interface MKNBAboutCell ()

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *typeLabel;

@property (nonatomic, strong)UILabel *valueLabel;

@end

@implementation MKNBAboutCell

+ (MKNBAboutCell *)initCellWithTableView:(UITableView *)table {
    MKNBAboutCell *cell = [table dequeueReusableCellWithIdentifier:@"MKNBAboutCellIdenty"];
    if (!cell) {
        cell = [[MKNBAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKNBAboutCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = COLOR_WHITE_MACROS;
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.valueLabel];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(25.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(25.f);
    }];
    [self.typeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(80.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    CGSize valueSize = [NSString sizeWithText:self.valueLabel.text
                                      andFont:self.valueLabel.font
                                   andMaxSize:CGSizeMake(self.contentView.frame.size.width - 30 - 25.f - 140 - 15, MAXFLOAT)];
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.typeLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(valueSize.height);
    }];
}

#pragma mark -
- (void)setDataModel:(MKNBAboutCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKNBAboutCellModel.class]) {
        return;
    }
    self.typeLabel.text = _dataModel.typeMessage;
    self.valueLabel.text = _dataModel.value;
    self.icon.image = LOADIMAGE(_dataModel.iconName, @"png");
    self.valueLabel.textColor = (_dataModel.canAdit ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    [self setNeedsLayout];
}

#pragma mark - setter & getter
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = DEFAULT_TEXT_COLOR;
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = MKFont(18.f);
    }
    return _typeLabel;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = UIColorFromRGB(0x808080);
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.font = MKFont(15.f);
        _valueLabel.numberOfLines = 0;
    }
    return _valueLabel;
}

@end
