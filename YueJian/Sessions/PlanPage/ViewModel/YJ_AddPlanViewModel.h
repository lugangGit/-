//
//  YJ_AddPlanViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_AddPlanViewModel : YJ_BaseModel
@property(nonatomic, copy) NSString *startTime;
@property(nonatomic, copy) NSString *endTime;
@property(nonatomic, copy) NSString *playType;
@property(nonatomic, copy) NSString *eatPlan;
@property(readonly, strong) RACCommand *ConfirmCommand;

- (void)addPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
             WithFailureBlock:(YJ_ResponseFail)failureBlock;
@end
