//
//  YJ_InputAlertView.m
//  YueJian
//
//  Created by LG on 2018/5/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RunningAlertView.h"

#define TopWindow [UIApplication sharedApplication].keyWindow

@interface YJ_RunningAlertView ()
@property (nonatomic, strong) UILabel *labDistanceTitle;
@property (nonatomic, strong) UILabel *labDistance;
@property (nonatomic, strong) UILabel *labTimeTitle;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UILabel *labSpeedTitle;
@property (nonatomic, strong) UILabel *labSpeed;
@property (nonatomic, strong) UILabel *labPaceTitle;
@property (nonatomic, strong) UILabel *labPace;
@property (nonatomic, strong) UILabel *labKaTitle;
@property (nonatomic, strong) UILabel *labKa;

@property (nonatomic, strong) UILabel *labUnit;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIButton *btnConfirm;
@property (nonatomic, weak) UIView *becloudView;
@end

@implementation YJ_RunningAlertView

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_running_alertView"]];
        [self addSubview:alertImageView];
        
        [alertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.bottom.offset(0);
        }];
        
        UIImageView *distanceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_runningAlert_distance"]];
        [self addSubview:distanceImageView];
        
        [distanceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(30);
            make.top.offset(70);
            make.width.offset(20);
            make.height.offset(20);
        }];
        
        //距离标题
        self.labDistanceTitle = [[UILabel alloc] init];
        self.labDistanceTitle.textAlignment = NSTextAlignmentLeft;
        self.labDistanceTitle.textColor = ButtonTitleNormal;
        self.labDistanceTitle.text = @"总距离（公里）";
        self.labDistanceTitle.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.labDistanceTitle];
        
        [self.labDistanceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(distanceImageView.mas_right).offset(10);
            make.top.offset(70);
            make.width.offset(200);
            make.height.offset(20);
        }];
        
        //公里视图
        self.labDistance = [[UILabel alloc] init];
        self.labDistance.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        self.labDistance.textColor = [UIColor whiteColor];
        self.labDistance.text = @"00.00";
        self.labDistance.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.labDistance];
        
        [self.labDistance mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labDistanceTitle.mas_bottom).offset(20);
            make.width.offset(200);
            make.height.offset(40);
        }];
        
        UIImageView *timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_runningAlert_time"]];
        [self addSubview:timeImageView];
        
        [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(30);
            make.top.equalTo(self.labDistance.mas_bottom).offset(10);
            make.width.offset(20);
            make.height.offset(20);
        }];
        
        //时间标题
        self.labTimeTitle = [[UILabel alloc] init];
        self.labTimeTitle.textAlignment = NSTextAlignmentLeft;
        self.labTimeTitle.textColor = ButtonTitleNormal;
        self.labTimeTitle.text = @"总时长";
        self.labTimeTitle.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.labTimeTitle];
        
        [self.labTimeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(timeImageView.mas_right).offset(10);
            make.top.equalTo(self.labDistance.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(20);
        }];
        
        //时间视图
        self.labTime = [[UILabel alloc] init];
        self.labTime.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        self.labTime.textColor = [UIColor whiteColor];
        self.labTime.text = @"00.00";
        self.labTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.labTime];
        
        [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labTimeTitle.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(40);
        }];
        
        UIImageView *speedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_runningAlert_speend"]];
        [self addSubview:speedImageView];
        
        [speedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(30);
            make.top.equalTo(self.labTime.mas_bottom).offset(10);
            make.width.offset(20);
            make.height.offset(20);
        }];
        
        //速度标题
        self.labSpeedTitle = [[UILabel alloc] init];
        self.labSpeedTitle.textAlignment = NSTextAlignmentLeft;
        self.labSpeedTitle.textColor = ButtonTitleNormal;
        self.labSpeedTitle.text = @"平均时速（公里/小时）";
        self.labSpeedTitle.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.labSpeedTitle];
        
        [self.labSpeedTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(speedImageView.mas_right).offset(10);
            make.top.equalTo(self.labTime.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(20);
        }];
        
        //速度视图
        self.labSpeed = [[UILabel alloc] init];
        self.labSpeed.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        self.labSpeed.textColor = [UIColor whiteColor];
        self.labSpeed.text = @"00.00";
        self.labSpeed.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.labSpeed];
        
        [self.labSpeed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labSpeedTitle.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(40);
        }];
        
        UIImageView *kaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_runningAlert_ka"]];
        [self addSubview:kaImageView];
        
        [kaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(30);
            make.top.equalTo(self.labSpeed.mas_bottom).offset(10);
            make.width.offset(20);
            make.height.offset(20);
        }];
        
        //热量标题
        self.labKaTitle = [[UILabel alloc] init];
        self.labKaTitle.textAlignment = NSTextAlignmentLeft;
        self.labKaTitle.textColor = ButtonTitleNormal;
        self.labKaTitle.text = @"热量（卡）";
        self.labKaTitle.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.labKaTitle];
        
        [self.labKaTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(kaImageView.mas_right).offset(10);
            make.top.equalTo(self.labSpeed.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(20);
        }];
        
        //热量视图
        self.labKa = [[UILabel alloc] init];
        self.labKa.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        self.labKa.textColor = [UIColor whiteColor];
        self.labKa.text = @"00.00";
        self.labKa.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.labKa];
        
        [self.labKa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labKaTitle.mas_bottom).offset(10);
            make.width.offset(200);
            make.height.offset(40);
        }];
        
        //保存
        self.btnConfirm = [[UIButton alloc] init];
        [self.btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        [self.btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateHighlighted];
        self.btnConfirm.layer.cornerRadius = 20;
        self.btnConfirm.backgroundColor = ThemeColor;
        self.btnConfirm.layer.opacity = 1;
        [self addSubview:self.btnConfirm];
        
        //设置控件圆角
        [self setCornerRadius:self];
        //[self setBtnDisabled];
        
        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.labKa.mas_bottom).offset(30);
            make.width.offset(140);
            make.height.offset(40);
        }];
        
        [[self.btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
            [self.view endEditing:YES];
            [self dismiss];
            self.callback();
        }];
        
    }
    return self;
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
- (void)showAlertDistance:(NSString *)distance withTime:(NSString *)time withSpeed:(NSString *)speed withKa:(NSString *)ka {
    self.labDistance.text = distance;
    self.labTime.text = time;
    self.labSpeed.text = speed;
    self.labKa.text = ka;
    
    //蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.5;
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
    self.frame = CGRectMake(0, 0, becloudView.frame.size.width * 0.8, 500);
    self.backgroundColor = [UIColor whiteColor];
    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.5);
    [TopWindow addSubview:self];
    
    //图片
    self.view = [[UIView alloc] init];
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 35;
    self.view.backgroundColor = [UIColor clearColor];
    [TopWindow addSubview:self.view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 35;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(self.mas_top).offset(35);
        make.height.width.offset(70);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.height.width.offset(70);
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
