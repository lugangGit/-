//
//  YJ_ForgetPasswordViewController.m
//  YueJian
//
//  Created by Garry on 2018/4/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_ForgetPasswordViewController.h"
#import "YJ_ForgetPasswordViewModel.h"
#import "UIButton+countDown.h"

@interface YJ_ForgetPasswordViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *tfVerificationCode;
@property (nonatomic, strong) YJ_ForgetPasswordViewModel *viewModel;
@property (nonatomic, assign) BOOL isTimeStart;
@end

@implementation YJ_ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:ThemeColor];
    self.viewModel = [[YJ_ForgetPasswordViewModel alloc] init];
    [self drawUI];
    [self clickBack];
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
    //修改占位文字的颜色
    [tfUserName setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    tfUserName.font = [UIFont systemFontOfSize:23];
    tfUserName.textColor = ThemeColor;
    tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    tfUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    [userView addSubview:tfUserName];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ThemeColor;
    [userView addSubview:lineView];
    
    //验证码
    UIView *verificationView = [[UIView alloc] init];
    verificationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:verificationView];
    
    UIImageView *verificationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_login_verify"]];
    [verificationView addSubview:verificationImageView];
    
    self.tfVerificationCode = [[UITextField alloc] init];
    self.tfVerificationCode.textAlignment = NSTextAlignmentLeft;
    self.tfVerificationCode.textColor = ThemeColor;
    self.tfVerificationCode.placeholder = NSLocalizedString(@"Code", nil);
    //通过KVC修改占位文字的颜色
    [self.tfVerificationCode setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    self.tfVerificationCode.font = [UIFont systemFontOfSize:23];
    self.tfVerificationCode.keyboardType = UIKeyboardTypeNumberPad;
    self.tfVerificationCode.delegate = self;
    [self.tfVerificationCode addTarget:self action:@selector(textFieldVerificationEditChanged:) forControlEvents:UIControlEventEditingChanged];
    [verificationView addSubview:self.tfVerificationCode];
    
    UIButton *btnVerification = [[UIButton alloc] init];
    btnVerification.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnVerification setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    btnVerification.titleLabel.font = [UIFont systemFontOfSize:17];
    [verificationView addSubview:btnVerification];
    
    UIView *lineVerificationView = [[UIView alloc] init];
    lineVerificationView.backgroundColor = ThemeColor;
    [verificationView addSubview:lineVerificationView];
    
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
    
    //用户约束
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(240);
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
        make.centerY.offset(0);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(28);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfUserName.mas_bottom).offset(0);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(2);
    }];
    
    //验证码约束
    [verificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userView.mas_bottom).offset(20);
        make.left.offset(50);
        make.right.offset(-50);
        make.height.offset(40);
    }];
    
    [verificationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.centerY.offset(0);
        make.width.height.offset(30);
    }];
    
    [self.tfVerificationCode mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.offset(0);
        make.centerY.offset(0);
        make.left.equalTo(userImageView.mas_right).offset(20);
        make.height.offset(28);
    }];
    
    [btnVerification mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(self.tfVerificationCode.mas_right).offset(5);
        make.right.offset(0);
        make.width.offset(120);
        make.height.offset(25);
    }];
    
    [lineVerificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfVerificationCode.mas_bottom).offset(0);
        make.left.equalTo(verificationImageView.mas_right).offset(20);
        make.right.offset(0);
        make.height.offset(2);
    }];
    
    //密码约束
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationView.mas_bottom).offset(20);
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
    
    // 登录按钮
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:NSLocalizedString(@"找回密码", nil) forState:UIControlStateNormal];
    [btnConfirm setTitle:NSLocalizedString(@"找回密码", nil) forState:UIControlStateHighlighted];
    btnConfirm.layer.cornerRadius = 20;
    [self.view addSubview:btnConfirm];
    
    //添加约束
    [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordView.mas_bottom).with.offset(30);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    RAC(self.viewModel, userName) = tfUserName.rac_textSignal;
    RAC(self.viewModel, verificationCode) = self.tfVerificationCode.rac_textSignal;
    RAC(self.viewModel, password) = tfPassword.rac_textSignal;
    
    btnVerification.rac_command = self.viewModel.verificationCommand;
    btnConfirm.rac_command = self.viewModel.confirmCommand;
    
    RAC(btnVerification, tintColor) = [RACObserve(btnVerification, enabled) map:^id(NSNumber *value) {
        //改变验证码按钮字体颜色
        if (value.boolValue == YES && _isTimeStart == NO) {
            [btnVerification setTitleColor:ThemeColor forState:UIControlStateNormal];
        }
        else if (value.boolValue == NO || _isTimeStart == YES) {
            [btnVerification setTitleColor:ButtonTitleNormal forState:UIControlStateNormal];
        }
        return value.boolValue ? [UIColor redColor] : [UIColor blueColor];
    }];
    
    RAC(btnConfirm, backgroundColor) = [RACObserve(btnConfirm, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
#pragma mark - Button点击事件
    __weak typeof(self) weakSelf = self;
    /**
     1.用户获取验证码
     2.button显示1秒已发验证码
     3.再次显示重新发送
     */
    [[btnVerification rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        //[SVProgressHUD show];
        
        //延迟1秒
        [btnVerification setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [btnVerification startWithTime:60 title:NSLocalizedString(@"重新发送", nil) countDownTitle:@"s" mainColor:ThemeColor countColor:ButtonTitleNormal];
            //倒计时开始 禁止按钮颜色改变
            _isTimeStart = YES;
            //倒计时完成 监听按钮颜色改变
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isTimeStart = NO;
            });
        });
        
        //发送请求 带自定义模版
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:tfUserName.text zone:@"86"  result:^(NSError *error) {
            NSLog(@"%@", tfUserName.text);
            if (!error)
            {
                //请求成功
                [SVProgressHUD dismiss];
                NSLog(@"请求成功");
            }
            else
            {
                NSLog(@"%@", error);
                //error
                [SVProgressHUD dismiss];
                [self showStatusWithError:@"验证码发送失败请重试"];
            }
        }];
    }];
    
    [[btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [SVProgressHUD show];
        //验证验证码
        [SMSSDK commitVerificationCode:self.tfVerificationCode.text phoneNumber:tfUserName.text zone:@"86" result:^(NSError *error) {
            if (!error)
            {
                //验证成功
                NSLog(@"验证成功");
                //发送请求
                [weakSelf.viewModel forgetPasswordWithSuccessBlock:^(id response) {
                    [SVProgressHUD dismiss];
                    [self.navigationController popViewControllerAnimated:YES];
                } WithFailureBlock:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
                }];
            }
            else
            {
                NSLog(@"%@", error);
                //error
                [SVProgressHUD dismiss];
                [self showStatusWithError:@"验证码错误"];
            }
        }];
        
    }];
}

- (void)clickBack
{
    //关闭
    UIButton *btnclick = [[UIButton alloc] init];
    [btnclick setTitle:NSLocalizedString(@"< 登录", nil) forState:UIControlStateNormal];
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
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //self.callback();
    //使用callback返回上一级页面，不直接使用dismiss防止上一控制器不存在的情况
    //[self dismissViewControllerAnimated:YES completion:nil];
}

//验证码限制字符
- (void)textFieldVerificationEditChanged:(UITextField*)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = self.textInputMode.primaryLanguage;
    //简体中文输入，包括简体拼音，五笔，手写
    if ([lang isEqualToString:@"zh-Hans"])
    {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        if (!selectedRange) {
            if (toBeString.length > 6) {
                textField.text = [toBeString substringToIndex:6];
            }
        }
    }
    //中文以外输入法，直接统计
    else {
        if (toBeString.length > 6) {
            textField.text = [toBeString substringToIndex:6];
        }
    }
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
