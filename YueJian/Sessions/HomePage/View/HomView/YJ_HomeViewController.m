//
//  YJ_HomeViewController.m
//  YueJian
//
//  Created by LG on 2018/5/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_HomeViewController.h"
#import "YJ_HealthKitManage.h"
#import "YJ_HomeViewModel.h"
#import "GifView.h"
#import "YJ_ScaleCircle.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "YJ_HomeModel.h"
#import "YJ_LoginViewController.h"
#import "YJ_MyTargetViewController.h"
#import "YJ_RunningViewController.h"
#import "MJRefresh.h"
#import "ZJCommitViewController.h"

@interface YJ_HomeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, AMapLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YJ_HomeViewModel *viewModel;
@property (nonatomic, strong) YJ_ScaleCircle *circle;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *weatherLabel;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *airStatusLabel;
@property (nonatomic, strong) UILabel *isPlayLabel;
@property (nonatomic, strong) UILabel *distanceValue;
@property (nonatomic, strong) UILabel *tiemValue;
@property (nonatomic, strong) UILabel *kaValue;
@property (nonatomic, strong) UIImageView *weatherImageView;
@property (nonatomic, strong) NSMutableArray *weatherArray;
@property (nonatomic, strong) NSMutableArray *airQualiyArray;
@property (nonatomic, strong) UIButton *targetBtn;
@end

@implementation YJ_HomeViewController

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //viewModel
    self.viewModel = [[YJ_HomeViewModel alloc] init];
    
    //绘制视图
    [self drawUI];
}

#pragma mark - 定位请求
- (void)singlelocationManager
{
    [SVProgressHUD show];
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    //带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    //[self.locationManager setAllowsBackgroundLocationUpdates:YES];
    [self.locationManager setLocationTimeout:10];
    [self.locationManager setReGeocodeTimeout:5];
    
    //带逆地理（返回坐标和地址信息）将下面代码中的YES改成NO 则不会返回地址信息
    __weak typeof(self) weakSelf = self;
    [weakSelf.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            [SVProgressHUD dismiss];
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            [weakSelf handlerGetHomeWeatherData:@"北京"];
            return;
        }
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            //获取位置信息
            NSLog(@"location:%@", regeocode.city);
            if (regeocode.city == NULL) {
                [weakSelf handlerGetHomeWeatherData:@"北京"];
            }else {
                [weakSelf handlerGetHomeWeatherData:regeocode.city];
            }
        }
    }];
}

