//
//  YJ_RunningRecordViewController.m
//  YueJian
//
//  Created by Garry on 2018/7/25.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RunningRecordViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface YJ_RunningRecordViewController ()<MAMapViewDelegate>
{
    NSMutableArray * _speedColors;
    CLLocationCoordinate2D * _runningCoords;
    NSUInteger _count;
    MAMultiPolyline * _polyline;
    int annotationType;
}

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation YJ_RunningRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏
    [self setNavigation];
    
    //绘制视图
    [self drawUI];
    
    [self initData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlay:_polyline];
    
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.mapView setVisibleMapRect:_polyline.boundingMapRect edgePadding:inset animated:NO];
}

- (void)dealloc
{
    if (_runningCoords)
    {
        free(_runningCoords);
        _count = 0;
    }
}

#pragma mark - init data
- (UIColor *)getColorForSpeed:(float)speed
{
    const float lowSpeedTh = 2.f;
    const float highSpeedTh = 3.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    
    float hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}

- (void)initData
{
    _speedColors = [NSMutableArray array];
    _count = self.locationMutableArray.count;
    NSMutableArray * indexes = [NSMutableArray array];
    _runningCoords = (CLLocationCoordinate2D *)malloc(_count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < _count; i++)
    {
        //从位置数组中取出最新的位置数据
        NSString *locationStr = _locationMutableArray[i];
        NSArray *temp = [locationStr componentsSeparatedByString:@","];
        NSString *latitudeStr = temp[0];
        
        NSArray *atitudeTemp = [latitudeStr componentsSeparatedByString:@"."];
        NSString *latitudeTh = atitudeTemp[0];
        NSString *longitudeTh = atitudeTemp[1];
  
        NSString *longitudeStr = temp[1];
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake([latitudeStr doubleValue], [longitudeStr doubleValue]);
        
        if (i == 0) {
            [self addAnnotationWithCooordinate:startCoordinate];
        }else if (i == _count - 1) {
            [self addAnnotationWithCooordinate:startCoordinate];
        }
        
        _runningCoords[i].latitude = [latitudeStr doubleValue];
        _runningCoords[i].longitude = [longitudeStr doubleValue];
        UIColor * speedColor;
        if (longitudeTh.length == 8) {
            NSLog(@"atitudeArray:%@",longitudeTh);
            speedColor = [UIColor clearColor];
        }else {
            speedColor = [self getColorForSpeed:2];
        }
        [_speedColors addObject:speedColor];
        
        //开始绘制轨迹
//        CLLocationCoordinate2D pointsToUse[2];
//        pointsToUse[0] = startCoordinate;
//        pointsToUse[1] = endCoordinate;
//        MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:2];
//        [_mapView addOverlay:lineOne];
        [indexes addObject:@(i)];
        
    }

    _polyline = [MAMultiPolyline polylineWithCoordinates:_runningCoords count:_count drawStyleIndexes:indexes];

}

#pragma mark - mapview delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == _polyline)
    {
        //MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = _speedColors;
        //polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}


#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - 绘制UI
- (void)drawUI {
    NSLog(@"locationMutableArray：%@", self.locationMutableArray);
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    _mapView.showsCompass = NO;
    [self.view addSubview:self.mapView];
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
            annotationType = 1;
        }else {
            annotationView.image = [UIImage imageNamed:@"icon_running_end"];
        }
        
        return annotationView;
    }
    
    return nil;
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
