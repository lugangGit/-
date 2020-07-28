//
//  YJ_CollectionViewCell.m
//  YueJian
//
//  Created by Garry on 2018/7/16.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_CollectionViewCell.h"

@implementation YJ_CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imagev];
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (UIImageView *)imagev{
    if (!_imagev) {
        self.imagev = [[UIImageView alloc] initWithFrame:self.bounds];
        //_imagev.backgroundColor = [UIColor blueColor];
    }
    return _imagev;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-20, 0, 20, 20);
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"icon_dynamic_photoDelete"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

@end
