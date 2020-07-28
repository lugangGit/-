//
//  YJ_SignViewController.m
//  YueJian
//
//  Created by LG on 2018/5/18.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_SignViewController.h"
#import "FSCalendar.h"
#import <EventKit/EventKit.h>
#import "YJ_SignViewModel.h"

@interface YJ_SignViewController ()<FSCalendarDataSource,FSCalendarDelegate>
@property (nonatomic, assign) NSInteger SignCount;
@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, strong) FSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, assign) BOOL showsLunar;
@property (nonatomic, assign) BOOL showsEvents;
@property (nonatomic, strong) NSArray<EKEvent *> *events;
//签到列表
@property (nonatomic, strong) NSMutableArray *signInList;
//签到按钮
@property (nonatomic, strong) UIButton *btnSign;
//记录年月(正式使用时,不需要此属性)
@property (nonatomic, strong) NSString *dateStr;
@property (nonatomic, strong) NSString *currentDataString;
@property (nonatomic, strong) YJ_SignViewModel *viewModel;

@end

@implementation YJ_SignViewController
{
    NSInteger _count;
}

#pragma mark - 懒加载
- (NSMutableArray *)signInList{
    if (!_signInList) {
        _signInList = [NSMutableArray array];
    }
    return _signInList;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[YJ_SignViewModel alloc] init];

    //设置导航栏
    [self setNavigation];
    
    //绘制UI
    [self drawUI];
    
    //日历配置
    [self calendarConfig];
    
    //获取网络请求日历数据
    [self getSign];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"目标签到", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 绘制UI
- (void)drawUI {
    //界面背景图
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_sign_background"]];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_offset(0);
        make.left.right.mas_offset(0);
    }];
    
    //创建日历类
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(150);
        make.left.mas_offset(10);
        make.right.mas_offset(-10);
        make.height.offset(300);
    }];
    
    //日历背景
    UIImageView *calendarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_sign_bgCalandar"]];
    [view addSubview:calendarImageView];
    
    [calendarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_offset(0);
        make.left.right.mas_offset(0);
    }];
    
    //创建日历
    self.calendar = [[FSCalendar alloc] init];
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    //日历语言为中文
    self.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    //允许多选,可以选中多个日期
    self.calendar.allowsMultipleSelection = YES;
    //如果值为1,那么周日就在第一列,如果为2,周日就在最后一列
    self.calendar.firstWeekday = 1;
    //周一...或者头部的2017年11月的显示方式
    self.calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
    [view addSubview:self.calendar];
    
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.mas_offset(10);
        make.right.mas_offset(-10);
        make.height.offset(260);
    }];

    //签到按钮
    self.btnSign = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSign setBackgroundColor:ThemeColor];
    [self.btnSign setTitle:NSLocalizedString(@"签到", nil) forState:UIControlStateNormal];
    [self.btnSign setTitle:NSLocalizedString(@"签到", nil) forState:UIControlStateHighlighted];
    //self.btnSign.showsTouchWhenHighlighted = YES;
    self.btnSign.layer.cornerRadius = 20;
    self.btnSign.layer.masksToBounds = YES;
    [self.view addSubview:self.btnSign];
    
    //添加约束
    [self.btnSign mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_bottom).with.offset(30);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    //按钮点击事件
    __weak typeof(self) weakSelf = self;
    [[weakSelf.btnSign rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        //假设在这里网络请求签到成功
        if (_count>31) {
            return;
        }else if (!_count){
            _count = 1;
        }
        
        for (int i = 0; i < self.signInList.count; i++) {
            if ([self.signInList[i] isEqualToString:self.currentDataString]) {
                [self showStatusWithWarnning:@"已签到成功"];
                return;
            }
        }
        //允许用户选择签到日期
        weakSelf.calendar.allowsSelection = YES;
        weakSelf.calendar.allowsMultipleSelection = YES;
        
        [SVProgressHUD show];
        [weakSelf.viewModel handlerPostSignData:weakSelf.currentDataString withSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            [weakSelf.signInList addObject:weakSelf.currentDataString];
            NSDate *date = [weakSelf.dateFormatter dateFromString:weakSelf.currentDataString];
            if (![weakSelf.calendar.selectedDates containsObject:date]) {
                [weakSelf.calendar selectDate:date];
            }
            //禁止用户选择
            weakSelf.calendar.allowsSelection = NO;
        } withFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

#pragma mark - 获取网络签到结果
- (void)getSign{
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [weakSelf.viewModel handlerGetSignDataWithSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        //self.signInList = [NSMutableArray arrayWithArray:@[@"2018-08-01", @"2018-08-02", @"2018-08-03"]];
        self.signInList = [NSMutableArray arrayWithArray:response[@"signDate"]];
        NSLog(@"%@",_signInList);
        //获取签到总数量
        self.SignCount = _signInList.count;
        if (self.SignCount) {
            for (NSString *dateStr in _signInList) {
                NSDate *date = [self.dateFormatter dateFromString:dateStr];
                if (![self.calendar.selectedDates containsObject:date]) {
                    [self.calendar selectDate:date];
                }
            }
        }
        //禁止用户选择
        self.calendar.allowsSelection = NO;
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

//获取日历范围显示日历范围
- (NSArray *)getStartTimeAndFinalTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *datenow = [NSDate date];
    self.currentDataString = [formatter stringFromDate:datenow];
    NSLog(@"%@", self.currentDataString);
    NSDate *newDate=[formatter dateFromString:self.currentDataString];
    double interval = 0;
    NSDate *firstDate = nil;
    NSDate *lastDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    BOOL OK = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:& firstDate interval:&interval forDate:newDate];
    if (OK) {
        lastDate = [firstDate dateByAddingTimeInterval:interval - 1];
    }else {
        return @[@"",@""];
    }
    NSString *firstString = [formatter stringFromDate: firstDate];
    NSString *lastString = [formatter stringFromDate: lastDate];
    //返回数据为日历要显示的最小日期firstString和最大日期lastString
    return @[firstString, lastString];
}

#pragma mark - 配置日历
- (void)calendarConfig{
    //创建系统日历类
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //获取日历要显示的日期范围
    NSArray *timeArray = [self getStartTimeAndFinalTime];
    self.dateStr = [timeArray[0] substringToIndex:7];
    NSLog(@"---%@---", self.dateStr);
    //设置最小和最大日期(在最小和最大日期之外的日期不能被选中,日期范围如果大于一个月,则日历可翻动)
    self.minimumDate = [self.dateFormatter dateFromString:timeArray[0]];
    self.maximumDate = [self.dateFormatter dateFromString:timeArray[1]];
    self.calendar.accessibilityIdentifier = @"calendar";
    //title显示方式
    self.calendar.appearance.headerDateFormat = @"yyyy年MM月";
    //关闭字体自适应,设置字体大小\颜色
    self.calendar.appearance.adjustsFontSizeToFitContentSize = NO;
    self.calendar.appearance.subtitleFont = [UIFont systemFontOfSize:8];
    self.calendar.appearance.headerTitleColor = [UIColor whiteColor];
    self.calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    self.calendar.appearance.selectionColor = [UIColor orangeColor];
    //日历头部颜色
    self.calendar.calendarHeaderView.backgroundColor = ThemeColor;
    self.calendar.calendarWeekdayView.backgroundColor = ThemeColor;
    //载入节假日
    //[self loadCalendarEvents];
    //显示节假日
    //[self eventItemClicked];
    //显示农历
    //[self lunarItemClicked];
}

#pragma mark - Target actions
//显示节日
- (void)eventItemClicked {
    self.showsEvents = !self.showsEvents;
    [self.calendar reloadData];
}

#pragma mark - FSCalendarDataSource
//日期范围(最小)
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return self.minimumDate;
}

//日期范围(最大)
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return self.maximumDate;
}

