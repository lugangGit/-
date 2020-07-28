//
//  YJ_RunningViewController.m
//  YueJian
//
//  Created by Garry on 2018/7/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RunningViewController.h"
#import "YJ_CountdownView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "YJ_RunningRecordViewController.h"
#import "YJ_RunningAlertView.h"

@interface YJ_RunningViewController ()<YJ_CountdownViewDelegate, AMapLocationManagerDelegate, MAMapViewDelegate>
{
    MAMultiPolyline * _polyline;
    double totalMeters;
    int annotationType;
}
@property (nonatomic, strong) YJ_CountdownView *countdownView;
@property (nonatomic, assign) dispatch_once_t onceDispatch;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isShowMap;
@property (nonatomic, assign) BOOL isShowPause;
@property (nonatomic, assign) BOOL isShowColor;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) int pauseCount;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UILabel *labDistance;
@property (nonatomic, strong) UILabel *labSpeed;
@property (nonatomic, strong) UIColor *lineColor;
//位置管理者
@property (nonatomic, strong) AMapLocationManager *locationManager;
//存放用户位置的数组
@property (nonatomic, strong) NSMutableArray *locationMutableArray;
//地图
@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation YJ_RunningViewController

#pragma mark - 位置管理者懒加载
- (AMapLocationManager *)locationManager
{
    if (_locationManager == nil)
    {
        _locationManager = [[AMapLocationManager alloc] init];
        
        //设置定位的精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        //位置信息更新最小距离
        _locationManager.distanceFilter = 5;
        
        //设置代理
        _locationManager.delegate = self;
        
        //如果没有授权则请求用户授权,
        //因为 requestAlwaysAuthorization 是 iOS8 后提出的,需要添加一个是否能响应的条件判断,防止崩溃
//        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined && [_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            [_locationManager requestAlwaysAuthorization];
//        }
    }
    return _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏
    [self setNavigation];
    
    //绘制视图
    [self drawUI];

    //创建存放位置的数组
    _locationMutableArray = [[NSMutableArray alloc] init];
    
    self.isShowPause = YES;
    self.isShowColor = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //倒计时开始
    [self.countdownView startAnimationCountdownWithTime:3];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // 子视图的设置只需要设置一次，否则会导致拖动下拉按钮位置闪烁的问题。
    dispatch_once(&_onceDispatch, ^{
        self.countdownView.frame = self.view.bounds;
    });
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - 绘制UI
- (void)drawUI {
    //添加View背景
    UIImageView *imageViewBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_running_background"]];
    [self.view addSubview:imageViewBg];
    
    [imageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    //地图视图
    [AMapServices sharedServices].enableHTTPS = YES;
    ///初始化地图
    _mapView = [[MAMapView alloc] init];
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    [_mapView setZoomLevel:16 animated:YES];
    _mapView.hidden = YES;
    self.isShowMap = NO;
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    ///把地图添加至view
    [self.view addSubview:_mapView];
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    UIImageView *imageViewMapBg = [[UIImageView alloc] init];
    imageViewMapBg.backgroundColor = RGBA(0, 0, 0, 0.1);
    imageViewMapBg.hidden = YES;
    [self.view addSubview:imageViewMapBg];
    
    [imageViewMapBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    //地图模式
    UIButton * btnMapModel = [[UIButton alloc] init];
    //btnMapModel.layer.cornerRadius = 15;
    btnMapModel.layer.borderWidth = 1.0;
    btnMapModel.layer.borderColor =[UIColor clearColor].CGColor;
    btnMapModel.clipsToBounds = TRUE;//去除边界
    [btnMapModel  setBackgroundImage:[UIImage imageNamed:@"icon_running_mapMode"] forState:UIControlStateNormal];
    [self.view addSubview:btnMapModel];
    
    [btnMapModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(40);
        make.right.offset(-80);
        make.width.height.offset(35);
    }];
    
    UILabel *labMapModel = [[UILabel alloc] init];
    labMapModel.font = [UIFont fontWithName:@"Helvetica" size:14];
    labMapModel.textColor = [UIColor whiteColor];
    labMapModel.text = @"地图模式";
    labMapModel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:labMapModel];
    
    [labMapModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(48);
        make.left.equalTo(btnMapModel.mas_right).offset(5);
        make.right.offset(0);
        make.height.offset(20);
    }];
    
    //时间视图
    self.labTime = [[UILabel alloc] init];
    self.labTime.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:55];
    self.labTime.textColor = [UIColor whiteColor];
    self.labTime.text = @"00:00:00";
    self.labTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labTime];
    
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(170);
        make.left.offset(20);
        make.right.offset(-20);
        make.height.offset(55);
    }];
    
    //公里视图
    self.labDistance = [[UILabel alloc] init];
    self.labDistance.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:35];
    self.labDistance.textColor = [UIColor whiteColor];
    self.labDistance.text = @"00.00";
    self.labDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labDistance];
    
    [self.labDistance mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labTime.mas_bottom).offset(50);
        make.left.offset(0);
        make.height.offset(40);
        make.width.offset(SCREEN_WIDTH/2);
    }];
    
    UILabel *labDistanceUnit = [[UILabel alloc] init];
    labDistanceUnit.font = [UIFont fontWithName:@"Helvetica" size:14];
    labDistanceUnit.textColor = [UIColor whiteColor];
    labDistanceUnit.text = @"距离(公里)";
    labDistanceUnit.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labDistanceUnit];
    
    [labDistanceUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labDistance.mas_bottom).offset(10);
        make.left.offset(0);
        make.height.offset(20);
        make.width.offset(SCREEN_WIDTH/2);
    }];
    
    //配速视图
    self.labSpeed = [[UILabel alloc] init];
    self.labSpeed.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:35];
    self.labSpeed.textColor = [UIColor whiteColor];
    self.labSpeed.text = @"00.00";
    self.labSpeed.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labSpeed];
    
    [self.labSpeed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labTime.mas_bottom).offset(50);
        make.left.equalTo(self.labDistance.mas_right).offset(0);
        make.right.offset(0);
        make.height.offset(40);
    }];
    
    UILabel *labSpeedUnit = [[UILabel alloc] init];
    labSpeedUnit.font = [UIFont fontWithName:@"Helvetica" size:14];
    labSpeedUnit.textColor = [UIColor whiteColor];
    labSpeedUnit.text = @"配速(分/公里)";
    labSpeedUnit.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labSpeedUnit];
    
    [labSpeedUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labDistance.mas_bottom).offset(10);
        make.left.equalTo(labDistanceUnit.mas_right).offset(0);
        make.right.offset(0);
        make.height.offset(20);
    }];
    
    //继续
    UIButton * btnContinue = [[UIButton alloc] init];
    btnContinue.layer.cornerRadius = 40;
    btnContinue.layer.borderWidth = 1.0;
    btnContinue.layer.borderColor =[UIColor clearColor].CGColor;
    btnContinue.clipsToBounds = TRUE;//去除边界
    btnContinue.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [btnContinue setTitleColor:RGBA(4,181,108,1.0) forState:UIControlStateNormal];
    [btnContinue setTitle:@"继续" forState:UIControlStateNormal];
    [self.view addSubview:btnContinue];
    
    [btnContinue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-110);
        make.centerX.offset(0);
        make.width.height.offset(80);
    }];
    
    //完成
    UIButton * btnFinish = [[UIButton alloc] init];
    btnFinish.layer.cornerRadius = 40;
    btnFinish.layer.borderWidth = 1.0;
    btnFinish.layer.borderColor =[UIColor clearColor].CGColor;
    btnFinish.clipsToBounds = TRUE;//去除边界
    btnFinish.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [btnFinish setTitleColor:RGBA(4,181,108,1.0) forState:UIControlStateNormal];
    [btnFinish setTitle:@"完成" forState:UIControlStateNormal];
    [self.view addSubview:btnFinish];
    
    [btnFinish mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-110);
        make.centerX.offset(0);
        make.width.height.offset(80);
    }];
    
    //暂停
    UIButton * btnPause = [[UIButton alloc] init];
    btnPause.layer.cornerRadius = 50;
    btnPause.layer.borderWidth = 1.0;
    btnPause.layer.borderColor =[UIColor clearColor].CGColor;
    btnPause.clipsToBounds = TRUE;//去除边界
    btnPause.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [btnPause setTitleColor:RGBA(4,181,108,1.0) forState:UIControlStateNormal];
    [btnPause setTitle:@"暂停" forState:UIControlStateNormal];
    //[btnPause setBackgroundImage:[UIImage imageNamed:@"icon_running_mapMode"] forState:UIControlStateNormal];
    [self.view addSubview:btnPause];
    
    [btnPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-100);
        make.centerX.offset(0);
        make.width.height.offset(100);
    }];
    
    //倒计时视图
    self.countdownView = [YJ_CountdownView new];
    self.countdownView.delegate = self;
    [self.view addSubview:self.countdownView];
    
    //按钮点击事件
    [[btnMapModel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        btnPause.hidden = NO;
        
        //计时继续
        [self continueRun];
        
        //开始定位
        [self.locationManager startUpdatingLocation];
        
        if (self.isShowMap) {
            self.isShowMap = NO;
            _mapView.hidden = YES;
            imageViewMapBg.hidden = YES;
            [btnMapModel  setBackgroundImage:[UIImage imageNamed:@"icon_running_mapMode"] forState:UIControlStateNormal];
            labMapModel.text = @"地图模式";
        }else {
            self.isShowMap = YES;
            _mapView.hidden = NO;
            imageViewMapBg.hidden = NO;
            [btnMapModel setBackgroundImage:[UIImage imageNamed:@"icon_running_runMode"] forState:UIControlStateNormal];
            labMapModel.text = @"跑步模式";
        }
        
    }];
    
    [[btnPause rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        //停止定位
        [self.locationManager stopUpdatingLocation];
        
        btnPause.hidden = YES;
        //设置动画的名字
        [UIButton beginAnimations:@"Animation" context:nil];
        //设置动画的间隔时间
        [UIButton setAnimationDuration:0.50];
        //使用当前正在运行的状态开始下一段动画
        [UIButton setAnimationBeginsFromCurrentState: YES];
        //设置视图移动的位移
        btnContinue.frame = CGRectMake(btnContinue.frame.origin.x-100, btnContinue.frame.origin.y, btnContinue.frame.size.width, btnContinue.frame.size.height);
        btnFinish.frame = CGRectMake(btnFinish.frame.origin.x+100, btnFinish.frame.origin.y, btnFinish.frame.size.width, btnFinish.frame.size.height);
        //设置动画结束
        [UIButton commitAnimations];
        
        //暂停计时
        [self pauseRun];
        self.pauseCount = self.count;
    }];
    
    [[btnContinue rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        //设置动画的名字
        [UIButton beginAnimations:@"Animation" context:nil];
        //设置动画的间隔时间
        [UIButton setAnimationDuration:0.50];
        //使用当前正在运行的状态开始下一段动画
        [UIButton setAnimationBeginsFromCurrentState: YES];
        //设置视图移动的位移
        btnContinue.frame = CGRectMake(btnContinue.frame.origin.x+100, btnContinue.frame.origin.y, btnContinue.frame.size.width, btnContinue.frame.size.height);
        btnFinish.frame = CGRectMake(btnFinish.frame.origin.x-100, btnFinish.frame.origin.y, btnFinish.frame.size.width, btnFinish.frame.size.height);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btnPause.hidden = NO;
        });
        //设置动画结束
        [UIButton commitAnimations];
        
        //继续计时
        [self continueRun];
        
        if ((self.count == self.pauseCount || self.count+1  == self.pauseCount) && self.count != 0) {
            self.isShowColor = NO;
        }
        
        //开始定位
        [self.locationManager startUpdatingLocation];

    }];
    
    [[btnFinish rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        btnContinue.enabled = NO;
        btnFinish.enabled = NO;
        //停止定位
        [self.locationManager stopUpdatingLocation];
        
        //停止计时
        [self stopRun];
        
        //结束大头针
        annotationType = 1;
        NSString *locationStr = _locationMutableArray.lastObject;
        NSArray *temp = [locationStr componentsSeparatedByString:@","];
        NSString *latitudeStr = temp[0];
        NSString *longitudeStr = temp[1];
        CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([latitudeStr doubleValue], [longitudeStr doubleValue]);
        [self addAnnotationWithCooordinate:endCoordinate];
        
        YJ_RunningAlertView *alertView = [[YJ_RunningAlertView alloc] init];
        alertView.callback = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        //平均速度
        double distance = [self.labDistance.text doubleValue];
        double hour = (double)self.count / 3600;
        double speed = distance / hour;
        NSString *speedStr = [NSString stringWithFormat:@"%0.2f", speed];
        if ([speedStr isEqualToString:@"nan"]) {
            speedStr = @"0.00";
        }
        //跑步热量（kcal）＝体重（kg）×距离（公里）×1.036
        double lcal = 120 * [self.labDistance.text doubleValue] / 3600;
        NSString *lcalStr = [NSString stringWithFormat:@"%0.2f", lcal];
        
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.6 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            btnFinish.enabled = YES;
//            [alertView showAlertDistance:self.labDistance.text withTime:self.labTime.text withSpeed:speedStr withKa:lcalStr];
//        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            btnFinish.enabled = YES;
            [alertView showAlertDistance:self.labDistance.text withTime:self.labTime.text withSpeed:speedStr withKa:lcalStr];
        });
        /*
        YJ_RunningRecordViewController *RrVC = [[YJ_RunningRecordViewController alloc] init];
        RrVC.locationMutableArray = self.locationMutableArray;
        [self.navigationController pushViewController:RrVC animated:YES];
        */
        
    }];
}

