//
//  YJ_APIManager.m
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_APIManager.h"
#import "BANetManager.h"
#import "YJ_Constants.h"
#import "YJ_UserProfile.h"
#import "YJ_BaseViewController.h"

@interface YJ_APIManager()

@property (nonatomic, copy) NSString *profilePath;

@end
@implementation YJ_APIManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static YJ_APIManager *apiManager;
    dispatch_once(&onceToken, ^{
        apiManager = [[YJ_APIManager alloc] init];
    });
    
    return apiManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _profilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"profile.plist"];
    }
    
    return self;
}

- (BOOL)isFirstLanuch
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return ![version isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kFirstLanuch]];
}

- (void)saveFirstLanuch
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kFirstLanuch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveLoggedUser:(NSString *)userName password:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kKeyChainAccountName];
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kKeyChainAccountPassword];
}

- (void)saveLoggedInStatus
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoginStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)retrieveLoggedUser
{
    return @{@"userName":[[NSUserDefaults standardUserDefaults] objectForKey:kKeyChainAccountName],
             @"password":[[NSUserDefaults standardUserDefaults] objectForKey:kKeyChainAccountPassword]};
}

- (BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoginStatus];
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginStatus];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyChainAccountName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyChainAccountPassword];
    [self removeProfile];
}

-(void)removeProfile
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:self.profilePath];
    [dictionary setObject:@"0" forKey:@"uid"];
    [dictionary setObject:@"" forKey:@"userType"];
    [self saveProfile:dictionary];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.profilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.profilePath error:nil];
    }
}

- (void)saveProfile:(NSDictionary *)dictionary
{
    NSMutableDictionary *profile = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.profilePath]) {
        profile = [NSMutableDictionary dictionaryWithContentsOfFile:self.profilePath];
    } else {
        profile = [NSMutableDictionary dictionary];
    }
    
    profile = [dictionary mutableCopy];
    
    if ([profile writeToFile:self.profilePath atomically:YES]) {
        NSLog(@"write user profile successfully");
    } else {
        NSLog(@"write user profile failure");
    }
}

- (NSDictionary *)readProfileDictionary
{
    return [NSDictionary dictionaryWithContentsOfFile:self.profilePath];
}

- (YJ_UserProfile *)readProfile
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.profilePath]) {
        NSLog(@"已经移除了文件");
    }else
    {
        NSLog(@"未移除文件");
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:self.profilePath];
    NSLog(@"read profile :%@", dictionary);
    return [[YJ_UserProfile alloc] initWithDictionary:dictionary];
}

-(void)changeRootVCToLogin
{
    //TODO: 进入Login View Controller
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Tabbar" bundle:[NSBundle mainBundle]];
    [UIApplication sharedApplication].delegate.window.rootViewController = mainSB.instantiateInitialViewController;
}

#pragma mark - Post Method
-(void)postParameters:(NSDictionary *)parameters
              withURL:(NSString *)urlString
     withSuccessBlock:(YJ_ResponseSuccess)successBlock
     withFailureBlock:(YJ_ResponseFail)failureBlock
         withProgress:(YJ_DownloadProgress)progress
{
    [BANetManager ba_requestWithType:BAHttpRequestTypePost
                       withUrlString:[NSString stringWithFormat:@"%@%@", kBaseRequestURL, urlString]
                      withParameters:parameters
                    withSuccessBlock:^(id response) {
                        successBlock(response);
                    } withFailureBlock:^(NSError *error) {
                        //error 403退出
                        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
                            YJ_BaseViewController *base = [YJ_BaseViewController new];
                            [base showStatusWithError:[base returnCurrentMessageWithErrorCode:403]];
                            [self logout];
                            [self changeRootVCToLogin];
                            
                            return;
                        }
                        failureBlock(error);
                    } progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        progress(bytesProgress, totalBytesProgress);
                    }];
}

#pragma mark - GET Method
-(void)getParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress
{
    [BANetManager ba_requestWithType:BAHttpRequestTypeGet
                       withUrlString:[NSString stringWithFormat:@"%@%@", kBaseRequestURL, urlString]
                      withParameters:parameters
                    withSuccessBlock:^(id response) {
                        successBlock(response);
                    } withFailureBlock:^(NSError *error) {
                        //error 403退出
                        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
                            YJ_BaseViewController *base = [YJ_BaseViewController new];
                            [base showStatusWithError:[base returnCurrentMessageWithErrorCode:403]];
                            [self logout];
                            [self changeRootVCToLogin];
                            
                            return;
                        }
                        failureBlock(error);
                    } progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        progress(bytesProgress, totalBytesProgress);
                    }];
}

