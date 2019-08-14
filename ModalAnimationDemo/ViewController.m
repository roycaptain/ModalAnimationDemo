//
//  ViewController.m
//  ModalAnimationDemo
//
//  Created by llbt-sk on 2019/8/14.
//  Copyright © 2019 llbt-sk. All rights reserved.
//

#import "ViewController.h"
#import "OnePresentationController.h"
#import "TwoPresentationController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,copy)NSArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self data];
    
    [self tableView];
}

#pragma mark - lazy load
-(UITableView *)tableView
{
    if (!_tableView) {
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.0f;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, width, height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(NSArray *)data
{
    if (!_data) {
        _data = @[
                  @"One",
                  @"Two"
                  ];
    }
    return _data;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = _data[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *oneVC = [mainSB instantiateViewControllerWithIdentifier:@"OneController"];
        OnePresentationController *presentationVC = [[OnePresentationController alloc] initWithPresentedViewController:oneVC presentingViewController:self];
        oneVC.transitioningDelegate = presentationVC;
        [self presentViewController:oneVC animated:YES completion:NULL];
    } else if (indexPath.row == 1) {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *twoVC = [mainSB instantiateViewControllerWithIdentifier:@"TwoController"];
        TwoPresentationController *presentationVC = [[TwoPresentationController alloc] initWithPresentedViewController:twoVC presentingViewController:self];
        twoVC.transitioningDelegate = presentationVC;
        [self presentViewController:twoVC animated:YES completion:NULL];
    }
}

@end
