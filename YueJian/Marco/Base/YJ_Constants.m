//
//  YJ_Constants.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_Constants.h"

@implementation YJ_Constants

CGFloat const kButtonCornerRadius = 15.0;

#pragma mark - Weather
NSString *const kWeatherAPIKey = @"ed5e0c4f2a4043b1b8dcd71bd6b0100f";

#pragma mark - Map
NSString *const kAMapAPIKey = @"9441deb8a52b2d89f40c69e34dfe0d53";
NSInteger const kAMapZoomLevel = 13;

#pragma mark - 移动数据分析
NSString *const kAliyunAPIKey = @"23578436";
NSString *const kAliyunAPISecretKey = @"bb3cef1659d04e9d6e6cd20c59dda7be";

#pragma mark - 移动推送
NSString *const kAliyunPushAPIKey = @"24837529";
NSString *const kAliyunPushAPISecretKey = @"f75094689ca568ba517f988c5d15eaf3";

#pragma mark - Other
NSString *const kFirstLanuch = @"firstLanuch";
NSString *const kLoginStatus = @"loginStatus";
NSString *const kToken = @"token";
NSString *const kKeyChainAccountName = @"Account";
NSString *const kKeyChainAccountPassword = @"Password";
NSString *const KPopView = @"PopViewToLogin";
NSString *const KIsLogin = @"kIsLogin";

#pragma mark - API URL
NSString *const kBaseRequestURL = @"http://39.107.119.146:8091";//http://39.107.119.146:8091  http://192.168.0.184:8091
NSString *const kBaseWeatherRequestURL = @"https://free-api.heweather.com/s6";

#pragma mark - Home
NSString *const kHomeWeatherURL = @"/weather/now?location=%E5%8C%97%E4%BA%AC&key=ed5e0c4f2a4043b1b8dcd71bd6b0100f";
NSString *const kHomeGetTargetURL = @"/api/body/query?userId=";
NSString *const kHomePostTargetURL = @"/api/body/change/targetStep";
NSString *const kHomeGetSignURL = @"/api/signIn/query/list?userId=";
NSString *const kHomePostSignURL = @"/api/signIn/add";
NSString *const kHomeGetBodyURL = @"/api/body/query?userId=";
NSString *const kHomePostBodyURL = @"/api/body/change";
NSString *const kHomePostDynameicURL = @"/api/dynamic/add";
NSString *const kHomeGetDynameicURL = @"/api/dynamic/query/list";
NSString *const kHomeDeleteDynameicURL = @"/api/dynamic/delete?dynamicId=";

#pragma mark - UserManager
NSString *const kLoginURL = @"/api/accounts/login";
NSString *const kLogoutURL = @"/api/accounts/loginout";
NSString *const kForgotPasswordURL = @"/api/accounts/find/password";
NSString *const kRegisterURL = @"/api/accounts/register";
NSString *const kChangeAvatarURL = @"/api/accounts/change/avatar";
NSString *const kChangeNicknameURL = @"/api/accounts/change/nickname";
NSString *const kChangeSexURL = @"/api/accounts/change/sex";
NSString *const kChangeBirthURL = @"/api/accounts/change/birth";
NSString *const kFeedbackURL = @"/api/feedback/add";
NSString *const kRegisterUserInfoURL = @"/api/accounts/edit/userInfo";
NSString *const kRegisterPlanURL = @"/api/accounts/edit/userInfo";

#pragma mark - Plan
NSString *const kPlanGetEditURL = @"/api/motionTarget/query?userId=";
NSString *const kPlanPostEditURL = @"/api/motionTarget/edit";
NSString *const kPlanGetAddURL = @"/api/sportPlan/query?userId=";
NSString *const kPlanPostAddURL = @"/api/sportPlan/edit";
NSString *const kPlanDeleteAddURL = @"/api/sportPlan/delete";


@end
