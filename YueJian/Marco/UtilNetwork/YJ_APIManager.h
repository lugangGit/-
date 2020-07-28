//
//  YJ_APIManager.h
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BANetManager;
@class YJ_UserProfile;

/*! 定义请求成功的block */
typedef void( ^ YJ_ResponseSuccess)(id response);
/*! 定义请求失败的block */
typedef void( ^ YJ_ResponseFail)(NSError *error);

/*! 定义上传进度block */
typedef void( ^ YJ_UploadProgress)(int64_t bytesProgress,
                                    int64_t totalBytesProgress);
/*! 定义下载进度block */
typedef void( ^ YJ_DownloadProgress)(int64_t bytesProgress,
                                      int64_t totalBytesProgress);

/*!
 *  方便管理请求任务。执行取消，暂停，继续等任务.
 *  - (void)cancel，取消任务
 *  - (void)suspend，暂停任务
 *  - (void)resume，继续任务
 */
typedef NSURLSessionTask YJ_URLSessionTask;

@interface YJ_APIManager : NSObject

@property (nonatomic, copy) NSString *loggedUserName;
@property (nonatomic, copy) NSString *loggedUserPassword;
@property (nonatomic, assign, readonly) BOOL isLoggedIn;
@property (nonatomic, assign, readonly) BOOL isFirstLanuch;

+(instancetype)sharedInstance;

- (void)saveLoggedUser:(NSString *)userName password:(NSString *)password;
- (void)saveLoggedInStatus;
- (NSDictionary *)retrieveLoggedUser;
- (void)logout;

- (void)saveProfile:(NSDictionary *)dictionary;
- (YJ_UserProfile *)readProfile;

-(NSDictionary *)readProfileDictionary;

#pragma mark - POST Method
-(void)postParameters:(NSDictionary *)parameters
              withURL:(NSString *)urlString
     withSuccessBlock:(YJ_ResponseSuccess)successBlock
     withFailureBlock:(YJ_ResponseFail)failureBlock
         withProgress:(YJ_DownloadProgress)progress;

#pragma mark - GET Method
-(void)getParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress;

-(void)getWeatherParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress;

#pragma mark - Delete Method
-(void)deleteParameters:(NSDictionary *)parameters
                withURL:(NSString *)urlString
       withSuccessBlock:(YJ_ResponseSuccess)successBlock
       withFailureBlock:(YJ_ResponseFail)failureBlock
           withProgress:(YJ_DownloadProgress)progress;

#pragma mark - Put Method
-(void)putParameters:(NSDictionary *)parameters
             withURL:(NSString *)urlString
    withSuccessBlock:(YJ_ResponseSuccess)successBlock
    withFailureBlock:(YJ_ResponseFail)failureBlock
        withProgress:(YJ_DownloadProgress)progress;

#pragma mark - 文件下载
-(YJ_URLSessionTask *)downloadFileWithURL:(NSString *)urlString
                              withSavaPath:(NSString *)savePath
                          withSuccessBlock:(YJ_ResponseSuccess)successBlock
                          withFailureBlock:(YJ_ResponseFail)failureBlock
                      withDownLoadProgress:(YJ_DownloadProgress)progress;

@end
