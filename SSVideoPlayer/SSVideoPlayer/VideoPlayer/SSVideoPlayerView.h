//
//  SSVideoPlayerView.h
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/5.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSVideoPlayerView;

@protocol SSVideoPlayerViewDelegate<NSObject>
/// 全屏
- (void)ssPlayerView:(SSVideoPlayerView *)playerView fullClick:(id)sender;
/// 取消全屏
- (void)ssPlayerView:(SSVideoPlayerView *)playerView narrowClick:(id)sender;
@end

NS_ASSUME_NONNULL_BEGIN

@interface SSVideoPlayerView : UIView
@property (nonatomic, weak) id<SSVideoPlayerViewDelegate>delegate;
@property (nonatomic, assign) BOOL isFullScreen;
/// Replace
- (void)replaceVideoWithUrl:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
