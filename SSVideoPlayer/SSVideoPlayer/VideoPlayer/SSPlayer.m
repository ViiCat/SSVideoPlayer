//
//  SSPlayer.m
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/6.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import "SSPlayer.h"
#import <Masonry/Masonry.h>

@interface SSPlayer()
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, copy) PlayerItemStatusBlock playerItemStatusBlock;
@property (nonatomic, copy) PlayerItemLoadTimeRangesBlock playerItemLoadTimeRangesBlock;
@property (nonatomic, strong)AVPlayerItem *currentItem;
@end

@implementation SSPlayer

// Override UIView method
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithContainer:(UIView *)view {
    if (self = [super init]) {
        
        AVPlayer *player  = [AVPlayer playerWithPlayerItem:nil];
        
        self.playerLayer = (AVPlayerLayer *)self.layer;
        self.playerLayer.player = player;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

        [view insertSubview:self atIndex:0];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    return self;
}

#pragma mark - User Action
- (void)play {
    [self.playerLayer.player play];
}

- (void)pause {
    [self.playerLayer.player pause];
}


- (void)replaceVideoWithUrl:(NSURL *)url status:(PlayerItemStatusBlock)statusBlock {
    self.playerItemStatusBlock = statusBlock;
    
    if (self.currentItem) {[self removeObserver];}
    
    AVAsset *avaset = [AVAsset assetWithURL:url];
    self.currentItem = [AVPlayerItem playerItemWithAsset:avaset];

    [self registerObserver];
    [self.playerLayer.player replaceCurrentItemWithPlayerItem:self.currentItem];
}

- (void)seekToTime:(NSTimeInterval)interval {

    [self.playerLayer.player seekToTime:CMTimeMake(interval, 1) toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
        
    }];
}

#pragma mark - Observe
- (void)registerObserver {
    
    if (self.currentItem) {
        
        /// 监听视频资源装载状态
        [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        /// 监听资源缓冲时间
        [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserver {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        /// 资源装载状态
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        if (self.playerItemStatusBlock) {
            self.playerItemStatusBlock(status);
        }
        
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        /// 资源缓冲时间
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges firstObject] CMTimeRangeValue];
            CMTime bufferDuration = CMTimeAdd(timerange.start, timerange.duration);
            // 获取到缓冲的时间,然后除以总时间,得到缓冲的进度
            if (self.playerItemLoadTimeRangesBlock) {
                self.playerItemLoadTimeRangesBlock(CMTimeGetSeconds(bufferDuration));
            }
        }
    }
}

- (void)addPeriodicTimeUsingBlock:(PeriodicTimeBlock)periodicBlock {
    // Invoke callback every half second
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    // Queue on which to invoke the callback
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Add time observer
    //    self.timeObserverToken =
    [self.playerLayer.player addPeriodicTimeObserverForInterval:interval
                                                          queue:mainQueue
                                                     usingBlock:^(CMTime time) {
                                                         // Use weak reference to self
                                                         // Update player transport UI
                                                         periodicBlock(CMTimeGetSeconds(time));
                                                     }];
}

- (void)addLoadTimeRangeBlock:(PlayerItemLoadTimeRangesBlock)loadTimeRangesBlock {
    self.playerItemLoadTimeRangesBlock = loadTimeRangesBlock;
}

#pragma mark - Other
- (NSTimeInterval)totalTime {
    CMTime totalTime = self.playerLayer.player.currentItem.duration;
    NSTimeInterval sec = CMTimeGetSeconds(totalTime);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    CMTime currentTime = self.playerLayer.player.currentTime;
    NSTimeInterval sec = CMTimeGetSeconds(currentTime);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

#pragma mark - Converter
+ (NSString *)stringDateTimeFromTimeInterval:(NSTimeInterval)interval {
    NSInteger hour = ((NSInteger)interval) / 3600;
    NSInteger minute = ((NSInteger)interval) / 60;
    NSInteger sec = ((NSInteger)interval) % 60;
    NSString *strTotal = @"00:00";
    if (hour) {
        strTotal = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour, (long)minute, sec];
    } else {
        strTotal = [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, sec];
    }
    return strTotal;
}
@end
