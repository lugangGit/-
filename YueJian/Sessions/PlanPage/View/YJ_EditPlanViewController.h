//
//  YJ_EditPlanViewController.h
//  YueJian
//
//  Created by Garry on 2018/7/31.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

typedef void(^Callback)(void);

@interface YJ_EditPlanViewController : YJ_BaseViewController

@property (nonatomic, copy) Callback callback;

@end