#pragma mark - 天气数据请求
- (void)handlerGetHomeWeatherData:(NSString *)localCity {
    //获取温度
    __weak typeof(self) weakSelf = self;
    [weakSelf.viewModel handlerGetHomeWeatherData:localCity withSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        NSArray *array = response[@"HeWeather6"];
        NSMutableArray *responseMutArray= [NSMutableArray array];
        for (NSDictionary *dic in array) {
            YJ_HomeModel *tmp =  [[YJ_HomeModel alloc] initWeatherWithDictionary:dic];
            [responseMutArray addObject:tmp];
        }
        weakSelf.weatherArray = [responseMutArray copy];
        YJ_HomeModel *tmpModel = self.weatherArray[0];
        weakSelf.cityLabel.text = tmpModel.location;
        weakSelf.weatherLabel.text = tmpModel.condText;
        weakSelf.temperatureLabel.text = [NSString stringWithFormat:@"%@℃", tmpModel.temperature];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", tmpModel.condCode]];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        weakSelf.weatherImageView.image = image;
        weakSelf.weatherImageView.tintColor = [UIColor whiteColor];
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
    
    //获取空气质量
    [self.viewModel handlerGetHomeAirQualityData:localCity withSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        NSArray *array = response[@"HeWeather6"];
        NSMutableArray *responseMutArray= [NSMutableArray array];
        for (NSDictionary *dic in array) {
            YJ_HomeModel *tmp =  [[YJ_HomeModel alloc] initAirQualityWithDictionary:dic];
            [responseMutArray addObject:tmp];
        }
        weakSelf.airQualiyArray = [responseMutArray copy];
        YJ_HomeModel *tmpModel = weakSelf.airQualiyArray[0];
        weakSelf.airStatusLabel.text = tmpModel.airQuality;
        if ([tmpModel.airQuality isEqualToString:@"优"] || [tmpModel.airQuality isEqualToString:@"良"]) {
            //健康离不开阳光赶紧运动起来!
            weakSelf.isPlayLabel.text = @"空气清新 赶紧运动起来";
        }else {
            //目前空气质量不适合户外运动!
            weakSelf.isPlayLabel.text = @"不适合户外运动";
        }
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

- (void)handlerTargetStepData {
    __weak typeof(self) weakSelf = self;
    if ([[YJ_APIManager sharedInstance] isLoggedIn]) {
        [weakSelf.viewModel handlerGetHomeTargetStepDataWithSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            [weakSelf.targetBtn setTitle:[NSString stringWithFormat:@"%@步 >", response[@"data"][@"targetStep"]] forState:UIControlStateNormal];
            //停止刷新
            [weakSelf.tableView.mj_header endRefreshing];
        } withFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
            //停止刷新
            [weakSelf.tableView.mj_header endRefreshing];
        }];
    }else {
        [self.targetBtn setTitle:@"-- >" forState:UIControlStateNormal];
        //停止刷新
        [weakSelf.tableView.mj_header endRefreshing];
    }
}

#pragma mark - 初始化UITableView
- (void)drawUI {
    //状态栏
    int rectStatus = [[UIApplication sharedApplication] statusBarFrame].size.height;
    //导航栏
    int rectNav = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"head%d", rectStatus + rectNav);
    //根据导航栏高度适配iphoneX
    if ((rectStatus + rectNav) == 64) {
        //初始化tableview
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -84, SCREEN_WIDTH, SCREEN_HEIGHT + 84) style:UITableViewStyleGrouped];
    }else {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -98, SCREEN_WIDTH, SCREEN_HEIGHT + 98) style:UITableViewStyleGrouped];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = TableViewBGColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.bounces = NO;
    [self.view addSubview:self.tableView];
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadHomeData)];
    //设置动画(自动调用loadNewDeals)
    [self.tableView.mj_header beginRefreshing];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - 请求数据
- (void)loadHomeData {
    //获取步数
    [self handlerStepData];
    //获取距离
    [self handlerDistanceData];
    //获取目标步数
    [self handlerTargetStepData];
    //定位请求天气数据
    [self singlelocationManager];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    switch (indexPath.section) {
        case 0:
            [self createStepView:cell];
            break;
        case 1:
            [self createStepDetailView:cell];
            break;
        case 2:
            [self createHealthManageView:cell];
            break;
        case 3:
            [self createStartGoView:cell];
            break;
        default:
            break;
    }
    
    return cell;
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            return 340;
        }
            break;
        case 1:
        {
            return 210;
        }
            break;
        case 2:
        {
            return 190;
        }
            break;
        case 3:
        {
            return 180;
        }
            break;
        default:
            break;
    }
    return 0;
}

//选择cell跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//设置分区头区域的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//设置分区尾区域的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 0;
    }
    return 10;
}

//fooderView
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *fooderView = [[UIView alloc] init];
    fooderView.backgroundColor = BGColor;
    return fooderView;
}

