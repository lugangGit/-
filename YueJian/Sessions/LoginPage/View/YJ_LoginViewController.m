//
//  YueJian
//
//  Created by Garry on 2018/4/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_LoginViewController.h"
#import "YJ_LoginViewModel.h"
#import "YJ_ForgetPasswordViewController.h"
#import "YJ_RegisterViewController.h"

@interface YJ_LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) YJ_LoginViewModel *viewModel;

@end

@implementation YJ_LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.viewModel = [[YJ_LoginViewModel alloc] init];
    [self drawUI];
    [self clickBack];
}

- (void)viewWillAppear:(BOOL)animated {
    BOOL registered = [[NSUserDefaults standardUserDefaults] boolForKey:KPopView];
    if (registered) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KPopView];
        self.callback();
    }
}

- (void)drawUI {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_login_bgs"]];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.right.offset(0);
    }];
    
    UIView *userView = [[UIView alloc] init];
    userView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:userView];
    
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_login_user"]];
    [userView addSubview:userImageView];
    
    //输入框
    UITextField *tfUserName = [[UITextField alloc] init];
    tfUserName.textAlignment = NSTextAlignmentLeft;
    tfUserName.placeholder = NSLocalizedString(@"Username",nil);
    //通过KVC修改占位文字的颜色
    [tfUserName setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    tfUserName.font = [UIFont systemFontOfSize:23];
    tfUserName.textColor = ThemeColor;
    tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    tfUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    [userView addSubview:tfUserName];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ThemeColor;
    [userView addSubview:lineView];
    
    //密码
    UIView *passwordView = [[UIView alloc] init];
    passwordView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordView];
    
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_login_password"]];
    [passwordView addSubview:passwordImageView];
    
    //输入框
    UITextField *tfPassword = [[UITextField alloc] init];
    tfPassword.textAlignment = NSTextAlignmentLeft;
    tfPassword.placeholder = NSLocalizedString(@"Password",nil);
    //通过KVC修改占位文字的颜色
    [tfPassword setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    tfPassword.font = [UIFont systemFontOfSize:23];
    tfPassword.textColor = ThemeColor;
    tfPassword.secureTextEntry = YES;
    tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
    tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordView addSubview:tfPassword];
    
    UIView *linePasswordView = [[UIView alloc] init];
    linePasswordView.backgroundColor = ThemeColor;
    [passwordView addSubview:linePasswordView];
    
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(270);
        make.left.offset(50);
        make.right.offset(-50);
        make.height.offset(40);
    }];
    
    [userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.centerY.offset(0);
        make.width.height.offset(30);
    }];
    
    [tfUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.offset(0);
        make.centerY.offset(0);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(28);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfUserName.mas_bottom).offset(0);
        //make.left.offset(40);
        //make.right.offset(-40);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(2);
    }];
    
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userView.mas_bottom).offset(20);
        make.left.offset(50);
        make.right.offset(-50);
        make.height.offset(40);
    }];
    
    [passwordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.centerY.offset(0);
        make.width.height.offset(30);
    }];
    
    [tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.offset(0);
        make.centerY.offset(0);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(28);
    }];
    
    [linePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPassword.mas_bottom).offset(0);
        //make.left.offset(40);
        //make.right.offset(-40);
        make.left.equalTo(passwordImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(2);
    }];
    
    //忘记密码
    UIButton *btnForgotPassword = [[UIButton alloc] init];
    [btnForgotPassword setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    btnForgotPassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnForgotPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnForgotPassword.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:btnForgotPassword];
    
    //添加约束
    [btnForgotPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordView.mas_bottom).offset(15);
        make.left.offset(50);
        make.width.offset(100);
        make.height.offset(15);
    }];
    
    //立即注册
    UIButton *btnRegister = [[UIButton alloc] init];
    [btnRegister setTitle:NSLocalizedString(@"立即注册", nil) forState:UIControlStateNormal];
    btnRegister.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:btnRegister];
    
    //添加约束
    [btnRegister mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordView.mas_bottom).offset(15);
        make.right.offset(-50);
        make.width.offset(60);
        make.height.offset(15);
    }];
    
    // 登录按钮
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
    [btnLogin setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateHighlighted];
    //[btnLogin setBackgroundColor:ThemeColor];
    btnLogin.layer.cornerRadius = 20;
    [self.view addSubview:btnLogin];
    
    //添加约束
    [btnLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordView.mas_bottom).with.offset(50);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    RAC(self.viewModel, userName) = tfUserName.rac_textSignal;
    RAC(self.viewModel, password) = tfPassword.rac_textSignal;
    
    btnLogin.rac_command = self.viewModel.loginCommand;
    
    RAC(btnLogin, backgroundColor) = [RACObserve(btnLogin, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnLogin rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self.view endEditing:YES];
        [SVProgressHUD show];
        [weakSelf.viewModel loginWithSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            //[LYT_SplashViewController changeRootVCToMain];
            weakSelf.callback();
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KIsLogin];
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
    
    [[btnForgotPassword rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        YJ_ForgetPasswordViewController *fpVC = [[YJ_ForgetPasswordViewController alloc] init];
        [self.navigationController pushViewController:fpVC animated:YES];
    }];
    
    [[btnRegister rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        YJ_RegisterViewController *rvc = [[YJ_RegisterViewController alloc] init];
        [self.navigationController pushViewController:rvc animated:YES];
    }];
}


- (void)clickBack {
    //关闭
    UIButton *btnclick = [[UIButton alloc] init];
    [btnclick setTitle:NSLocalizedString(@"< Back", nil) forState:UIControlStateNormal];
    btnclick.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnclick setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnclick.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:btnclick];
    
    //添加约束
    [btnclick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(40);
        make.left.offset(30);
        make.width.offset(50);
        make.height.offset(30);
    }];
    
    [[btnclick rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
