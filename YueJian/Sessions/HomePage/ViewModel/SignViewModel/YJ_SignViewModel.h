//
//  YJ_SignViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/6.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_SignViewModel : YJ_BaseModel

- (void)handlerPostSignData:(NSString *)currentDate withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)handlerGetSignDataWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                      withFailureBlock:(YJ_ResponseFail)failureBlock;
@end