#pragma mark - 创建步数视图
- (void)createStepView:(UITableViewCell *)cell {
    //创建视图
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"img_home_bgsteps"];
    [cell.contentView addSubview:imageView];
    
    //图片
    self.weatherImageView = [[UIImageView alloc] init];
    [cell.contentView addSubview:self.weatherImageView];
    
    //城市名称
    self.cityLabel = [[UILabel alloc] init];
    self.cityLabel.text = @"--";
    self.cityLabel.textColor = [UIColor whiteColor];
    self.cityLabel.font = [UIFont systemFontOfSize:15];
    [self.cityLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.cityLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:self.cityLabel];
    
    //白线
    UIView *lineTopView = [[UIView alloc] init];
    lineTopView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:lineTopView];
    
    //天气状况
    self.weatherLabel = [[UILabel alloc] init];
    self.weatherLabel.text = @"--";
    self.weatherLabel.textColor = [UIColor whiteColor];
    self.weatherLabel.font = [UIFont systemFontOfSize:15];
    [self.weatherLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.weatherLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:self.weatherLabel];
    
    //温度
    self.temperatureLabel = [[UILabel alloc] init];
    self.temperatureLabel .text = @"--℃";
    self.temperatureLabel .textColor = [UIColor whiteColor];
    self.temperatureLabel .font = [UIFont systemFontOfSize:43 weight:0.2];
    [self.temperatureLabel  setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.temperatureLabel  setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:self.temperatureLabel];
    
    //空气质量
    self.airStatusLabel = [[UILabel alloc] init];
    self.airStatusLabel.text = @"--";
    self.airStatusLabel.textColor = [UIColor whiteColor];
    self.airStatusLabel.font = [UIFont systemFontOfSize:15];
    [self.airStatusLabel  setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.airStatusLabel  setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [cell.contentView addSubview:self.airStatusLabel];
    
    //白线
    UIView *lineBomView = [[UIView alloc] init];
    lineBomView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:lineBomView];
    
    //建议运动
    self.isPlayLabel = [[UILabel alloc] init];
    self.isPlayLabel.text = @"--";
    self.isPlayLabel.textColor = [UIColor whiteColor];
    self.isPlayLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:self.isPlayLabel];
    
    //步数
    self.circle = [[YJ_ScaleCircle alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 156)/2, 164, 156, 156)];
    //四个区域的颜色
    self.circle.firstColor = ThemeColor;
    self.circle.secondColor = TableViewBGColor;
    //四个区域所占的比例
    self.circle.firstScale = 0.6;
    self.circle.secondScale = 0.4;
    //线宽
    self.circle.lineWith = 8.5;
    //未填充颜色
    self.circle.unfillColor = [UIColor clearColor];
    //动画时长
    self.circle.animation_time = 3.0;
    [cell.contentView addSubview:self.circle];
    
    //添加约束
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.right.mas_offset(0);
    }];
    
    [self.weatherImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.left.offset(40);
        make.height.offset(90);
        make.width.offset(90);
    }];
    
    [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(55);
        make.left.offset(140);
        make.height.offset(15);
    }];
    
    [lineTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(55);
        make.left.equalTo(self.cityLabel.mas_right).with.offset(8);
        make.width.offset(1);
        make.height.offset(15);
    }];
    
    [self.weatherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(55);
        make.left.equalTo(lineTopView.mas_right).with.offset(8);
        make.height.offset(15);
    }];
    
    [self.temperatureLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cityLabel.mas_bottom).with.offset(5);
        make.left.offset(140);
        make.width.offset(120);
        make.height.offset(46);
    }];
    
    [self.airStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.temperatureLabel .mas_bottom).with.offset(5);
        make.left.offset(140);
        make.height.offset(15);
    }];
    
    [lineBomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.temperatureLabel .mas_bottom).with.offset(5);
        make.left.equalTo(self.airStatusLabel.mas_right).with.offset(8);
        make.width.offset(1);
        make.height.offset(15);
    }];
    
    [self.isPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.temperatureLabel .mas_bottom).with.offset(5);
        make.left.equalTo(lineBomView.mas_right).with.offset(8);
        make.right.offset(-5);
        make.height.offset(15);
    }];
}

