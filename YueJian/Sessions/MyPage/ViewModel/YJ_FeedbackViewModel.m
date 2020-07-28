//
//  YJ_FeedbackViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_FeedbackViewModel.h"

@implementation YJ_FeedbackViewModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        _ConfirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputs]
                                                  signalBlock:^RACSignal *(id input) {
                                                      return [RACSignal empty];
                                                  }];
    }
    
    return self;
}

-(RACSignal *)validateInputs
{
    return [RACSignal combineLatest:@[RACObserve(self, feedBack)] reduce:^id(NSString *feedBack){
        NSLog(@"feedBack:%@", feedBack);
        return @(feedBack.length > 0 && feedBack.length <= 100);
    }];
}

- (void)postFeedbackWithSuccessBlock:(YJ_ResponseSuccess)successBlock WithFailureBlock:(YJ_ResponseFail)failureBlock {
    [[YJ_APIManager sharedInstance] postParameters:@{
                                                     @"content": self.feedBack,
                                                     @"userId": @""
                                                     }
                                           withURL:kFeedbackURL
                                  withSuccessBlock:^(id response) {
                                      //判断请求是否成功
                                      if ([response[@"result"] isEqual:@0]) {
                                          //没有数据，进行异常处理
                                          NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:response];
                                          failureBlock(underlyingError);
                                      }else
                                      {
                                          successBlock(response);
                                      }
                                  } withFailureBlock:^(NSError *error) {
                                      //请求失败
                                      failureBlock(error);
                                  } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                                  }];
}

@end
