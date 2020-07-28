//
//  YJ_MyInfoViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/3.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_MyInfoViewModel.h"

@implementation YJ_MyInfoViewModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        _NicknameConfirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputsNickname]
                                                  signalBlock:^RACSignal *(id input) {
                                                      return [RACSignal empty];
                                                  }];
        _BirthConfirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputsBirth]
                                                          signalBlock:^RACSignal *(id input) {
                                                              return [RACSignal empty];
                                                          }];
    }
    
    return self;
}

-(RACSignal *)validateInputsNickname
{
    return [RACSignal combineLatest:@[RACObserve(self, nickname)] reduce:^id(NSString *nickname){
        NSLog(@"nickname:%@", nickname);
        return @(nickname.length > 0 && nickname.length <= 15);
    }];
}

-(RACSignal *)validateInputsBirth
{
    return [RACSignal combineLatest:@[RACObserve(self, birth)] reduce:^id(NSString *birth){
        NSLog(@"birth:%@", birth);
        return @(birth.length > 0);
    }];
}

- (void)submitChangeWithNickname:(NSString *)nickname withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    NSLog(@"userProfile = %@，token = %@", userProfile.userID, userProfile.token);
    [[YJ_APIManager sharedInstance] putParameters:@{
                                                    @"userId":userProfile.userID,
                                                    @"nickname":nickname
                                                   }
                                          withURL:kChangeNicknameURL
                                 withSuccessBlock:^(id response) {
                                     //success
                                     if ([response[@"code"] isEqual:@0]) {
                                         NSError *underlyingError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:errno userInfo:response];
                                         failureBlock(underlyingError);
                                     }else
                                     {
                                         [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
                                         [[YJ_APIManager sharedInstance] saveLoggedInStatus];
                                         successBlock(response);
                                     }
                                 } withFailureBlock:^(NSError *error) {
                                     failureBlock(error);
                                     
                                 } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                                 }];
}

- (void)submitChangeWithSex:(NSString *)sex withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    NSLog(@"userProfile = %@，token = %@", userProfile.userID, userProfile.token);
    [[YJ_APIManager sharedInstance] putParameters:@{
                                                     @"userId":userProfile.userID,
                                                     @"sex":sex
                                                   }
                                          withURL:kChangeSexURL
      withSuccessBlock:^(id response) {
          //success
          if ([response[@"code"] isEqual:@0]) {
              NSError *underlyingError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:errno userInfo:response];
              failureBlock(underlyingError);
          }else
          {
              [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
              [[YJ_APIManager sharedInstance] saveLoggedInStatus];
              successBlock(response);
          }
    } withFailureBlock:^(NSError *error) {
        failureBlock(error);
    } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
    }];
}

- (void)submitChangeWithBirth:(NSString *)birth withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    NSLog(@"userProfile = %@，token = %@", userProfile.userID, userProfile.token);
    [[YJ_APIManager sharedInstance] putParameters:@{
                                                    @"userId":userProfile.userID,
                                                    @"birth":birth
                                                   }
                                          withURL:kChangeBirthURL
                                 withSuccessBlock:^(id response) {
                                     //success
                                     if ([response[@"code"] isEqual:@0]) {
                                         NSError *underlyingError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:errno userInfo:response];
                                         failureBlock(underlyingError);
                                     }else
                                     {
                                         [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
                                         [[YJ_APIManager sharedInstance] saveLoggedInStatus];
                                         successBlock(response);
                                     }
                                 } withFailureBlock:^(NSError *error) {
                                     failureBlock(error);
                                     
                                 } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                                 }];
}

- (void)submitChangeWithAvatar:(NSString *)avatar withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] putParameters:@{
                                                     @"userId":userProfile.userID,
                                                     @"avatar":avatar
                                                   }
                                          withURL:kChangeAvatarURL
                                 withSuccessBlock:^(id response) {
                                     if ([response[@"code"] isEqual:@0]) {
                                         NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:response];
                                         failureBlock(underlyingError);
                                     }else
                                     {
                                         //请求成功，更新数据
                                         [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
                                         [[YJ_APIManager sharedInstance] saveLoggedInStatus];
                                         successBlock(response);
                                     }
                                 } withFailureBlock:^(NSError *error) {
                                     failureBlock(error);
                                 } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                                 }];
}

- (void)logoutWithSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    [[YJ_APIManager sharedInstance] deleteParameters:nil withURL:kLogoutURL withSuccessBlock:^(id response) {
        if ([response[@"code"] isEqual:@0]) {
            NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                  code:errno userInfo:response];
            failureBlock(underlyingError);
        }else
        {
            //请求成功，更新数据
            [[YJ_APIManager sharedInstance] logout];
            successBlock(response);
        }
    } withFailureBlock:^(NSError *error) {
        failureBlock(error);
    } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
    }];
}

@end