#pragma mark - 创建步数详情
- (void)createStepDetailView:(UITableViewCell *)cell {
    //运动距离
    UIImageView *stepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_steps"]];
    [cell.contentView addSubview:stepImageView];
    
    UILabel *distanceTitle = [[UILabel alloc] init];
    distanceTitle.text = @"今日的运动距离:";
    distanceTitle.textColor = [UIColor blackColor];
    distanceTitle.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:distanceTitle];
    
    self.distanceValue = [[UILabel alloc] init];
    self.distanceValue.text = @"--";
    self.distanceValue.textColor = [UIColor grayColor];
    self.distanceValue.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:self.distanceValue];
    
    //运动时间
    UIImageView *timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_time"]];
    [cell.contentView addSubview:timeImageView];
    
    UILabel *distanceTime = [[UILabel alloc] init];
    distanceTime.text = @"运动时间:";
    distanceTime.textColor = [UIColor blackColor];
    distanceTime.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:distanceTime];
    
    self.tiemValue = [[UILabel alloc] init];
    self.tiemValue.text = @"--";
    self.tiemValue.textColor = [UIColor grayColor];
    self.tiemValue.font = [UIFont systemFontOfSize:14];
    //distanceValue.backgroundColor = BGColor;
    [cell.contentView addSubview:self.tiemValue];
    
    //消耗卡路里
    UIImageView *kaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_fire"]];
    [cell.contentView addSubview:kaImageView];
    
    UILabel *distanceKa = [[UILabel alloc] init];
    distanceKa.text = @"消耗的热量:";
    distanceKa.textColor = [UIColor blackColor];
    distanceKa.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:distanceKa];
    
    self.kaValue = [[UILabel alloc] init];
    self.kaValue.text = @"--";
    self.kaValue.textColor = [UIColor grayColor];
    self.kaValue.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:self.kaValue];
    
    UILabel *todayLabel = [[UILabel alloc] init];
    todayLabel.text = @"运动目标";
    todayLabel.textColor = [UIColor blackColor];
    todayLabel.font = [UIFont systemFontOfSize:18];
    todayLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:todayLabel];
    
    self.targetBtn = [[UIButton alloc] init];
    self.targetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn.layer setMasksToBounds:YES];
    [self.targetBtn.layer setCornerRadius:10.0];
    [self.targetBtn.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){238/255, 238/255, 238/255, 0.1});
    [self.targetBtn.layer setBorderColor:colorref];
    [self.targetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.targetBtn setTitle:@"-- >" forState:UIControlStateNormal];
    [cell.contentView addSubview:self.targetBtn];
    
    //添加约束
    [stepImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.offset(20);
        make.width.offset(30);
        make.height.offset(30);
    }];
    
    [distanceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.equalTo(stepImageView.mas_right).with.offset(15);
        make.width.offset(140);
        make.height.offset(18);
    }];
    
    [self.distanceValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(distanceTitle.mas_bottom).with.offset(5);
        make.left.equalTo(stepImageView.mas_right).with.offset(15);
        make.width.offset(140);
        make.height.offset(16);
    }];
    
    [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stepImageView.mas_bottom).with.offset(30);
        make.left.offset(20);
        make.width.offset(30);
        make.height.offset(30);
    }];
    
    [distanceTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stepImageView.mas_bottom).with.offset(30);
        make.left.equalTo(timeImageView.mas_right).with.offset(15);
        make.width.offset(140);
        make.height.offset(18);
    }];
    
    [self.tiemValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(distanceTime.mas_bottom).with.offset(5);
        make.left.equalTo(timeImageView.mas_right).with.offset(15);
        make.width.offset(140);
        make.height.offset(16);
    }];
    
    [kaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeImageView.mas_bottom).with.offset(30);
        make.left.offset(20);
        make.width.offset(30);
        make.height.offset(30);
    }];
    
    [distanceKa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeImageView.mas_bottom).with.offset(30);
        make.left.equalTo(kaImageView.mas_right).with.offset(15);
        make.width.offset(160);
        make.height.offset(18);
    }];
    
    [self.kaValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(distanceKa.mas_bottom).with.offset(5);
        make.left.equalTo(kaImageView.mas_right).with.offset(15);
        make.width.offset(140);
        make.height.offset(16);
    }];
    
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(-25);
        make.width.offset(90);
        make.right.offset(-40);
        make.height.offset(25);
    }];
    
    [self.targetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(todayLabel.mas_bottom).with.offset(10);
        make.right.offset(-45);
        make.height.offset(28);
        make.width.offset(80);
    }];
    
    [[self.targetBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if ([[YJ_APIManager sharedInstance] isLoggedIn]) {
            YJ_MyTargetViewController *targetVC = [[YJ_MyTargetViewController alloc] init];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:targetVC];
            [self presentViewController:navc animated:YES completion:nil];
            targetVC.callback = ^(NSString *meter){
                NSLog(@"%@", meter);
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.targetBtn setTitle:[NSString stringWithFormat:@"%@步 >", meter] forState:UIControlStateNormal];
            };
        }else {
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
            YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navc animated:YES completion:nil];
            loginVC.callback = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                    [self handlerTargetStepData];
                    /*if([[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        YJ_MyTargetViewController *targetVC = [[YJ_MyTargetViewController alloc] init];
                        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:targetVC];
                        [self presentViewController:navc animated:YES completion:nil];
                        targetVC.callback = ^(NSString *meter){
                            NSLog(@"%@", meter);
                            [self dismissViewControllerAnimated:YES completion:nil];
                            [self.targetBtn setTitle:[NSString stringWithFormat:@"%@步 >", meter] forState:UIControlStateNormal];
                        };
                    }*/
                });
            };
        }
    }];
}