-(void)getWeatherParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress
{
    [BANetManager ba_requestWithType:BAHttpRequestTypeGet
                       withUrlString:[NSString stringWithFormat:@"%@%@", kBaseWeatherRequestURL, urlString]
                      withParameters:parameters
                    withSuccessBlock:^(id response) {
                        successBlock(response);
                    } withFailureBlock:^(NSError *error) {
                        //error 403退出
                        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
                            YJ_BaseViewController *base = [YJ_BaseViewController new];
                            [base showStatusWithError:[base returnCurrentMessageWithErrorCode:403]];
                            [self logout];
                            [self changeRootVCToLogin];
                            
                            return;
                        }
                        failureBlock(error);
                    } progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        progress(bytesProgress, totalBytesProgress);
                    }];
}

#pragma mark - Delete Method
-(void)deleteParameters:(NSDictionary *)parameters
                withURL:(NSString *)urlString
       withSuccessBlock:(YJ_ResponseSuccess)successBlock
       withFailureBlock:(YJ_ResponseFail)failureBlock
           withProgress:(YJ_DownloadProgress)progress
{
    [BANetManager ba_requestWithType:BAHttpRequestTypeDelete
                       withUrlString:[NSString stringWithFormat:@"%@%@", kBaseRequestURL, urlString]
                      withParameters:parameters
                    withSuccessBlock:^(id response) {
                        successBlock(response);
                    } withFailureBlock:^(NSError *error) {
                        //error 403退出
                        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
                            YJ_BaseViewController *base = [YJ_BaseViewController new];
                            [base showStatusWithError:[base returnCurrentMessageWithErrorCode:403]];
                            [self logout];
                            [self changeRootVCToLogin];

                            return;
                        }
                        failureBlock(error);
                    } progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        progress(bytesProgress, totalBytesProgress);
                    }];
}

#pragma mark - Put Method
-(void)putParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress
{
    [BANetManager ba_requestWithType:BAHttpRequestTypePut
                       withUrlString:[NSString stringWithFormat:@"%@%@", kBaseRequestURL, urlString]
                      withParameters:parameters
                    withSuccessBlock:^(id response) {
                        successBlock(response);
                    } withFailureBlock:^(NSError *error) {
                        //error 403退出
                        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: forbidden (403)"]) {
                            YJ_BaseViewController *base = [YJ_BaseViewController new];
                            [base showStatusWithError:[base returnCurrentMessageWithErrorCode:403]];
                            [self logout];
                            [self changeRootVCToLogin];
                            
                            return;
                        }
                        failureBlock(error);
                    } progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        progress(bytesProgress, totalBytesProgress);
                    }];
}

#pragma mark - 文件下载
-(YJ_URLSessionTask *)downloadFileWithURL:(NSString *)urlString
                             withSavaPath:(NSString *)savePath
                         withSuccessBlock:(YJ_ResponseSuccess)successBlock
                         withFailureBlock:(YJ_ResponseFail)failureBlock
                     withDownLoadProgress:(YJ_DownloadProgress)progress
{
    YJ_URLSessionTask *sessionTask = nil;
    sessionTask = [BANetManager ba_downLoadFileWithUrlString:[NSString stringWithFormat:@"%@", urlString]
                                                  parameters:nil
                                                withSavaPath:savePath
                                            withSuccessBlock:^(id response) {
                                                NSLog(@"下载完成，路径为：%@", response);
                                                successBlock(response);
                                            } withFailureBlock:^(NSError *error) {
                                                failureBlock(error);
                                            } withDownLoadProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                                                progress(bytesProgress, totalBytesProgress);
                                                /*! 封装方法里已经回到主线程，所有这里不用再调主线程了 */
                                                
                                                //        self.downloadLabel.text = [NSString stringWithFormat:@"下载进度：%.2lld%%",100 * bytesProgress/totalBytesProgress];
                                                //        [downloadBtn setTitle:@"下载中..." forState:UIControlStateNormal];
                                            }];
    /*! 开始启动任务 */
    [sessionTask resume];
    return sessionTask;
}

@end
