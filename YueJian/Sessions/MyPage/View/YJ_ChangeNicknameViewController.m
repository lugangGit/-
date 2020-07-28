//
//  YJ_ChangeNicknameViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/3.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_ChangeNicknameViewController.h"
#import "YJ_MyInfoViewModel.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"

#define MAX_NAMEWORDS_LENGTH    15

@interface YJ_ChangeNicknameViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfNickname;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UIButton *btnFooter;
@property (nonatomic, strong) YJ_MyInfoViewModel *viewModel;
@property (nonatomic, strong) YJ_UserProfile *userProfile;

@end

@implementation YJ_ChangeNicknameViewController

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
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"修改昵称", nil);
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
    self.btnFooter.rac_command = self.viewModel.NicknameConfirmCommand;
    RAC(_btnFooter, backgroundColor) = [RACObserve(_btnFooter, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor :ButtonTitleNormal;
    }];
    
    //给按钮添加点击事件响应
    __weak typeof(self) weakSelf = self;
    [[weakSelf.btnFooter rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [SVProgressHUD show];
        [weakSelf.viewModel submitChangeWithNickname:weakSelf.tfNickname.text withSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            weakSelf.callback();
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
    
    self.tfNickname = [[UITextField alloc]init];
    self.tfNickname.textColor = [UIColor blackColor];
    self.tfNickname.font = [UIFont systemFontOfSize:14.0];
    self.tfNickname.textAlignment = NSTextAlignmentLeft;
    self.tfNickname.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.tfNickname becomeFirstResponder];
    self.tfNickname.delegate = self;
    [self.tfNickname addTarget:self action:@selector(textFieldNickEditChanged:) forControlEvents:UIControlEventEditingChanged];
    if (![[YJ_APIManager sharedInstance] isLoggedIn]) {
        self.tfNickname.placeholder = NSLocalizedString(@"昵称在15字以内...", nil);
    }else
    {
        if ([self.userProfile.nickName isEqualToString:@""]) {
            self.tfNickname.placeholder = NSLocalizedString(@"昵称在15字以内...", nil);
        }else {
            self.tfNickname.text = self.userProfile.nickName;
        }
    }
    [cell addSubview:self.tfNickname];
    
    [self.tfNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(30);
        make.centerY.offset(0);
        make.right.offset(-10);
        make.height.offset(20);
    }];
    
#pragma mark - 设置观察者
    //检测文本框内容变化
    RAC(self.viewModel, nickname) = self.tfNickname.rac_textSignal;
    
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

#pragma mark - UITextFieldNotifiaction
//限制输入字数
- (void)textFieldNickEditChanged:(UITextField*)textField
{
    NSString *toBeString = self.tfNickname.text;
    NSString *lang = self.textInputMode.primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"])//简体中文输入，包括简体拼音，五笔，手写
    {
        UITextRange *selectedRange = [self.tfNickname markedTextRange];
        //获取高亮部分
        if (!selectedRange) {
            if (toBeString.length > MAX_NAMEWORDS_LENGTH) {
                textField.text = [toBeString substringToIndex:MAX_NAMEWORDS_LENGTH];
            }
        }
        //有高亮字符串暂不限制
        else
        {
        }
    }
    //中文以外输入法，直接统计
    else
    {
        if (toBeString.length > MAX_NAMEWORDS_LENGTH)
        {
            textField.text = [toBeString substringToIndex:MAX_NAMEWORDS_LENGTH];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1 && string.length == 0) {
        return YES;
    }
    else if (textField == self.tfNickname) {
        if (self.tfNickname.text.length >= MAX_NAMEWORDS_LENGTH) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//处理手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
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