#pragma mark - 创建健康专题界面
- (void)createHealthManageView:(UITableViewCell *)cell {
    //健康专题
    UIImageView *healthImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_health"]];
    [cell.contentView addSubview:healthImageView];
    
    UILabel *healthTitle = [[UILabel alloc] init];
    healthTitle.text = @"精选专题";
    healthTitle.textColor = [UIColor blackColor];
    healthTitle.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:healthTitle];

    //添加约束
    [healthImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15);
        make.left.offset(20);
        make.width.height.offset(25);
    }];
    
    [healthTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(16);
        make.left.equalTo(healthImageView.mas_right).with.offset(10);
        make.width.offset(140);
        make.height.offset(20);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    [cell.contentView addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthImageView.mas_bottom).with.offset(10);
        make.bottom.left.right.offset(0);
    }];
    
    //scrollView.contentSize = CGSizeMake(120*3+60, 120);
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 120);

    //设置边界回弹,弹出一片白
    scrollView.bounces = NO;
    //隐藏滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    //设置滚动视图的图片内容
    for (int i=0; i<3; i++) {
        //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*130+30, 0, 100, 120)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*((SCREEN_WIDTH-100)/3+25)+25, 0, (SCREEN_WIDTH-100)/3, 120)];
        view.layer.cornerRadius = 10;
        view.layer.borderWidth = 1;
        view.tag = i;
        view.layer.borderColor = BGColor.CGColor;
        [scrollView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //添加图片到滚动视图里
        [view addSubview:imageView];
        //开启用户交互
        imageView.userInteractionEnabled = YES;
        //设置tag标记
        imageView.tag = i;
        //创建轻拍手势器
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHotMenuAction:)];
        //添加手势到图片上
        [view addGestureRecognizer:tap];
        [scrollView addSubview:view];
        
        UILabel *label = [[UILabel alloc] init];
        switch (i) {
            case 0: {
                //设置图片内容
                imageView.image = [UIImage imageNamed:@"icon_home_manage"];
                label.text = NSLocalizedString(@"身体档案", nil);
            }
                break;
            case 1: {
                imageView.image = [UIImage imageNamed:@"icon_home_signs"];
                label.text = NSLocalizedString(@"目标签到", nil);
            }
                break;
            case 2: {
                imageView.image = [UIImage imageNamed:@"icon_home_eat"];
                label.text = NSLocalizedString(@"热门动态", nil);
            }
                break;
            default:
                break;
        }
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.offset(15);
            make.right.offset(-15);
            make.height.offset(50);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).with.offset(15);
            make.centerX.offset(0);
            make.height.offset(15);
            make.width.offset(60);
        }];
    }
}

