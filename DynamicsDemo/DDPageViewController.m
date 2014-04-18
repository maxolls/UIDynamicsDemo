//
//  DDPageViewController.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/10/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.
//

#import "DDPageViewController.h"
#import "DDTestDynamicsViewController.h"
#import "DDBasicsViewController.h"
#import "DDSystemExamplesViewController.h"
#import "DDGraphViewController.h"

@interface DDPageViewController ()
@property (nonatomic,strong) NSMutableArray *controllers;
@end

@implementation DDPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpControllers];
	
    //Set up UIPageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[self.controllers[0]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    self.pageViewController.dataSource = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    [self.pageViewController didMoveToParentViewController:self];
    
    [self setUpGestures];
}

-(void)setUpControllers{
    
    //Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //Intro
    DDBasicsViewController *intro= [storyboard instantiateViewControllerWithIdentifier:@"Intro"];
    [self.controllers addObject:intro];
    
    //Basic
    DDBasicsViewController *basic= [storyboard instantiateViewControllerWithIdentifier:@"DDBasicsViewController"];
    [self.controllers addObject:basic];
    
    //System
    DDSystemExamplesViewController *systemEx= [storyboard instantiateViewControllerWithIdentifier:@"DDSystemExamplesViewController"];
    [self.controllers addObject:systemEx];
    
    //Alert
    DDSystemExamplesViewController *alert= [storyboard instantiateViewControllerWithIdentifier:@"DDSystemExamplesViewControllerAlertView"];
    [self.controllers addObject:alert];
    
    //Test
    DDTestDynamicsViewController *test= [storyboard instantiateViewControllerWithIdentifier:@"DDTestDynamicsViewController"];
    [self.controllers addObject:test];
    
    //Graph
    DDGraphViewController *g= [storyboard instantiateViewControllerWithIdentifier:@"DDGraphViewController"];
    [self.controllers addObject:g];
    
}

-(void)setUpGestures{
    for (UIGestureRecognizer *r  in self.pageViewController.gestureRecognizers) {
        r.enabled = NO;
    }
    
    UISwipeGestureRecognizer *swipeNext = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage)];
    swipeNext.numberOfTouchesRequired = 2;
    swipeNext.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeNext];
    
    UISwipeGestureRecognizer *swipeBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousPage)];
    swipeBack.numberOfTouchesRequired = 2;
    swipeBack.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeBack];
}

#pragma mark - Page control

-(void)nextPage{
    UIViewController *nextController = [self pageViewController:nil viewControllerAfterViewController:self.pageViewController.viewControllers[0]];
    if (nextController) {
        [self.pageViewController setViewControllers:@[nextController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
    }
}

-(void)previousPage{
    UIViewController *nextController = [self pageViewController:nil viewControllerBeforeViewController:self.pageViewController.viewControllers[0]];
    if (nextController) {
        [self.pageViewController setViewControllers:@[nextController]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES
                                         completion:nil];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.controllers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) return nil;
    index--;
    return self.controllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.controllers indexOfObject:viewController];
    if (index == NSNotFound) return nil;
    index++;
    if (index == [self.controllers count]) return nil;
    return self.controllers[index];
}

#pragma mark - setter and getter

-(NSMutableArray *)controllers{
    if (!_controllers) _controllers = [NSMutableArray array];
    return _controllers;
}

@end
