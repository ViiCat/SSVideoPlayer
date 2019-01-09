//
//  AppDelegate.h
//  SSVideoPlayer
//
//  Created by Liu Jie on 2019/1/5.
//  Copyright © 2019 JasonMark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

