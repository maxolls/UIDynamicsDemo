//
//  DDBasicsViewController.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/12/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.
//

#import "DDBasicsViewController.h"

@interface DDBasicsViewController ()
@property (nonatomic,strong) UIDynamicAnimator *animator;

@property (nonatomic,strong) IBOutlet UIButton *snapButton;
@property (nonatomic,strong) UIView *snapAnchor;
@property (nonatomic,strong) UISnapBehavior *snap;
@property (nonatomic) BOOL canSnap;

@property (nonatomic,strong) IBOutlet UIButton *attachButton;
@property (nonatomic,strong) UIView *attachAnchor;
@property (nonatomic,strong) UIAttachmentBehavior *attach;
@property (nonatomic) BOOL canAttach;
@end

@implementation DDBasicsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canSnap = NO;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - actions 

-(IBAction)gravityButtonPressed:(UIButton*)sender{
    UIGravityBehavior *g = [[UIGravityBehavior alloc] initWithItems:@[sender]];
    [self.animator addBehavior:g];
}

-(IBAction)gravityCollisionButtonPressed:(UIButton*)sender{
    UIGravityBehavior *g = [[UIGravityBehavior alloc] initWithItems:@[sender]];
    [self.animator addBehavior:g];
    
    UICollisionBehavior *c = [[UICollisionBehavior alloc] initWithItems:@[sender]];
    c.collisionMode = UICollisionBehaviorModeBoundaries;
    c.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:c];
}

-(IBAction)attachmentButtonPressed:(UIButton*)sender{
    self.canAttach = !self.canAttach;
    if (self.canSnap) {
        self.canSnap = NO;
        self.snapButton.backgroundColor = [UIColor darkGrayColor];
    }
    if (self.canAttach) {
        sender.backgroundColor = [UIColor redColor];
    }else{
        sender.backgroundColor = [UIColor darkGrayColor];
    }
}

-(IBAction)snapButtonPressed:(UIButton*)sender{
    self.canSnap = !self.canSnap;
    if (self.canAttach) {
        self.canAttach = NO;
        self.attachButton.backgroundColor = [UIColor darkGrayColor];
    }
    if (self.canSnap) {
        sender.backgroundColor = [UIColor redColor];
    }else{
        sender.backgroundColor = [UIColor darkGrayColor];
    }
}

-(void)tap:(UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.view];
    if (self.canSnap) {
        if (self.snap) [self.animator removeBehavior:self.snap];
        self.snap = [[UISnapBehavior alloc] initWithItem:self.snapButton snapToPoint:point];
        [self.animator addBehavior:self.snap];
        
        if (!self.snapAnchor) {
            self.snapAnchor = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
            self.snapAnchor.backgroundColor = [UIColor darkGrayColor];
            [self.view addSubview:self.snapAnchor];
        }
        self.snapAnchor.center = point;
        
    } else if (self.canAttach){
        if (!self.attach) {
            self.attach = [[UIAttachmentBehavior alloc] initWithItem:self.attachButton attachedToAnchor:point];
            self.attach.length = 0;
            self.attach.frequency = 1;
            self.attach.damping = .8;
            [self.animator addBehavior:self.attach];
        }
        [self.attach setAnchorPoint:point];
        
        if (!self.attachAnchor) {
            self.attachAnchor = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
            self.attachAnchor.backgroundColor = [UIColor darkGrayColor];
            [self.view addSubview:self.attachAnchor];
        }
        self.attachAnchor.center = point;
    }
}

-(IBAction)pushButtonPressed:(UIButton*)sender{
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[sender] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(-1, -1);
    [self.animator addBehavior:push];
}

-(IBAction)itemBehaviorButtonPressed:(UIButton*)sender{
    UIGravityBehavior *g = [[UIGravityBehavior alloc] initWithItems:@[sender]];
    [self.animator addBehavior:g];
    
    UICollisionBehavior *c = [[UICollisionBehavior alloc] initWithItems:@[sender]];
    c.collisionMode = UICollisionBehaviorModeBoundaries;
    c.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:c];
    
    UIDynamicItemBehavior *itemB = [[UIDynamicItemBehavior alloc] initWithItems:@[sender]];
    itemB.elasticity = .9;
    [self.animator addBehavior:itemB];
}

@end
