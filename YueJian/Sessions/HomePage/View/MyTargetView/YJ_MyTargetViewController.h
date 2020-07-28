//
//  YJ_MyTargetViewController.h
//  YueJian
//
//  Created by Garry on 2018/4/27.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

typedef void(^TargetCallback)(NSString *meter);

@interface YJ_MyTargetViewController : YJ_BaseViewController

@property (nonatomic, copy) TargetCallback callback;

@end
