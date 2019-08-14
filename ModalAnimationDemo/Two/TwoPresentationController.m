//
//  TwoPresentationController.m
//  ModalAnimationDemo
//
//  Created by llbt-sk on 2019/8/14.
//  Copyright © 2019 llbt-sk. All rights reserved.
//

#import "TwoPresentationController.h"

@interface TwoPresentationController ()<UIViewControllerAnimatedTransitioning>

@property(nonatomic,strong)UIView *maskView; // 遮罩层

@end

@implementation TwoPresentationController

#pragma mark - lazy load
-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.opaque = NO; //是否透明
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController:)]];
        [self.containerView addSubview:_maskView];
    }
    return _maskView;
}

- (void)dismissController:(UITapGestureRecognizer*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
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

-(void)presentationTransitionWillBegin
{
    [self maskView];
    // 获取presentingViewController 的转换协调器，应该动画期间的一个类？上下文？之类的，负责动画的一个东西
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    // 动画期间，背景View的动画方式
    _maskView.alpha = 0.f;
    __weak typeof(self) weakSelf = self;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        weakSelf.maskView.alpha = 0.4f;
    } completion:NULL];
}

-(void)presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed) {
        _maskView = nil;
    }
}

-(void)dismissalTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    __weak typeof(self) weakSelf = self;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        weakSelf.maskView.alpha = 0.f;
    } completion:NULL];
}

-(void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed) {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return self;
}

//--------以下四个方法，是按照苹果官方Demo里的，都是为了计算目标控制器View的frame的----------------
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
{
    if (container == self.presentedViewController)
        return ((UIViewController*)container).preferredContentSize;
    else
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    
    // The presented view extends presentedViewContentSize.height points from
    // the bottom edge of the screen.
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
    return presentedViewControllerFrame;
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    _maskView.frame = self.containerView.bounds;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [transitionContext isAnimated] ? 1.0 : 0;
}

// 核心，动画效果的实现
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 1.获取源控制器、目标控制器、动画容器View
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __unused UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    // 2. 获取源控制器、目标控制器 的View，但是注意二者在开始动画，消失动画，身份是不一样的：
    // 也可以直接通过上面获取控制器获取，比如：toViewController.view
    // For a Presentation:
    //      fromView = The presenting view.
    //      toView   = The presented view.
    // For a Dismissal:
    //      fromView = The presented view.
    //      toView   = The presenting view.
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [containerView addSubview:toView];  //必须添加到动画容器View上。
    
    // 判断是present 还是 dismiss
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
    CGFloat screenW = CGRectGetWidth(containerView.bounds);
    CGFloat screenH = CGRectGetHeight(containerView.bounds);
    
    // 左右留35
    // 上下留80
    
    // 屏幕顶部：
    CGFloat x = 40.0f;
    CGFloat y = -screenH;
    CGFloat w = screenW - x * 2;
    CGFloat h = screenH - 80.0f * 2;
    CGRect topFrame = CGRectMake(x, y, w, h);
    
    // 屏幕中间：
    CGRect centerFrame = CGRectMake(x, 80.0, w, h);
    
    // 屏幕底部
    CGRect bottomFrame = CGRectMake(x, screenH + 10, w, h);  //加10是因为动画果冻效果，会露出屏幕一点
    
    if (isPresenting) {
        toView.frame = topFrame;
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    // duration： 动画时长
    // delay： 决定了动画在延迟多久之后执行
    // damping：速度衰减比例。取值范围0 ~ 1，值越低震动越强
    // velocity：初始化速度，值越高则物品的速度越快
    // UIViewAnimationOptionCurveEaseInOut 加速，后减速
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (isPresenting)
            toView.frame = centerFrame;
        else
            fromView.frame = bottomFrame;
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
    
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    // 动画结束...
}


@end
