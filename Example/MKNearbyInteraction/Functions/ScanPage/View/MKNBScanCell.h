//
//  MKNBScanCell.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/7.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKNBScanCellModel : NSObject

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, strong)NSNumber *rssi;

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, assign)BOOL connectable;

@property (nonatomic, copy)NSString *location;

@end

@protocol MKNBScanCellDelegate <NSObject>

- (void)nb_connectPeriperal:(CBPeripheral *)peripheral;

@end

@interface MKNBScanCell : MKBaseCell

@property (nonatomic, weak)id <MKNBScanCellDelegate>delegate;

@property (nonatomic, strong)MKNBScanCellModel *dataModel;

+ (MKNBScanCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
