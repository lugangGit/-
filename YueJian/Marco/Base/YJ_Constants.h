//
//  YJ_Constants.h
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

//主题颜色
#define ThemeColor          [UIColor jk_colorWithHexString:@"11d6d5"] //#00ffe4 11d6d5

#define SubThemeColor       [UIColor colorWithRed:28/255.0 green:203/255.0 blue:174/255.0 alpha:1];
//不可交互按钮背景色
#define ButtonTitleNormal   [UIColor jk_colorWithHexString:@"D2D2D2"]
//tableview背景色
#define TableViewBGColor    [UIColor whiteColor]
//默认背景色
#define BGColor             [UIColor jk_colorWithHexString:@"F2F2F2"] //eeeeee
//按钮置灰
#define ButtonDisableColor  [UIColor jk_colorWithHexString:@"CCCCCC"]

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height

#define SubColor            [UIColor jk_colorWithHexString:@"70bbb6"]

#define RGBA(r,g,b,a)       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
//头像边框
#define AvatarCycleCGColor  [UIColor jk_colorWithWholeRed:255.0 green:255.0 blue:255.0 alpha:0.3].CGColor

//正文字体主标题
#define MainTextColor           [UIColor jk_colorWithHexString:@"323232"]

//#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//#define ScreenHeight [UIScreen mainScreen].bounds.size.height
// 适配宏
#define HeightRealValue(value)  ((value/1334.0)*ScreenHeight)
#define WidthRealValue(value)   ((value/750.0)*ScreenWidth)
#define SINGLE_LINE_WIDTH       (1 / [UIScreen mainScreen].scale)

@interface YJ_Constants : NSObject

//Constants

extern CGFloat const kButtonCornerRadius;

#pragma mark - Weather
extern NSString *const kWeatherAPIKey;

#pragma mark - Map
extern NSString *const kAMapAPIKey;
extern NSInteger const kAMapZoomLevel;

#pragma mark - 移动数据分析
extern NSString *const kAliyunAPIKey;
extern NSString *const kAliyunAPISecretKey;

#pragma mark - Other
extern NSString *const kFirstLanuch;
extern NSString *const kLoginStatus;
extern NSString *const kToken;
extern NSString *const kKeyChainAccountName;
extern NSString *const kKeyChainAccountPassword;
extern NSString *const KPopView;
extern NSString *const KIsLogin;

#pragma mark - API URL
extern NSString *const kBaseRequestURL;
extern NSString *const kBaseWeatherRequestURL;

#pragma mark - Home
extern NSString *const kHomeWeatherURL;
extern NSString *const kHomeGetBodyURL;
extern NSString *const kHomePostBodyURL;
extern NSString *const kHomeGetTargetURL;
extern NSString *const kHomePostTargetURL;
extern NSString *const kHomeGetSignURL;
extern NSString *const kHomePostSignURL;
extern NSString *const kHomePostDynameicURL;
extern NSString *const kHomeGetDynameicURL;
extern NSString *const kHomeDeleteDynameicURL;

#pragma mark - UserManager
extern NSString *const kLoginURL;
extern NSString *const kLogoutURL;
extern NSString *const kForgotPasswordURL;
extern NSString *const kRegisterURL;
extern NSString *const kRegisterUserInfoURL;
extern NSString *const kRegisterPlanURL;
extern NSString *const kChangeAvatarURL;
extern NSString *const kChangeNicknameURL;
extern NSString *const kChangeSexURL;
extern NSString *const kChangeBirthURL;
extern NSString *const kFeedbackURL;

#pragma mark - Plan
extern NSString *const kPlanGetEditURL;
extern NSString *const kPlanPostEditURL;
extern NSString *const kPlanGetAddURL;
extern NSString *const kPlanPostAddURL;
extern NSString *const kPlanDeleteAddURL;


@end
