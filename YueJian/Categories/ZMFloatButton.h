//
//  ZMFloatButton.h
//  xinzibao
//
//  Created by mac on 2017/2/7.
//  Copyright © 2017年 jiangzhenmin. All rights reserved.
//
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#import <UIKit/UIKit.h>
@class ZMFloatButton;
@protocol ZMFloatButtonDelegate <NSObject>

@required

- (void)floatTapAction:(ZMFloatButton *)sender;

@end
@interface ZMFloatButton : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, assign) id<ZMFloatButtonDelegate> delegate;
@property (nonatomic, strong) UIImageView *bannerIV;//浮标的imageview
@property (nonatomic, assign) BOOL isMoving;//是否可移动

@end