//数据源方法,根据是否显示节日
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date {
    if (self.showsEvents) {
        EKEvent *event = [self eventsForDate:date].firstObject;
        if (event) {
            return event.title;
        }
    }
    return nil;
}

#pragma mark - FSCalendarDelegate
//手动选中了某个日期(本项目暂时被隐藏)
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSLog(@"did select %@",[self.dateFormatter stringFromDate:date]);
}

//当前页被改变,日历翻动时调用(本项目暂时没用到)
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    NSLog(@"did change page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

//返回节日数量
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    if (!self.showsEvents) return 0;
    if (!self.events) return 0;
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    return events.count;
}

//calendar的events的偏好设置
- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    //如果不允许显示节日
    if (!self.showsEvents) return nil;
    //如果当前日期范围内根本没有节日
    if (!self.events) return nil;
    //根据日期来获取事件数组
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:events.count];
    //遍历事件,设置事件文字颜色
    [events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [colors addObject:[UIColor colorWithCGColor:obj.calendar.CGColor]];
    }];
    return colors.copy;
}

#pragma mark - Private methods
//加载节日到日历中
- (void)loadCalendarEvents
{
    __weak typeof(self) weakSelf = self;
    EKEventStore *store = [[EKEventStore alloc] init];
    //请求访问日历
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        //允许访问
        if(granted) {
            NSDate *startDate = self.minimumDate;
            NSDate *endDate = self.maximumDate;
            NSPredicate *fetchCalendarEvents = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
            NSArray<EKEvent *> *eventList = [store eventsMatchingPredicate:fetchCalendarEvents];
            NSArray<EKEvent *> *events = [eventList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable event, NSDictionary<NSString *,id> * _Nullable bindings) {
                return event.calendar.subscribed;
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf) return;
                weakSelf.events = events;
                [weakSelf.calendar reloadData];
            });
            
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"获取节日事件需要权限" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
}

//根据日期来显示事件
- (NSArray<EKEvent *> *)eventsForDate:(NSDate *)date {
    NSArray<EKEvent *> *events = [self.cache objectForKey:date];
    if ([events isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSArray<EKEvent *> *filteredEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.occurrenceDate isEqualToDate:date];
    }]];
    if (filteredEvents.count) {
        [self.cache setObject:filteredEvents forKey:date];
    } else {
        [self.cache setObject:[NSNull null] forKey:date];
    }
    return filteredEvents;
}

#pragma mark - 返回
- (void)clickBack {
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
