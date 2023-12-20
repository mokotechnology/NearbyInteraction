//
//  MKCJAddNearbyCell.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/5.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKCJAddNearbyCellModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, strong)NSNumber *rssi;

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

@protocol MKCJAddNearbyCellDelegate <NSObject>

- (void)cg_connectPeripheral:(CBPeripheral *)peripheral deviceName:(NSString *)deviceName;

@end

@interface MKCJAddNearbyCell : MKBaseCell

@property (nonatomic, weak)id <MKCJAddNearbyCellDelegate>delegate;

@property (nonatomic, strong)MKCJAddNearbyCellModel *dataModel;

+ (MKCJAddNearbyCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
