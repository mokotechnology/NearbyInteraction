//
//  MKNBAboutCell.h
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/9.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKNBAboutCellModel : NSObject

@property (nonatomic, copy)NSString *typeMessage;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, copy)NSString *iconName;

@property (nonatomic, assign)BOOL canAdit;

@end

@interface MKNBAboutCell : MKBaseCell

@property (nonatomic, strong)MKNBAboutCellModel *dataModel;

+ (MKNBAboutCell *)initCellWithTableView:(UITableView *)table;

@end

NS_ASSUME_NONNULL_END
