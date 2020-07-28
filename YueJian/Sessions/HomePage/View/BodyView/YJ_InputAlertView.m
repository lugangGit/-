//
//  YJ_InputAlertView.m
//  YueJian
//
//  Created by LG on 2018/5/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_InputAlertView.h"

#define TopWindow [UIApplication sharedApplication].keyWindow

@interface YJ_InputAlertView ()
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labUnit;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIButton *btnConfirm;
@property (nonatomic, weak) UIView *becloudView;
@end

@implementation YJ_InputAlertView

- (instancetype)init {
    self = [super init];
    if (self) {
        //标题
        self.labTitle = [[UILabel alloc] init];
        self.labTitle.textAlignment = NSTextAlignmentCenter;
        self.labTitle.textColor = [UIColor blackColor];
        self.labTitle.text = @"";
        self.labTitle.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.labTitle];
        
        [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.offset(50);
            make.width.offset(50);
            make.height.offset(20);
        }];
        
         //输入框
        self.textField = [[UITextField alloc] init];
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.font = [UIFont systemFontOfSize:28];
        self.textField.textColor = ThemeColor;
        self.textField.keyboardType = UIKeyboardTypeDecimalPad;
        //self.textField.backgroundColor = [UIColor redColor];
        [self addSubview:self.textField];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labTitle.mas_bottom).offset(20);
            make.width.offset(80);
            make.height.offset(30);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = BGColor;
        [self addSubview:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(-20);
            make.top.equalTo(self.textField.mas_bottom).offset(0);
            make.width.offset(100);
            make.height.offset(1);
        }];
        
        //标题
        self.labUnit = [[UILabel alloc] init];
        self.labUnit.textAlignment = NSTextAlignmentCenter;
        self.labUnit.textColor = [UIColor blackColor];
        self.labUnit.text = @"";
        self.labUnit.font = [UIFont systemFontOfSize:16];
        //self.labUnit.backgroundColor = ThemeColor;
        [self addSubview:self.labUnit];
        
        [self.labUnit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.textField.mas_right).offset(0);
            make.top.equalTo(self.labTitle.mas_bottom).offset(20);
            make.width.offset(40);
            make.height.offset(30);
        }];
        
        //保存
        self.btnConfirm = [[UIButton alloc] init];
        [self.btnConfirm setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
        [self.btnConfirm setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateHighlighted];
        self.btnConfirm.layer.cornerRadius = 20;
        [self addSubview:self.btnConfirm];
        
        //设置控件圆角
        [self setCornerRadius:self];
        [self setBtnDisabled];
        
        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(lineView.mas_bottom).offset(20);
            make.width.offset(140);
            make.height.offset(40);
        }];
        
        [[self.btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
            [self.view endEditing:YES];
            [self dismiss];
            self.callback(self.textField.text);
        }];
        
        // 发送键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextViewDidChange) name:UITextFieldTextDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)inputTextViewDidChange
{
    if (self.textField.text.length == 0 || self.textField.text.length > 5) {
        [self setBtnDisabled];
    } else {
        self.btnConfirm.enabled = YES;
        if (self.confirmBgColor) {
            self.btnConfirm.backgroundColor = self.confirmBgColor;
            self.btnConfirm.layer.opacity = 1;
        } else {
            self.btnConfirm.backgroundColor = ThemeColor;
            self.btnConfirm.layer.opacity = 1;
        }
    }
}

//设置无效状态
- (void)setBtnDisabled
{
    self.btnConfirm.enabled = NO;
    self.btnConfirm.backgroundColor = ButtonDisableColor;
    self.btnConfirm.layer.opacity = 1;
}

//设置控件圆角
- (void)setCornerRadius:(UIView *)view {
    if (self.radius) {
        view.layer.cornerRadius = self.radius;
    } else {
        view.layer.cornerRadius = 8.0;
    }
    view.layer.masksToBounds = YES;
}

#pragma mark - 显示视图
- (void)showAlertTitle:(NSString *)title withUnit:(NSString *)unit withImageName:(NSString *)imageName {
    [self.textField becomeFirstResponder];
    self.labUnit.text = unit;
    self.labTitle.text = title;
    //蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.7;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView:)];
    [becloudView addGestureRecognizer:tapGR];
    //是否显示蒙版
    if (_hideBecloud) {
        becloudView.hidden = YES;
    } else {
        becloudView.hidden = NO;
    }
    [TopWindow addSubview:becloudView];
    self.becloudView = becloudView;
    
    //输入框
    self.frame = CGRectMake(0, 0, becloudView.frame.size.width * 0.7, 200);
    self.backgroundColor = [UIColor whiteColor];
    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.4);
    [TopWindow addSubview:self];
    
    //图片
    self.view = [[UIView alloc] init];
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 35;
    self.view.backgroundColor = [UIColor whiteColor];
    [TopWindow addSubview:self.view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:imageView];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(self.mas_top).offset(35);
        make.height.width.offset(70);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.height.width.offset(50);
    }];
}

- (void)closeAlertView:(UIButton *)sender {
    [self dismiss];
}

#pragma mark - 移除
- (void)dismiss {
    [self removeFromSuperview];
    [self.becloudView removeFromSuperview];
    [self.view removeFromSuperview];
}

@end
