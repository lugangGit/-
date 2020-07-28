//
//  YJ_AddPlanViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_AddPlanViewModel.h"

@implementation YJ_AddPlanViewModel
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
    return [RACSignal combineLatest:@[RACObserve(self, startTime), RACObserve(self, endTime), RACObserve(self, playType)] reduce:^id(NSString *startTime, NSString *endTime, NSString *playType){
        NSLog(@"startTime:%@,endTime:%@,playType:%@", startTime,endTime,playType);
        return @(startTime.length > 0 && endTime.length > 0  && playType.length > 0 && playType.length <= 8);
    }];
}

- (void)addPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock WithFailureBlock:(YJ_ResponseFail)failureBlock {
    //判断时间段
    NSString *string;
    if (6 <= [[self.startTime substringToIndex:3] integerValue] && [[self.startTime substringToIndex:3] integerValue] <= 8) {
        string = @"早晨";
    }else if (8 < [[self.startTime substringToIndex:3] integerValue] && [[self.startTime substringToIndex:3] integerValue] < 11)  {
        string = @"上午";
    }else if (11 <= [[self.startTime substringToIndex:3] integerValue] && [[self.startTime substringToIndex:3] integerValue] <= 13)  {
        string = @"中午";
    }else if (13 < [[self.startTime substringToIndex:3] integerValue] && [[self.startTime substringToIndex:3] integerValue] <= 17)  {
        string = @"下午";
    }else if (17 < [[self.startTime substringToIndex:3] integerValue] && [[self.startTime substringToIndex:3] integerValue] <= 22)  {
        string = @"晚上";
    }else {
        string = @"夜间";
    }
    NSLog(@"%ld", (long)[[self.startTime substringToIndex:3] integerValue]);
    NSString *playTime = [NSString stringWithFormat:@"%@~%@", self.startTime, self.endTime];
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] postParameters:@{@"userId" : userProfile.userID,
                                                     @"playTimeType" : string,
                                                     @"playTime" : playTime,
                                                     @"playType" : self.playType,
                                                     @"eatPlan" : self.eatPlan,
                                                    }
                                           withURL:kPlanPostAddURL
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
