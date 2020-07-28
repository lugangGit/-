//
//  YJ_LoginViewMode.m
//  YueJian
//
//  Created by Garry on 2018/4/12.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_LoginViewModel.h"

@implementation YJ_LoginViewModel

- (instancetype) init
{
    self = [super init];
    if (self) {
        _loginCommand = [[RACCommand alloc] initWithEnabled:[self validateInputs]
                                                signalBlock:^RACSignal *(id input) {
                                                    return [RACSignal empty];
                                                }];
    }
    
    return self;
}

-(RACSignal *)validateInputs
{
    return [RACSignal combineLatest:@[RACObserve(self, userName), RACObserve(self, password)] reduce:^id(NSString *userName, NSString *pd){
        NSLog(@"%@", pd);
        return @([userName jk_isMobileNumber] && pd.length >= 1 && pd.length <= 16);
    }];
}

-(void)loginWithSuccessBlock:(YJ_ResponseSuccess)successBlock
            WithFailureBlock:(YJ_ResponseFail)failureBlock
{
    [[YJ_APIManager sharedInstance] postParameters:@{
                                                     @"phoneNum": self.userName,
                                                     @"password":self.password
                                                    }
                                            withURL:kLoginURL
                                   withSuccessBlock:^(id response)
     {
         if ([response[@"code"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             YJ_UserProfile *user = [[YJ_UserProfile alloc] initWithDictionary:response[@"data"]];
             [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
             [[YJ_APIManager sharedInstance] saveLoggedInStatus];
             ALBBMANAnalytics *man = [ALBBMANAnalytics getInstance];
             [man updateUserAccount:user.phoneNum userid:user.userID];
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

@end
