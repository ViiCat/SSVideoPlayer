//
//  FSLiveStreamNavigationView.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/10.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLiveStreamViewModel.h"

typedef NS_ENUM(NSInteger, FSLiveStreamDanmakuState) {
    FSLiveStreamDanmakuStateClose,
    FSLiveStreamDanmakuStateOpen,
};

@class FSLiveStreamNavigationView;
@protocol FSLiveStreamNavigationViewDelegate<NSObject>
- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav shareClick:(id)sender;
- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav danmakuClick:(id)sender;
- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav backClick:(id)sender;
@end

/**
 * 自定义导航
 */
@interface FSLiveStreamNavigationView : UIView
@property (nonatomic, weak) id<FSLiveStreamNavigationViewDelegate> delegate;
@property (nonatomic, strong) FSLiveStreamViewModel *model;
@property (nonatomic, assign, readonly) FSLiveStreamDanmakuState danmakuState;

- (void)updateStateWithOrientation:(UIInterfaceOrientation)orientation mediaType:(FSLiveStreamMediaType)mediaType;

- (void)destoryObject;
@end
