//
//  SSVideoPlayerView.m
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/5.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import "SSVideoPlayerView.h"
#import "SSPlayer.h"
#import "Masonry.h"

@interface SSVideoPlayerView()
@property (nonatomic, strong) SSPlayer *player;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerHeight;
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalTime;
@property (weak, nonatomic) IBOutlet UILabel *lbPlayTime;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnFullNarrow;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end
@implementation SSVideoPlayerView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.player = [[SSPlayer alloc] initWithContainer:self.playerContainer];
    [self.slider setThumbImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (deviceOrientation == UIDeviceOrientationPortrait) {
        [self setChangeOrientation:UIInterfaceOrientationPortrait];
        
    } else {//if (deviceOrientation == UIDeviceOrientationLandscapeLeft ) {
        [self setChangeOrientation:UIInterfaceOrientationLandscapeLeft];
    }
}

- (void)replaceVideoWithUrl:(NSURL *)url {
    __weak typeof(self) weakSelf = self;
    [self.player replaceVideoWithUrl:url status:^(AVPlayerItemStatus status) {
        // Switch over the status
        if (status == AVPlayerItemStatusReadyToPlay) {
            [weakSelf registerObserver];
            [weakSelf.player play];
            [weakSelf.btnPlayPause setSelected:YES];
            weakSelf.lbTotalTime.text = [SSPlayer stringDateTimeFromTimeInterval:[weakSelf.player totalTime]];
        } else {
            // Failed.
        }
    }];
}

- (IBAction)closeClick:(id)sender {
    [self.player pause];
    [self removeFromSuperview];
}
#pragma mark - Public
- (void)setChangeOrientation:(UIInterfaceOrientation)orientation {
    
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        /// 全屏
        self.isFullScreen = YES;
        self.btnClose.hidden = YES;
        self.btnFullNarrow.selected = YES;
        
        self.playerHeight.constant = self.frame.size.height;
        
    } else if(orientation == UIInterfaceOrientationPortrait) {
        /// 取消全屏
        self.isFullScreen = NO;
        self.btnClose.hidden = NO;
        self.btnFullNarrow.selected = NO;
        
        self.playerHeight.constant = self.frame.size.width * 9.0 / 16.0;
    }
}

#pragma mark - Action
- (IBAction)playAndPauseClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        /// 播放
        [self.player play];
        
    } else {
        /// 暂停
        [self.player pause];
    }
}

- (IBAction)fullAndNarrowClick:(id)sender {
    UIButton *btn = (UIButton *)sender;

    if (btn.selected) {
        /// 取消全屏
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        [self setChangeOrientation:UIInterfaceOrientationPortrait];
        
    } else {
        /// 全屏
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        [self setChangeOrientation:UIInterfaceOrientationLandscapeLeft];
    }
}

- (IBAction)progressValueChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSTimeInterval sliderSec = slider.value * [self.player totalTime];
    self.lbPlayTime.text = [SSPlayer stringDateTimeFromTimeInterval:sliderSec];
}

- (IBAction)sliderTouchDown:(id)sender {
    [self.player pause];
}

- (IBAction)sliderTouchUpInside:(id)sender {
    UISlider *slider = (UISlider *)sender;
    
    self.btnPlayPause.selected = YES;
    NSTimeInterval sliderSec = slider.value * [self.player totalTime];
    [self.player seekToTime:sliderSec];
    [self.player play];
}

#pragma mark - Observe
- (void)registerObserver {
    
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeUsingBlock:^(NSTimeInterval interval) {
        weakSelf.lbPlayTime.text = [SSPlayer stringDateTimeFromTimeInterval:interval];
        weakSelf.slider.value = interval / [weakSelf.player totalTime];
    }];
    
    [self.player addLoadTimeRangeBlock:^(NSTimeInterval interval) {
//        NSLog(@"LoadTime:%f",interval);
    }];
}

- (void)dealloc {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
