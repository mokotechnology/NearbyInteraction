//
//  MKNBAddNearbyCell.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKNBAddNearbyCellModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, strong)NSNumber *rssi;

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

@protocol MKNBAddNearbyCellDelegate <NSObject>

- (void)nb_connectPeripheral:(CBPeripheral *)peripheral deviceName:(NSString *)deviceName;

@end

@interface MKNBAddNearbyCell : MKBaseCell

@property (nonatomic, weak)id <MKNBAddNearbyCellDelegate>delegate;

@property (nonatomic, strong)MKNBAddNearbyCellModel *dataModel;

+ (MKNBAddNearbyCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
