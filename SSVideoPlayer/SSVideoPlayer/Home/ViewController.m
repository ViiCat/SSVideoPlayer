//
//  ViewController.m
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/5.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import "ViewController.h"
#import "HomeCollectionViewCell.h"
#import "SSVideoPlayerView.h"

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) SSVideoPlayerView *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    

}

- (NSArray<NSDictionary *> *)dataSrouce {
    NSArray<NSDictionary *> *arr = @[@{@"title":@"倩狐：采访苏州孙女士65天减重27.6斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/11%E6%9C%88/%E5%80%A9%E7%8B%90%E4%B9%8B%E8%A1%8C%EF%BC%9A%E6%B1%9F%E8%8B%8F%E8%8B%8F%E5%B7%9E%E5%AD%99%E5%A5%B3%E5%A3%AB65%E5%A4%A9%E5%87%8F%E9%87%8D27.6%E6%96%A4%E5%8E%86%E7%A8%8B.mp4"},
                                   @{@"title":@"倩狐：采访天津刘女士90天减重23斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/9%E6%9C%88/%E5%80%A9%E7%8B%90%E9%87%87%E8%AE%BF%E5%A4%A9%E6%B4%A5%E5%88%98%E5%A5%B3%E5%A3%AB.mp4"},
                                   @{@"title":@"倩狐：采访南京朱女士60天减重26斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/9%E6%9C%88/%E5%80%A9%E7%8B%90%E9%87%87%E8%AE%BF%E5%8D%97%E4%BA%AC.mp4"},
                                   @{@"title":@"倩狐：采访青岛王女士产后减肥减重30斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/%E9%9D%92%E5%B2%9B%E7%8E%8B%E5%A5%B3%E5%A3%AB.mp4"},
                                   @{@"title":@"倩狐：采访北京方女士瘦19斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/%E6%96%B9%E5%A5%B3%E5%A3%AB%E7%98%A619%E6%96%A4.mp4"},
                                     @{@"title":@"倩狐：采访苏州孙女士65天减重27.6斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/11%E6%9C%88/%E5%80%A9%E7%8B%90%E4%B9%8B%E8%A1%8C%EF%BC%9A%E6%B1%9F%E8%8B%8F%E8%8B%8F%E5%B7%9E%E5%AD%99%E5%A5%B3%E5%A3%AB65%E5%A4%A9%E5%87%8F%E9%87%8D27.6%E6%96%A4%E5%8E%86%E7%A8%8B.mp4"},
                                     @{@"title":@"倩狐：采访天津刘女士90天减重23斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/9%E6%9C%88/%E5%80%A9%E7%8B%90%E9%87%87%E8%AE%BF%E5%A4%A9%E6%B4%A5%E5%88%98%E5%A5%B3%E5%A3%AB.mp4"},
                                     @{@"title":@"倩狐：采访南京朱女士60天减重26斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/9%E6%9C%88/%E5%80%A9%E7%8B%90%E9%87%87%E8%AE%BF%E5%8D%97%E4%BA%AC.mp4"},
                                     @{@"title":@"倩狐：采访青岛王女士产后减肥减重30斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/%E9%9D%92%E5%B2%9B%E7%8E%8B%E5%A5%B3%E5%A3%AB.mp4"},
                                     @{@"title":@"倩狐：采访北京方女士瘦19斤历程", @"url":@"https://fox239-com.oss-cn-shanghai.aliyuncs.com/%E6%96%B9%E5%A5%B3%E5%A3%AB%E7%98%A619%E6%96%A4.mp4"}];
    return arr;
}

#pragma mark - Orientation Support
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    NSLog(@">>>>>%d", self.player.isFullScreen);
//    return self.player.isFullScreen ? UIInterfaceOrientationMaskLandscapeLeft : UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self dataSrouce].count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 6.0;
    cell.lbTitle.text = [self dataSrouce][indexPath.row][@"title"];
    return cell;
}

////设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 30) / 2.0;
    return CGSizeMake(itemWidth, itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strUrl = [self dataSrouce][indexPath.row][@"url"];
    [self.player replaceVideoWithUrl:[NSURL URLWithString:strUrl]];
    [self.view addSubview:self.player];
}

- (SSVideoPlayerView *)player {
    if (!_player) {
        _player = [[NSBundle mainBundle] loadNibNamed:@"SSVideoPlayerView" owner:self options:nil].firstObject;
    }
    return _player;
}
@end
