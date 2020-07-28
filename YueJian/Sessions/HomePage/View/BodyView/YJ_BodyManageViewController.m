//
//  YJ_BodyManageViewController.m
//  YueJian
//
//  Created by LG on 2018/5/9.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BodyManageViewController.h"
#import "YJ_InputAlertView.h"
#import "YJ_BodyProfile.h"
#import "YJ_BodyManageViewModel.h"

@interface YJ_BodyManageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *arrTitleData;
@property (nonatomic, strong) NSMutableDictionary *dicCurrentData;
@property (nonatomic, copy) NSString *bodyProfilePath;
@property (nonatomic, copy) NSString *bodyNewProfilePath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YJ_BodyProfile *bodyData;
@property (nonatomic, strong) YJ_BodyManageViewModel *viewModel;

@end

@implementation YJ_BodyManageViewController

#pragma mark - 数据
- (NSArray *)arrTitleData
{
    if (!_arrTitleData) {
        _arrTitleData = @[
                          @{@"image":@"icon_body_height",
                            @"title":NSLocalizedString(@"身高", nil),
                            @"detail":NSLocalizedString(@"170cm", nil)},
                          
                          @{@"image":@"icon_body_weight",
                            @"title":NSLocalizedString(@"体重", nil),
                            @"detail":NSLocalizedString(@"70kg", nil)},
                          
                          @{@"image":@"icon_body_bust",
                            @"title":NSLocalizedString(@"胸围", nil),
                            @"detail":NSLocalizedString(@"100cm", nil)},
                          
                          @{@"image":@"icon_body_waist",
                            @"title":NSLocalizedString(@"腰围", nil),
                            @"detail":NSLocalizedString(@"40cm", nil)},
                          
                          @{@"image":@"icon_body_hip",
                            @"title":NSLocalizedString(@"臀围", nil),
                            @"detail":NSLocalizedString(@"50cm", nil)},
                          
                          @{@"image":@"icon_body_bf",
                            @"title":NSLocalizedString(@"体脂率", nil),
                            @"detail":NSLocalizedString(@"10.0%", nil)},
                          
                          @{@"image":@"icon_body_bf",
                            @"title":NSLocalizedString(@"记录你身体变化趋势", nil),
                            @"detail":NSLocalizedString(@"5.0%", nil)}
                        ];
    }
    return _arrTitleData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏
    [self setNavigation];
    
    self.bodyProfilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"bodyProfile.plist"];
    self.bodyNewProfilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"bodyNewProfile.plist"];
    self.bodyData= [[YJ_BodyProfile alloc] init];
    
#warning - 假数据字典
    //self.dicCurrentData = [NSMutableDictionary dictionaryWithObjects:@[@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0"] forKeys:@[@"height",@"weight",@"bust",@"waist",@"hip",@"fatRate"]];
    
    self.dicCurrentData = [NSMutableDictionary dictionary];
    
    //viewModel
    self.viewModel = [[YJ_BodyManageViewModel alloc] init];
    
    //请求数据
    [self handlerBodyData];
    
    //绘制视图
    [self drawUI];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"身体档案", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 绘制UI
- (void)drawUI {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.right.offset(0);
    }];
}

