//
//  ZJCommit.m
//  ZJCommitListDemo
//
//  Created by 邓志坚 on 2017/12/10.
//  Copyright © 2017年 邓志坚. All rights reserved.
//

#import "ZJCommit.h"

@implementation ZJCommit

//-(NSArray *)pic_urls{
//    if (self.img_data.length > 5) {
//        NSData *jsonData = [self.img_data dataUsingEncoding:NSUTF8StringEncoding];
//
//        
//        NSError *error = nil;
//        NSArray  *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingAllowFragments
//                                                          error:&error];
//        
//        if (jsonObject != nil && error == nil){
//            _pic_urls = jsonObject;
//        }else{
//            // 解析错误
//            return nil;
//        }
//        
////        NSString *imgArrStr = [NSJSONSerialization JSONObjectWithData:jsonData
////
////                                                              options:NSJSONReadingMutableContainers
////
////                                                                error:&err];
////
////        NSLog(@"评论图片数组字符串---> %@",imgArrStr);
////        NSArray *array = [imgArrStr componentsSeparatedByString:@","];
////        NSLog(@"评论图片数组字符串---> %@ ----> 一共 %ld 张",imgArrStr,array.count);
////        _pic_urls = array;
//    }
//     return _pic_urls;
//    
//}

-(id)initWithDict:(NSDictionary *)dict{
    if (self == [super init]) {
        self.dynameicId = dict[@"id"];
        self.uid = dict[@"userId"];
        self.avatar  = dict[@"avatarImg"];
        self.nickname = dict[@"nickName"];
        self.add_time = dict[@"releaseTimeStr"];
        self.content = dict[@"content"];
        self.img_data = dict[@"imgList"];
        self.city = dict[@"position"];
        self.pic_urls = dict[@"imgList"];
        
//        self.dynameicId = dict[@"dynameicId"];
//        self.uid = dict[@"uid"];
//        self.avatar  = dict[@"avatar"];
//        self.nickname = dict[@"nickname"];
//        self.add_time = dict[@"add_time"];
//        self.content = dict[@"content"];
//        self.img_data = dict[@"img_data"];
        
      /*self.img_data = dict[@"img_data"];
        self.like_id = dict[@"like_id"];
        self.like_count = dict[@"like_count"];
        self.unlike_count = dict[@"unlike_count"];
        self.rating = dict[@"rating"];*/
    }
    return self;
}

+(instancetype)commitWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}


@end
