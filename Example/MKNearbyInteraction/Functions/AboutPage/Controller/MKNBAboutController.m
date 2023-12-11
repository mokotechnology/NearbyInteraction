//
//  MKNBAboutController.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/12/9.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBAboutController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "NSString+MKAdd.h"
#import "UIView+MKAdd.h"

#import "MKCustomUIAdopter.h"

#import "MKNBAboutCell.h"

@interface MKNBAboutController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UIImageView *aboutIcon;

@property (nonatomic, strong)UILabel *versionLabel;

@property (nonatomic, strong)UILabel *companyNameLabel;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIView *tableHeader;

@property (nonatomic, strong)UIView *tableFooter;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKNBAboutController

- (void)dealloc {
    NSLog(@"MKNBAboutController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNBAboutCellModel *model = self.dataList[indexPath.row];
    CGSize valueSize = [NSString sizeWithText:model.value
                                      andFont:MKFont(15.f)
                                   andMaxSize:CGSizeMake(kViewWidth - 30 - 25.f - 140 - 15, MAXFLOAT)];
    return MAX(44.f, valueSize.height + 20.f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        [self openWebBrowser];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNBAboutCell *cell = [MKNBAboutCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark -
- (void)loadSubViews {
    self.defaultTitle = @"About MOKO";
    [self.rightButton setHidden:YES];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [@"Version:" stringByAppendingString:version];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)loadTableDatas {
    MKNBAboutCellModel *faxModel = [[MKNBAboutCellModel alloc] init];
    faxModel.iconName = @"faxIcon";
    faxModel.typeMessage = @"Fax";
    faxModel.value = @"86-75523573370-808";
    [self.dataList addObject:faxModel];
    
    MKNBAboutCellModel *telModel = [[MKNBAboutCellModel alloc] init];
    telModel.iconName = @"telIcon";
    telModel.typeMessage = @"Tel";
    telModel.value = @"86-75523573370";
    [self.dataList addObject:telModel];
    
    MKNBAboutCellModel *addModel = [[MKNBAboutCellModel alloc] init];
    addModel.iconName = @"addUsIcon";
    addModel.typeMessage = @"Add";
    addModel.value = @"4F,Building2,Guanghui Technology Park,MinQing Rd,Longhua,Shenzhen,Guangdong,China";
    [self.dataList addObject:addModel];
    
    MKNBAboutCellModel *linkModel = [[MKNBAboutCellModel alloc] init];
    linkModel.iconName = @"shouceIcon";
    linkModel.typeMessage = @"Website";
    linkModel.value = @"www.mokosmart.com";
    linkModel.canAdit = YES;
    [self.dataList addObject:linkModel];
    
    [self.tableView reloadData];
}

#pragma mark - Private method
- (void)openWebBrowser{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.mokosmart.com"]
                                       options:@{}
                             completionHandler:nil];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        
        _tableView.tableHeaderView = self.tableHeader;
        _tableView.tableFooterView = self.tableFooter;
    }
    return _tableView;
}

- (UIImageView *)aboutIcon{
    if (!_aboutIcon) {
        _aboutIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kViewWidth - 110.f) / 2, 40.f, 110.f, 110.f)];
        _aboutIcon.image = LOADIMAGE(@"aboutIcon", @"png");
    }
    return _aboutIcon;
}

- (UILabel *)versionLabel{
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40.f + 110.f + 17.f, kViewWidth, MKFont(17.f).lineHeight)];
        _versionLabel.textColor = DEFAULT_TEXT_COLOR;
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.font = MKFont(17.f);
    }
    return _versionLabel;
}

- (UILabel *)companyNameLabel{
    if (!_companyNameLabel) {
        _companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 185.f, kViewWidth, MKFont(17).lineHeight)];
        _companyNameLabel.textColor = DEFAULT_TEXT_COLOR;
        _companyNameLabel.textAlignment = NSTextAlignmentCenter;
        _companyNameLabel.font = MKFont(16.f);
        _companyNameLabel.text = @"MOKO TECHNOLOGY LTD.";
    }
    return _companyNameLabel;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIView *)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 200.f)];
        
        _tableHeader.backgroundColor = COLOR_WHITE_MACROS;
        [_tableHeader addSubview:self.aboutIcon];
        [_tableHeader addSubview:self.versionLabel];
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 195.f, kViewWidth, 0.5f)];
        lineView.backgroundColor = CUTTING_LINE_COLOR;
        [_tableHeader addSubview:lineView];
    }
    return _tableHeader;
}

- (UIView *)tableFooter {
    if (!_tableFooter) {
        _tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 250.f)];
        _tableFooter.backgroundColor = COLOR_WHITE_MACROS;
        
        [_tableFooter addSubview:self.companyNameLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 249.5f, 0.5f)];
        lineView.backgroundColor = CUTTING_LINE_COLOR;
        [_tableFooter addSubview:lineView];
    }
    return _tableFooter;
}

@end
