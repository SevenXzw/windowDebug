//
//  ViewController.m
//  debugVisualizeLibrary
//
//  Created by 许振文 on 2021/1/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    UIButton *aBtn =[UIButton buttonWithType:(UIButtonTypeSystem)];
    [aBtn addTarget:self action:@selector(click) forControlEvents:(UIControlEventTouchUpInside)];
    [aBtn setTitle:@"Prenst" forState:(UIControlStateNormal)];
    [aBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    aBtn.center = self.view.center;
    [aBtn sizeToFit];
    [self.view addSubview:aBtn];
    
    [self click];
}

- (void)click{
    ViewController *ctrl = [[ViewController alloc] init];
    [self presentViewController:ctrl animated:true completion:nil];
}

@end