#pragma mark - MKMapViewDelegate
/**
 更新用户位置，只要用户改变则调用此方法（包括第一次定位到用户位置）
 第一种画轨迹的方法:我们使用在地图上的变化来描绘轨迹,这种方式不用考虑从 CLLocationManager 取出的经纬度在 mapView 上显示有偏差的问题
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    //设置地图比例
    [_mapView setZoomLevel:17 animated:YES];
    
    //当前位置经纬度
    NSString *latitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.longitude];
    NSLog(@"更新的用户位置:纬度:%@, 经度:%@",latitude,longitude);
    
    //设置地图中心点
    _mapView.centerCoordinate = location.coordinate;
    
    if (_locationMutableArray.count != 0) {
        //从位置数组中取出最新的位置数据
        NSString *locationStr = _locationMutableArray.lastObject;
        NSArray *temp = [locationStr componentsSeparatedByString:@","];
        NSString *latitudeStr = temp[0];
        NSString *longitudeStr = temp[1];
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake([latitudeStr doubleValue], [longitudeStr doubleValue]);
        
        //当前确定到的位置数据
        CLLocationCoordinate2D endCoordinate;
        endCoordinate.latitude = location.coordinate.latitude;
        endCoordinate.longitude = location.coordinate.longitude;
        
        //移动距离的计算
        double meters = [self calculateDistanceWithStart:startCoordinate end:endCoordinate];
        double speend = 0.0;
        double pace = 0.0;
        if (self.isShowColor) {
            totalMeters = meters + totalMeters;
            NSLog(@"移动的距离为%f米 %f", meters, totalMeters);
            
            //显示距离、配速
            speend = (meters/1000)/((double)self.count/60);
            pace = ((double)self.count/60)/(meters/1000);
            NSLog(@"speend:%f", speend);
            self.labSpeed.text = [NSString stringWithFormat:@"%0.2f", pace];
            double distance = totalMeters/1000;
            self.labDistance.text = [NSString stringWithFormat:@"%0.2f", distance];
        }

        //为了美化移动的轨迹,移动的位置超过10米,方可添加进位置的数组
        if (5 <= meters) {
            NSLog(@"添加进位置数组");
            NSString *locationString;
            if (self.isShowColor) {
                locationString = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude, location.coordinate.longitude];
            }else {
               locationString = [NSString stringWithFormat:@"%0.8f,%0.8f",location.coordinate.latitude, location.coordinate.longitude];
            }
            
            [_locationMutableArray addObject:locationString];
            
            //开始绘制轨迹
            CLLocationCoordinate2D pointsToUse[2];
            pointsToUse[0] = startCoordinate;
            pointsToUse[1] = endCoordinate;
            //调用 addOverlay 方法后,会进入 rendererForOverlay 方法,完成轨迹的绘制
            MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:2];
            self.lineColor = [self getColorForSpeed:speend];
            //_polyline = [MAMultiPolyline polylineWithCoordinates:_runningCoords count:_count drawStyleIndexes:indexes];
            [_mapView addOverlay:lineOne];
            
        }else {
            NSLog(@"不添加进位置数组");
        }
    }else {
        //开始计时
        [self startRun];
       
        //存放位置的数组,如果数组包含的对象个数为0,那么说明是第一次进入,将当前的位置添加到位置数组
        NSString *locationString = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude, location.coordinate.longitude];
        [_locationMutableArray addObject:locationString];
        [self addAnnotationWithCooordinate:location.coordinate];

    }
}

-(void)addAnnotationWithCooordinate:(CLLocationCoordinate2D)coordinate
{
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    static NSString *customReuseIndetifier = @"customReuseIndetifier";

    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        //当前位置AnnotationView
        if ([annotation isKindOfClass:[MAUserLocation class]]) {
            MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            }
            annotationView.image = [UIImage imageNamed:@"icon_running_local"];
            
            //自定义标记图标
            annotationView.canShowCallout = NO;
            return annotationView;
        }
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            annotationView.canShowCallout = NO;
            annotationView.draggable = YES;
            annotationView.calloutOffset = CGPointMake(0, -5);
        }
        
        if (annotationType == 0) {
            annotationView.image = [UIImage imageNamed:@"icon_running_start"];

        }else {
            annotationView.image = [UIImage imageNamed:@"icon_running_end"];
        }
        
        return annotationView;
    }
    
    return nil;
}

- (UIColor *)getColorForSpeed:(double)speed
{
    speed = 0.2f;
    const float lowSpeedTh = 0.005f;
    const float highSpeedTh = 0.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    
    float hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
    
    polylineRenderer.lineWidth = 9;
    if (self.isShowColor) {
        polylineRenderer.strokeColor = self.lineColor;
    }else {
        polylineRenderer.strokeColor = [UIColor clearColor];
        self.isShowColor = YES;
    }
    //polylineRenderer.gradient = YES;
    
    return polylineRenderer;
}

#pragma mark - CLLocationManagerDelegate
/**
 *  当前定位授权状态发生改变时调用
 *
 *  @param manager 位置管理者
 *  @param status  授权的状态
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            NSLog(@"用户还未进行授权");
            break;
        }
        case kCLAuthorizationStatusDenied:{
            // 判断当前设备是否支持定位和定位服务是否开启
            if([CLLocationManager locationServicesEnabled]){
                
                NSLog(@"用户不允许程序访问位置信息或者手动关闭了位置信息的访问");
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL: url];
                }
            }else{
                NSLog(@"定位服务关闭,弹出系统的提示框,点击设置可以跳转到定位服务界面进行定位服务的开启");
            }
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            NSLog(@"受限制的");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            NSLog(@"授权允许在前台和后台均可使用定位服务");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            NSLog(@"授权允许在前台可使用定位服务");
            break;
        }
            
        default:
            break;
    }
}
/**
 我们并没有把从 CLLocationManager 取出来的经纬度放到 mapView 上显示
 原因:
 我们在此方法中取到的经纬度依据的标准是地球坐标,但是国内的地图显示按照的标准是火星坐标
 MKMapView 不用在做任何的处理,是因为 MKMapView 是已经经过处理的
 也就导致此方法中获取的坐标在 mapView 上显示是有偏差的
 解决的办法有很多种,可以上网就行查询,这里就不再多做赘述
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 设备的当前位置
    CLLocation *currLocation = [locations lastObject];
    
    NSString *latitude = [NSString stringWithFormat:@"纬度:%3.5f",currLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"经度:%3.5f",currLocation.coordinate.longitude];
    NSString *altitude = [NSString stringWithFormat:@"高度值:%3.5f",currLocation.altitude];
    
    NSLog(@"位置发生改变:纬度:%@,经度:%@,高度:%@",latitude,longitude,altitude);
    
    [manager stopUpdatingLocation];
}

//定位失败的回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"无法获取当前位置 error : %@",error.localizedDescription);
}

#pragma mark - 距离测算
- (double)calculateDistanceWithStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end {
    
    double meter = 0;
    
    double startLongitude = start.longitude;
    double startLatitude = start.latitude;
    double endLongitude = end.longitude;
    double endLatitude = end.latitude;
    
    double radLatitude1 = startLatitude * M_PI / 180.0;
    double radLatitude2 = endLatitude * M_PI / 180.0;
    double a = fabs(radLatitude1 - radLatitude2);
    double b = fabs(startLongitude * M_PI / 180.0 - endLongitude * M_PI / 180.0);
    
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLatitude1) * cos(radLatitude2) * pow(sin(b/2),2)));
    s = s * 6378137;
    
    meter = round(s * 10000) / 10000;
    return meter;
}

#pragma mark - YJ_CountdownViewDelegate
- (void)countdownFinish {
    //倒计时结束开始定位
    [self.locationManager startUpdatingLocation];
}

#pragma mark - 计时器
//开始
- (void)startRun {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.count = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(repeatShowTime:) userInfo:@"admin" repeats:YES];
    _mapView.delegate = self;
}

//停止
- (void)stopRun {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    //self.count = 0;
}

//暂停
- (void)pauseRun {
    [self.timer setFireDate:[NSDate distantFuture]];
}

//继续
- (void)continueRun {
    [self.timer setFireDate:[NSDate date]];
}

- (void)repeatShowTime:(NSTimer *)tempTimer {
    self.count++;
    // 将秒转换成“00:00:00”的格式来显示
    NSInteger secPerHour = 60 * 60;
    NSInteger hour = self.count / secPerHour;
    NSInteger min = (self.count % secPerHour) / 60;
    NSInteger sec = (self.count % secPerHour) % 60;
    
    NSString *hourStr = (hour >= 10) ? [NSString stringWithFormat:@"%@", @(hour)] : [NSString stringWithFormat:@"0%@", @(hour)];
    NSString *minStr = (min >= 10) ? [NSString stringWithFormat:@"%@", @(min)] : [NSString stringWithFormat:@"0%@", @(min)];
    NSString *secStr = (sec >= 10) ? [NSString stringWithFormat:@"%@", @(sec)] : [NSString stringWithFormat:@"0%@", @(sec)];
    
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@:%@", hourStr, minStr, secStr];
    
    self.labTime.text = timeStr;
    
}

//销毁NSTimer
- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.navigationController popViewControllerAnimated:YES];
//}

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
