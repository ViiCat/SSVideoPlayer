//
//  FSLiveStreamViewModel.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/9.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSLiveStreamViewModel.h"

@implementation FSLiveStreamViewModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id"};
}

- (BOOL)isFree {
    return [self.price floatValue] <= 0 || self.own;
}

- (BOOL)canBuy {
    return ((self.purchase_time_limit.integerValue - self.time_played.integerValue) > 0);
}

/// 是否为已购买
- (BOOL)hasBuy {
    
    if (self.state.integerValue == FSLiveStartedState && ![self canBuy]) {
        return false;
    }
    if (self.state.integerValue == FSLiveEndedState) {
        return false;
    }
    return true;
}

/// 高/标清
- (NSString *)play_live_url:(FSLiveSharpness)sharp {
    
    if (self.live_url.length <= 0) {
        return nil;
    }
    
    if (sharp == FSLiveSharpnessHight) {
        return [self.live_url stringByAppendingString:@"@720p"];
    }
    return [self.live_url stringByAppendingString:@"@480p"];
}
@end
