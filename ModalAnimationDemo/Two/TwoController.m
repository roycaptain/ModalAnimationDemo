//
//  TwoController.m
//  ModalAnimationDemo
//
//  Created by llbt-sk on 2019/8/14.
//  Copyright © 2019 llbt-sk. All rights reserved.
//

#import "TwoController.h"

@interface TwoController ()

@end

@implementation TwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100.0f, 60.0f, 120.0f, 60.0f);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
