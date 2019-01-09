//
//  FSLiveStreamViewModel.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/9.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLZBModel.h"

typedef NS_ENUM(NSInteger, FSLiveStreamMediaType) {
    FSLiveStreamMediaTypeVideo,
    FSLiveStreamMediaTypeAudio,
};

@interface FSLiveStreamViewModel : NSObject
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSNumber *original_price;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *is_member_free;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *poster_url;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *live_url;
@property (nonatomic, strong) NSNumber *live_type;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSNumber *clicks;
@property (nonatomic, strong) NSNumber *comments;
@property (nonatomic, strong) NSNumber *favorites;
@property (nonatomic, copy) NSString *start_time;
@property (nonatomic, copy) NSString *end_time;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSNumber *own;
@property (nonatomic, strong) NSNumber *time_played;
@property (nonatomic, strong) NSNumber *purchase_time_limit;
@property (nonatomic, strong) NSNumber *has_look_back;
@property (nonatomic, strong) NSNumber *is_ordered;
@property (nonatomic, strong) NSNumber *ordered_count;
@property (nonatomic, strong) NSNumber *buy_count;
@property (nonatomic, strong) NSNumber *has_class;

- (BOOL)isFree;

- (BOOL)canBuy;

/// 是否为已购买
- (BOOL)hasBuy;

- (NSString *)play_live_url:(FSLiveSharpness)sharp;

@end
