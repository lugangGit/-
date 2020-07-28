//
//  YJ_PlanViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/8.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_PlanViewModel : YJ_BaseModel

- (void)handlerGetHeaderPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                            withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)handlerGetCellPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                          withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)deletePlanWithPlanId:(NSString *)planId
                  withSuccessBlock:(YJ_ResponseSuccess)successBlock
                  withFailureBlock:(YJ_ResponseFail)failureBlock;
@end
