//
//  YJ_InputAlertView.h
//  YueJian
//
//  Created by LG on 2018/5/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <UIKit/UIKit.h>
//确认按钮回调的block
typedef void(^confirmCallback)(void);

@interface YJ_RunningAlertView : UIView

//是否显示蒙版，默认显示
@property (nonatomic, assign) BOOL hideBecloud;
//圆角半径
@property (nonatomic, assign) CGFloat radius;
//确认按钮颜色
@property (nonatomic, strong) UIColor *confirmBgColor;
//回调
@property (nonatomic, copy) confirmCallback callback;

//弹出输入框
- (void)showAlertDistance:(NSString *)distance withTime:(NSString *)time withSpeed:(NSString *)speed withKa:(NSString *)ka;

@end