#pragma mark - 创建Go视图
- (void)createStartGoView:(UITableViewCell *)cell {
    //运动圈
    UIImageView *healthImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_play"]];
    [cell.contentView addSubview:healthImageView];
    
    UILabel *healthTitle = [[UILabel alloc] init];
    healthTitle.text = @"运动圈";
    healthTitle.textColor = [UIColor blackColor];
    healthTitle.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:healthTitle];
    
    //运动记录
    UIImageView *recordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_playrecord"]];
    [cell.contentView addSubview:recordImageView];
    
    UIButton *recordBtn = [[UIButton alloc] init];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [recordBtn setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cell.contentView addSubview:recordBtn];
    
    //Go
    UIButton * goButton = [[UIButton alloc] init];
    goButton.titleLabel.font = [UIFont systemFontOfSize:40 weight:0.3];
    goButton.layer.cornerRadius = 50;
    goButton.layer.borderWidth = 1.0;
    goButton.layer.borderColor =[UIColor clearColor].CGColor;
    goButton.clipsToBounds = TRUE;//去除边界
    //goButton.backgroundColor = SubColor;
    [goButton setTitle:@"" forState:UIControlStateNormal];
    [goButton  setBackgroundImage:[UIImage imageNamed:@"icon_home_running"] forState:UIControlStateNormal];
    [cell.contentView addSubview:goButton];
    
    UILabel *goLabel = [[UILabel alloc] init];
    goLabel.text = @"开始跑步";
    goLabel.textColor = [UIColor grayColor];
    goLabel.textAlignment = NSTextAlignmentCenter;
    goLabel.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:goLabel];
    
    //添加约束
    [healthImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15);
        make.left.offset(20);
        make.width.height.offset(25);
    }];
    
    [healthTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(16);
        make.left.equalTo(healthImageView.mas_right).with.offset(10);
        make.width.offset(140);
        make.height.offset(20);
    }];
    
    [recordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.right.offset(-20);
        make.width.height.offset(25);
    }];
    
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.right.equalTo(recordImageView.mas_left).offset(-5);
        make.width.offset(70);
        make.height.offset(20);
    }];
    
    [goButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(healthImageView.mas_bottom).with.offset(0);
        make.width.height.offset(100);
    }];
    
    [goLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(goButton.mas_bottom).with.offset(10);
        make.width.offset(70);
        make.height.offset(16);
    }];
    
    [[goButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self performSegueWithIdentifier:@"RunningPage" sender:nil];
    }];
    
  /*UIImageView *goImageView = [[UIImageView alloc] init];
    goImageView.layer.masksToBounds = YES;
    goImageView.layer.cornerRadius = 100/2;
    goImageView.layer.borderWidth = 1.0;
    [goImageView setUserInteractionEnabled:YES];
    goImageView.layer.borderColor = BGColor.CGColor;
    [cell.contentView addSubview:goImageView];

    //添加约束
    [goImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(0);
        make.width.height.offset(100);
    }];*/
}

//手势识别器的触发事件
- (void)tapHotMenuAction:(UITapGestureRecognizer *)tap {
    //获取当前图片的tag值
    int i = (int)tap.view.tag;
    switch (i) {
        case 0:
        {
            if([[YJ_APIManager sharedInstance] isLoggedIn])
            {
                [self performSegueWithIdentifier:@"BodyManage" sender:nil];
            }
            else
            {
                UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
                YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
                UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self presentViewController:navc animated:YES completion:nil];
                loginVC.callback = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:nil];
                        if([[YJ_APIManager sharedInstance] isLoggedIn])
                        {
                            [self performSegueWithIdentifier:@"TrafficRecord" sender:nil];
                        }
                    });
                };
            }
        }
            break;
        case 1:
        {
            if([[YJ_APIManager sharedInstance] isLoggedIn])
            {
                [self performSegueWithIdentifier:@"SignPage" sender:nil];
            }
            else
            {
                UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
                YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
                UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self presentViewController:navc animated:YES completion:nil];
                loginVC.callback = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:nil];
                        if([[YJ_APIManager sharedInstance] isLoggedIn])
                        {
                            [self performSegueWithIdentifier:@"SignPage" sender:nil];
                        }
                    });
                };
            }
        }
            break;
        case 2:
        {
            ZJCommitViewController *commmit = [[ZJCommitViewController alloc] init];
            [self.navigationController pushViewController:commmit animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 获取步数
- (void)handlerStepData {
    YJ_HealthKitManage *manage = [YJ_HealthKitManage shareInstance];
    [manage authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            [manage getStepCount:^(double stepValue, double timeValue, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //中心标签的显示数值
                    self.circle.centerLable.text = [NSString stringWithFormat:@"%.0f", stepValue];
                    int h = timeValue / 3600;
                    int m = ((long)timeValue % 3600)/60;
                    self.tiemValue.text = [NSString stringWithFormat:@"%@小时%@分钟", @(h), @(m)];
                    if (h >= 1) {
                        self.kaValue.text = [NSString stringWithFormat:@"%d卡路里", h*255+255/60*m];
                    }else if (m > 0) {
                        self.kaValue.text = [NSString stringWithFormat:@"%d卡路里", 75];
                    }
                });
            }];
        }
        else {
            NSLog(@"fail");
        }
    }];
}

#pragma mark - 获取距离
- (void)handlerDistanceData {
    YJ_HealthKitManage *manage = [YJ_HealthKitManage shareInstance];
    [manage authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            [manage getDistance:^(double value, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.distanceValue.text = [NSString stringWithFormat:@"%.2f公里", value];
                });
            }];
        }
        else {
            NSLog(@"fail");
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
