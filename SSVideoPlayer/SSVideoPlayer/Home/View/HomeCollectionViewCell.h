//
//  HomeCollectionViewCell.h
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/5.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

@end

NS_ASSUME_NONNULL_END
