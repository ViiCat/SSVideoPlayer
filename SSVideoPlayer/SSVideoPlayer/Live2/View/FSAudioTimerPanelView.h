//
//  FSAudioTimerPanelView.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/12.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLiveStreamViewModel.h"

/**
 * 音频播放时长计时面板
 */
@interface FSAudioTimerPanelView : UIView
@property (nonatomic, strong) FSLiveStreamViewModel *model;

- (void)destoryObject;
@end
