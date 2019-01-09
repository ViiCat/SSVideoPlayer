//
//  SSPlayer.h
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/6.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^PlayerItemStatusBlock)(AVPlayerItemStatus status);
typedef void(^PeriodicTimeBlock)(NSTimeInterval interval);
typedef void(^PlayerItemLoadTimeRangesBlock)(NSTimeInterval interval);

@interface SSPlayer : UIView

- (instancetype)initWithContainer:(UIView *)view;
/// 播放
- (void)play;
/// 暂停
- (void)pause;
/// 时长
- (NSTimeInterval)totalTime;
/// 播放时长
- (NSTimeInterval)currentTime;
///
- (void)seekToTime:(NSTimeInterval)interval;
/// Replace Video Source
- (void)replaceVideoWithUrl:(NSURL *)url status:(PlayerItemStatusBlock) statusBlock;
/// Observe PlayTimer When Video Playing
- (void)addPeriodicTimeUsingBlock:(PeriodicTimeBlock)periodicBlock;
/// Observe LoadTimeRanges When Video Source Setup
- (void)addLoadTimeRangeBlock:(PlayerItemLoadTimeRangesBlock)loadTimeRangesBlock;

+ (NSString *)stringDateTimeFromTimeInterval:(NSTimeInterval)interval;
@end

NS_ASSUME_NONNULL_END