#pragma mark - 数据请求
- (void)handlerBodyData {
    [SVProgressHUD show];
    [self.viewModel handlerGetBodyDataSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        self.dicCurrentData = [NSMutableDictionary dictionaryWithDictionary: response[@"data"]];
        [self.tableView reloadData];
    } withFailureBlock:^(NSError *error) {
        [self showStatusWithError:[self returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrTitleData.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    }
    
    if (indexPath.section == 6) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = BGColor;
        UILabel *labTitle = [[UILabel alloc] init];
        labTitle.font = [UIFont systemFontOfSize:12];
        labTitle.textColor = [UIColor grayColor];
        labTitle.text = self.arrTitleData[indexPath.section][@"title"];
        [cell addSubview:labTitle];
        
        [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.offset(5);
            
        }];
        
        return cell;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.arrTitleData[indexPath.section][@"title"];
    
    cell.imageView.image = [UIImage imageNamed:self.arrTitleData[indexPath.section][@"image"]];
    CGSize itemSize = CGSizeMake(25, 25);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    switch (indexPath.section) {
        case 0:
        {
            NSString *string = [NSString stringWithFormat: @"%@cm", self.dicCurrentData[@"height"]];
            if([string isEqualToString:@"(null)cm"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        case 1:
        {
            NSString *string = [NSString stringWithFormat: @"%@kg", self.dicCurrentData[@"weight"]];
            if([string isEqualToString:@"(null)kg"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        case 2:
        {
            NSString *string = [NSString stringWithFormat: @"%@cm", self.dicCurrentData[@"bust"]];
            if([string isEqualToString:@"(null)cm"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        case 3:
        {
            NSString *string = [NSString stringWithFormat: @"%@cm", self.dicCurrentData[@"waist"]];
            if([string isEqualToString:@"(null)cm"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        case 4:
        {
            NSString *string = [NSString stringWithFormat: @"%@cm", self.dicCurrentData[@"hip"]];
            if([string isEqualToString:@"(null)cm"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        case 5:
        {
            NSString *string = [NSString stringWithFormat: @"%@%%", self.dicCurrentData[@"fatRate"]];
            if([string isEqualToString:@"(null)%"]) {
                cell.detailTextLabel.text = @"";
            }else {
                cell.detailTextLabel.text = string;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - 选择cell跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YJ_InputAlertView *alertView = [[YJ_InputAlertView alloc] init];
    __weak typeof(self) weakSelf = self;
    alertView.callback = ^(NSString *inputString) {
        switch (indexPath.section) {
            case 0:
            {
                [self.dicCurrentData setObject:inputString forKey:@"height"];
            }
                break;
            case 1:
            {
                [self.dicCurrentData setObject:inputString forKey:@"weight"];
            }
                break;
            case 2:
            {
                [self.dicCurrentData setObject:inputString forKey:@"bust"];
            }
                break;
            case 3:
            {
                [self.dicCurrentData setObject:inputString forKey:@"waist"];
            }
                break;
            case 4:
            {
                [self.dicCurrentData setObject:inputString forKey:@"hip"];
            }
                break;
            case 5:
            {
                [self.dicCurrentData setObject:inputString forKey:@"fatRate"];
            }
                break;
            default:
                break;
                
        }
        
        NSLog(@"%@", self.dicCurrentData);

        //提交数据
        [weakSelf.viewModel handlerPostBodyData:self.dicCurrentData withSuccessBlock:^(id response) {
        } withFailureBlock:^(NSError *error) {
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
        
        [self.tableView reloadData];
    };
    
    switch (indexPath.section) {
        case 0:
            [alertView showAlertTitle:@"身高" withUnit:@"cm" withImageName:@"icon_alert_height"];
            break;
        case 1:
            [alertView showAlertTitle:@"体重" withUnit:@"kg" withImageName:@"icon_alert_weight"];
            break;
        case 2:
            [alertView showAlertTitle:@"胸围" withUnit:@"cm" withImageName:@"icon_alert_bust"];
            break;
        case 3:
            [alertView showAlertTitle:@"腰围" withUnit:@"cm" withImageName:@"icon_alert_waist"];
            break;
        case 4:
            [alertView showAlertTitle:@"臀围" withUnit:@"cm" withImageName:@"icon_alert_hip"];
            break;
        case 5:
            [alertView showAlertTitle:@"体脂率" withUnit:@"%" withImageName:@"icon_alert_bf"];
            break;
        case 6:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        default:
            break;
    }
    
}

//[self saveBodyProfile:self.dicCurrentData withProfilePath:self.bodyProfilePath];
//[self.dicCurrentData setObject:inputString forKey:@"height"];
//[self saveBodyProfile:self.dicCurrentData withProfilePath:self.bodyNewProfilePath];
//
//YJ_BodyProfile *oldBodyData = [self readProfile:self.bodyProfilePath];
//YJ_BodyProfile *newBodyData = [self readProfile:self.bodyNewProfilePath];
//NSLog(@"%@,%@", oldBodyData, newBodyData);

#pragma mark - 本地存储数据
- (void)saveBodyProfile:(NSDictionary *)dictionary withProfilePath:(NSString *)profilePath
{
    NSMutableDictionary *profile = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:profilePath]) {
        profile = [NSMutableDictionary dictionaryWithContentsOfFile:profilePath];
    } else {
        profile = [NSMutableDictionary dictionary];
    }
    
    profile = [dictionary mutableCopy];
    
    if ([profile writeToFile:profilePath atomically:YES]) {
        NSLog(@"write user bodyProfile successfully");
    } else {
        NSLog(@"write user bodyProfile failure");
    }
}

- (YJ_BodyProfile *)readProfile:(NSString *)profilePath
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:profilePath];
    NSLog(@"read profile :%@", dictionary);
    return [[YJ_BodyProfile alloc] initWithDictionary:dictionary];
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

//设置分区头区域的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooderInSection:(NSInteger)section
{
    return 0.01f;
}

//设置分区尾区域的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 8;
    }
    return 5;
}

//view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BGColor;
    return view;
}

//返回
- (void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
