//
//  FSAudioTimerPanelView.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/12.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSAudioTimerPanelView.h"

@interface FSAudioTimerPanelView()
@property (weak, nonatomic) IBOutlet UILabel *lbTime;

@property (nonatomic, assign) NSInteger times;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FSAudioTimerPanelView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.timer fire];
}

- (void)setModel:(FSLiveStreamViewModel *)model {
    _model = model;
    self.times = model.time_played.integerValue;
}

- (void)destoryObject {
    [self.timer invalidate];
    self.timer = nil;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)onTimer:(NSTimer *)timer {
    self.times += 1;
    self.lbTime.text = [NSString stringWithFormat:@"正音频直播 %@", [self formateTime: self.times]];
}

- (NSString *)formateTime:(NSInteger)time {
    NSMutableString *mString = @"".mutableCopy;
    NSInteger h = time/(60*60);
    NSInteger m = (time/60)%60;
    NSInteger s = time%60;
    if (h>0) {
        [mString appendFormat:@"%ld小时",h];
    }
    if (mString.length > 0 || m>0) {
        [mString appendFormat:@"%ld分钟",m];
    }
    
    if (mString.length > 0 || s>0) {
        [mString appendFormat:@"%ld秒",s];
    }
    
    return mString.copy;
}
@end
