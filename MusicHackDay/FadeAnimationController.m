//
//  FadeAnimationController.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "FadeAnimationController.h"

@interface FadeAnimationController ()

@end

@implementation FadeAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 画面遷移コンテキストから遷移元、遷移先ビューコントローラの取得 --- (1)
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 画面遷移コンテキストからコンテナビューを取得 --- (2)
    UIView *containerView = [transitionContext containerView];
    
    // コンテナビュー上に遷移先ビューを追加 --- (3)
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         // アニメーションを実行 --- (4)
                         fromVC.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         // 画面遷移完了を通知 --- (5)
                         [transitionContext completeTransition:YES];
                     }];
}
@end
