//
//  YJ_ChangeBirthViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/3.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_ChangeBirthViewController.h"
#import "YJ_MyInfoViewModel.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"

@interface YJ_ChangeBirthViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *tfBirth;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UIButton *btnFooter;
@property (nonatomic, strong) YJ_MyInfoViewModel *viewModel;
@property (nonatomic, strong) YJ_UserProfile *userProfile;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL isFirstChoose;

@end

@implementation YJ_ChangeBirthViewController


#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGColor;
    
    //viewModel初始化
    self.viewModel = [[YJ_MyInfoViewModel alloc] init];
    
    [self.view addSubview:self.myTableView];
        
    //设置导航栏
    [self setNavigation];
    
    self.userProfile = [[YJ_APIManager sharedInstance] readProfile];
    
    //UIDatePicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minuteInterval = 30;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignActive)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"修改生日", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - setUpView
- (UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -26, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _myTableView.rowHeight = 45.0;
        [_myTableView setDelegate:self];
        [_myTableView setDataSource:self];
        [_myTableView setBackgroundColor:BGColor];
        _myTableView.tableFooterView = [self setUpFooterView];
    }
    return _myTableView;
}

#pragma mark - setUpFooterView
- (UIView *)setUpFooterView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    self.btnFooter = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnFooter.layer.cornerRadius = 20;
    [self.btnFooter setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [self.btnFooter setBackgroundColor:[UIColor jk_colorWithHexString:@"808080"]];
    [bgView addSubview:self.btnFooter];
    
    [self.btnFooter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(12);
        make.height.offset(40);
        make.left.offset(40);
        make.right.offset(-40);
    }];
    
#pragma mark - 设置观察者
    self.btnFooter.rac_command = self.viewModel.BirthConfirmCommand;
    
    RAC(_btnFooter, backgroundColor) = [RACObserve(_btnFooter, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor :ButtonTitleNormal;
    }];
    
    //给按钮添加点击事件响应
    __weak typeof(self) weakSelf = self;
    [[weakSelf.btnFooter rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [SVProgressHUD show];
        [weakSelf.viewModel submitChangeWithBirth:self.tfBirth.text withSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            self.callback();
        } withFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
    
    return bgView;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //注册cell
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.tfBirth = [[UITextField alloc]init];
    self.tfBirth.textColor = [UIColor blackColor];
    self.tfBirth.font = [UIFont systemFontOfSize:14.0];
    self.tfBirth.textAlignment = NSTextAlignmentLeft;
    self.tfBirth.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.tfBirth becomeFirstResponder];
    self.tfBirth.delegate = self;
    if (![[YJ_APIManager sharedInstance] isLoggedIn]) {
        self.tfBirth.placeholder = NSLocalizedString(@"请选择出生日期", nil);
    }else
    {
        if ([self.userProfile.birth isEqualToString:@""]) {
            self.tfBirth.placeholder = NSLocalizedString(@"请选择出生日期", nil);
        }else {
            self.tfBirth.text = self.userProfile.birth;
        }
    }
    [cell addSubview:self.tfBirth];
    
    [self.tfBirth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(30);
        make.centerY.offset(0);
        make.right.offset(-10);
        make.height.offset(20);
    }];
    
#pragma mark - 设置观察者
    //检测文本框内容变化
    RAC(self.viewModel, birth) = self.tfBirth.rac_textSignal;
    
    return cell;
}

#pragma mark - setUpHeightForHeaderAndFooter
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //获取当前时间日期
    if (_isFirstChoose) {
        NSDate *date=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateStr;
        dateStr = [formatter stringFromDate:date];
        NSLog(@"%@",dateStr);
        self.tfBirth.text = dateStr;
        self.viewModel.birth = dateStr;
        _isFirstChoose = NO;
    }
    
    //UIDatePicker以及在当前视图上就不用再显示
    if (self.datePicker.superview == nil) {
        //close all keyboard or data picker visible currently
        [self.view endEditing:YES];
        //此处将Y坐标设在最底下，为了一会动画的展示
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 200);
        [self.view addSubview:self.datePicker];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
        [UIView commitAnimations];
    }
    return NO;
}

#pragma mark - 选择日期
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    self.tfBirth.text = dateString;
    self.viewModel.birth = dateString;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

-(void)resignActive
{
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//处理手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"%@", touch.view);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {
        [self.datePicker removeFromSuperview];
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
