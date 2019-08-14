//
//  OnePresentationController.m
//  ModalAnimationDemo
//
//  Created by llbt-sk on 2019/8/14.
//  Copyright © 2019 llbt-sk. All rights reserved.
//

#import "OnePresentationController.h"

@interface OnePresentationController ()

@property(nonatomic,strong)UIView *maskView;

@end

@implementation OnePresentationController

#pragma mark - lazy load
-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.opaque = NO; // 是否透明
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController:)]];
        [self.containerView addSubview:_maskView];
    }
    return _maskView;
}

#pragma mark - 点击遮罩层
- (void)dismissController:(UITapGestureRecognizer*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return self;
}

// 重写 initWithPresentedViewController
-(instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        // 必须设置 presentedViewController 的 modalPresentationStyle
        // 在自定义动画效果的情况下，苹果强烈建议设置为 UIModalPresentationCustom
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

// 开始呈现
- (void)presentationTransitionWillBegin
{
    // 设置遮罩层
    [self maskView];
    // 获取presentingViewController 的转换协调器，应该动画期间的一个类？上下文？之类的，负责动画的一个东西
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    // 动画期间，背景View的动画方式
    _maskView.alpha = 0.0f;
    __weak typeof(self) weakSelf = self;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        weakSelf.maskView.alpha = 0.4f;
    } completion:NULL];
}

// 在呈现过渡结束时被调用的，并且该方法提供一个布尔变量来判断过渡效果是否完成
- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed) {
        _maskView = nil;
    }
}

- (void)dismissalTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    __weak typeof(self) weakSelf = self;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        weakSelf.maskView.alpha = 0.f;
    } completion:NULL];
}

// 消失过渡完成之后调用，此时应该将视图移除，防止强引用
- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
}

// 跳转控制器设置
- (CGRect)frameOfPresentedViewInContainerView
{
    CGFloat height = 300.f;
    
    CGRect containerViewBounds = self.containerView.bounds;
    containerViewBounds.origin.y = containerViewBounds.size.height - height;
    containerViewBounds.size.height = height;
    return containerViewBounds;
}

// 控制器内容大小变化时，就会调用这个方法
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    _maskView.frame = self.containerView.bounds;
}

@end
