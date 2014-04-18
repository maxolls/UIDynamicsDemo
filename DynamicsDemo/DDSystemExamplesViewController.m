//
//  DDSystemExamplesViewController.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/12/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.
//

#import "DDSystemExamplesViewController.h"

@interface DDSystemExamplesViewController ()

@end

@implementation DDSystemExamplesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(IBAction)alertFastButtonPresser:(UIButton*)sender{
    CGRect newFrame = sender.frame;
    newFrame.size.height = newFrame.size.height + 40;
    newFrame.size.width = newFrame.size.width + 40;
    newFrame.origin.x = newFrame.origin.x - 20;
    newFrame.origin.y = newFrame.origin.y - 20;
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         sender.frame = newFrame;
                     }
                     completion:nil];
}

-(IBAction)alertSlowButtonPresser:(UIButton*)sender{
    CGRect newFrame = sender.frame;
    newFrame.size.height = newFrame.size.height + 40;
    newFrame.size.width = newFrame.size.width + 40;
    newFrame.origin.x = newFrame.origin.x - 20;
    newFrame.origin.y = newFrame.origin.y - 20;
    [UIView animateWithDuration:2
                          delay:0
         usingSpringWithDamping:.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         sender.frame = newFrame;
                     }
                     completion:nil];
}

-(IBAction)alertButtonPressed:(id)sender{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Sup" message:nil delegate:nil cancelButtonTitle:@"Not much" otherButtonTitles:nil];
    [a show];
}



@end
