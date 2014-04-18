//
//  DDGraphViewController.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/12/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.
//

#import "DDGraphViewController.h"
#import "DDNodeView.h"

@interface DDGraphViewController ()
@property (nonatomic,weak) IBOutlet UIView *nodeRoot;

@property (nonatomic,strong) UIDynamicAnimator *animator;
@property (nonatomic,strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic,strong) UIAttachmentBehavior *grabber;
@property (nonatomic) NSInteger totalLevels;
//@property (nonatomic,strong) NSMutableArray *pushBehaviors;
@end

@implementation DDGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setUpAnimator];
}

-(void)setUpAnimator{
    srand(time(0));
    
    //Animator
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    //Item behavior
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.nodeRoot]];
    self.itemBehavior.allowsRotation = NO;
    self.itemBehavior.resistance = 1;
    [self.animator addBehavior:self.itemBehavior];
    
    //Snap
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.nodeRoot snapToPoint:self.nodeRoot.center];
    [self.animator addBehavior:snap];
    
    //Add items
    [self startRecursiveTree];
}

-(void)startRecursiveTree{
    self.totalLevels = 4;
    [self recursiveTreeWithNode:self.nodeRoot andLevelLeft:self.totalLevels];
}

-(void)recursiveTreeWithNode:(UIView*)node andLevelLeft:(NSInteger)levelLeft{
    if (levelLeft>0) {
        NSInteger subNodeCount = 2+( rand()%3);
        for (int i = 0; i<subNodeCount; i++) {
            
            //Add subview
            CGPoint relativeCenterPoint = [self polarToCartesianWithRadianAngle:i*(2*M_PI/subNodeCount)
                                                            withMagnitude:30.0];
            CGPoint absoluteCenterPoint = CGPointMake(node.center.x + relativeCenterPoint.x,
                                                node.center.y + relativeCenterPoint.y);
            if (!CGPointEqualToPoint(absoluteCenterPoint, self.nodeRoot.center)) {
                DDNodeView *subNode = [[DDNodeView alloc] initWithRadius:10.0 withCenter:absoluteCenterPoint];
                
                subNode.backgroundColor = [UIColor colorWithWhite:0.0
                                                            alpha:((float)levelLeft/((float)self.totalLevels *1.1))];
                [self.view addSubview:subNode];
                
                //Attachment
                //[self attachmentView:node andView:subNode withLength:(self.totalLevels-levelLeft)*10.0];
                [self attachmentView:node andView:subNode withLength:20.0 withFequency:levelLeft*2];
                
                //Push away from node root
                [self pushView:subNode awayFromView:self.nodeRoot];
                
                //Add to item behavior
                [self.itemBehavior addItem:subNode];
                
                //Recursive tree
                [self recursiveTreeWithNode:subNode andLevelLeft:levelLeft-1];
            }
        }
    }
}

-(void)attachmentView:(UIView*)a andView:(UIView*)b withLength:(CGFloat)lenght withFequency:(CGFloat)frequency{
    UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc] initWithItem:a attachedToItem:b];
    attach.length = lenght;
    attach.frequency = frequency;
    attach.damping = 1;
    [self.animator addBehavior:attach];
}

-(void)pushView:(UIView*)a awayFromView:(UIView*)b{
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[a] mode:UIPushBehaviorModeContinuous];
    CGPoint fromPoint = b.center;
    CGPoint toPoint = a.center;
    CGFloat dx = toPoint.x - fromPoint.x;
    CGFloat dy = toPoint.y - fromPoint.y;
    if (dx==0 && dy==0) {
        NSLog(@"Warning: -(void)pushView:(UIView*)a awayFromView:(UIView*)b");
    }
    CGFloat length = sqrtf(dx * dx + dy * dy);
    push.pushDirection = CGVectorMake(dx/length, dy/length);
    [self.animator addBehavior:push];
}

-(CGPoint)polarToCartesianWithRadianAngle:(CGFloat)angle withMagnitude:(CGFloat)magnitude{
    return CGPointMake(magnitude * cosf(angle), magnitude * sinf(angle));
}

#pragma mark - gesture

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.view];
    UIView *item = [self itemSelectedWithPoint:point];
    if (item) {
        CGPoint pointInsideView = [self.view convertPoint:point toView:item];
        self.grabber = [[UIAttachmentBehavior alloc] initWithItem:item
                                                 offsetFromCenter:UIOffsetMake(pointInsideView.x - item.frame.size.width/2.0,
                                                                               pointInsideView.y - item.frame.size.height/2.0)
                                                 attachedToAnchor:point];
        //self.grabber.length=1;
        [self.animator addBehavior:self.grabber];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.animator removeBehavior:self.grabber];
    self.grabber = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.animator removeBehavior:self.grabber];
    self.grabber = nil;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    self.grabber.anchorPoint = [touch locationInView:self.view];
}

-(UIView*)itemSelectedWithPoint:(CGPoint)point{
    for (UIView *item in self.view.subviews) {
        if (CGRectContainsPoint(item.frame, point)) {
            return item;
        }
    }
    return nil;
}


@end
