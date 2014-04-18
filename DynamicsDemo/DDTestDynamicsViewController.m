//
//  DDTestDynamicsViewController.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/10/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.

#import "DDTestDynamicsViewController.h"

@interface DDTestDynamicsViewController ()

//UI
@property (nonatomic,weak) IBOutlet UIView *menuView;

@property (nonatomic,weak) IBOutlet UISlider *countSlider;
@property (nonatomic,weak) IBOutlet UISlider *dampingSlider;
@property (nonatomic,weak) IBOutlet UISlider *lengthSlider;
@property (nonatomic,weak) IBOutlet UISlider *frequencySlider;
@property (nonatomic,weak) IBOutlet UISwitch *itemCollisionSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *wallCollisionSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *snapSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *pushSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *gravitySwitch;
@property (nonatomic,weak) IBOutlet UISwitch *allowRotationSwitch;
@property (nonatomic,weak) IBOutlet UISlider *angularResistanceSlider;
@property (nonatomic,weak) IBOutlet UISlider *densitySlider;
@property (nonatomic,weak) IBOutlet UISlider *elasticitySlider;
@property (nonatomic,weak) IBOutlet UISlider *frictionSlider;
@property (nonatomic,weak) IBOutlet UISlider *resistanceSlider;
@property (nonatomic,weak) IBOutlet UISegmentedControl *viewTypeSegment;

@property (nonatomic,weak) IBOutlet UILabel *countLabel;
@property (nonatomic,weak) IBOutlet UILabel *dampingLabel;
@property (nonatomic,weak) IBOutlet UILabel *lengthLabel;
@property (nonatomic,weak) IBOutlet UILabel *frequencyLabel;
@property (nonatomic,weak) IBOutlet UILabel *angularResistanceLabel;
@property (nonatomic,weak) IBOutlet UILabel *densityLabel;
@property (nonatomic,weak) IBOutlet UILabel *elasticityLabel;
@property (nonatomic,weak) IBOutlet UILabel *frictionLabel;
@property (nonatomic,weak) IBOutlet UILabel *resistanceLabel;

//Dynamics
@property (nonatomic,strong) UIDynamicAnimator *animator;
@property (nonatomic,strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic,strong) NSMutableArray *attachmentBehaviors;
@property (nonatomic,strong) NSMutableArray *snapBehaviors;
@property (nonatomic,strong) NSMutableArray *pushBehaviors;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIAttachmentBehavior *grabber;
@property (nonatomic,strong) UIGravityBehavior *g;
@property (nonatomic,strong) UICollisionBehavior *collision;
@property (nonatomic,strong) UICollisionBehavior *collisionWall;
@end

@implementation DDTestDynamicsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self setUpMenu];
    [self createItems];
    
    //Double tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning!");
}

#pragma mark - Create, delete. edit behaviors/items

-(void)createItems{
    for (int i =0; i<roundf(self.countSlider.value); i++) {
        [self createItem];
    }
}

-(void)createItem{
    //Items
    UIView *item = nil;
    if (self.viewTypeSegment.selectedSegmentIndex == 0) {
         item = [[UIView alloc] initWithFrame:CGRectMake((rand() % 400) + 300,
                                                                  (rand() % 400) + 300,
                                                                  60,
                                                                  60)];
        item.backgroundColor = [UIColor colorWithWhite:self.items.count/(roundf(self.countSlider.value)+1) alpha:1.0];
    } else if (self.viewTypeSegment.selectedSegmentIndex == 1){
        item = [[UILabel alloc] initWithFrame:CGRectMake((rand() % 400) + 300,
                                                         (rand() % 400) + 300,
                                                         60,
                                                         60)];
        [(UILabel*)item setText:@"Hello"];
    }else if (self.viewTypeSegment.selectedSegmentIndex == 2){
        item = [[UISwitch alloc] initWithFrame:CGRectMake((rand() % 400) + 300,
                                                          (rand() % 400) + 300,
                                                          60,
                                                          60)];
    }
    
    //item.backgroundColor=[UIColor blackColor];
    [self.view addSubview:item];
    
    //Gravity
    if (!self.g) self.g = [[UIGravityBehavior alloc] init];
    [self.g addItem:item];
    
    //Item dynamics
    if (!self.itemBehavior) {
        self.itemBehavior = [[UIDynamicItemBehavior alloc] init];
        [self.animator addBehavior:self.itemBehavior];
    }
    [self.itemBehavior addItem:item];
    
    //Attachments
    if (self.items.count>0) {
        UIView *lastItem = [self.items lastObject];
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:item
                                                                       attachedToItem:lastItem];
        attachment.length = self.lengthSlider.value;
        attachment.damping = self.dampingSlider.value;
        attachment.frequency =self.frequencySlider.value;
        [self.animator addBehavior:attachment];
        [self.attachmentBehaviors addObject:attachment];
    }
    [self.items addObject:item];
    
    //Snap - nothing
    
    //Push
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[item] mode:UIPushBehaviorModeInstantaneous];
    push.active = NO;
    [self.animator addBehavior:push];
    [self.pushBehaviors addObject:push];
    
    //Collision
    if (!self.collision) {
        self.collision = [[UICollisionBehavior alloc] init];
        self.collision.collisionMode = UICollisionBehaviorModeItems;
    }
    [self.collision addItem:item];
    
    //Collision wall
    if (!self.collisionWall) {
        self.collisionWall = [[UICollisionBehavior alloc] init];
        self.collisionWall.collisionMode = UICollisionBehaviorModeBoundaries;
        self.collisionWall.translatesReferenceBoundsIntoBoundary = YES;
    }
    [self.collisionWall addItem:item];
    
    [self updateItems];
}

-(void)deleteItems{
    
    //Item dynamics
    [self.animator removeBehavior:self.itemBehavior];
    self.itemBehavior = nil;
    
    //Gravity
    [self.animator removeBehavior:self.g];
    self.g=nil;
    
    //Attachments
    for (UIDynamicBehavior *b in self.attachmentBehaviors) [self.animator removeBehavior:b];
    self.attachmentBehaviors = nil;
    
    //Snap
    for (UIDynamicBehavior *b in self.snapBehaviors) [self.animator removeBehavior:b];
    self.snapBehaviors = nil;
    
    //Push
    for (UIDynamicBehavior *b in self.pushBehaviors) [self.animator removeBehavior:b];
    self.pushBehaviors = nil;
    
    //Collision
    [self.animator removeBehavior:self.collision];
    self.collision = nil;
    
    //Collision wall
    [self.animator removeBehavior:self.collisionWall];
    self.collisionWall = nil;
    
    //Items
    for (UIView *item in self.items) [item removeFromSuperview];
    [self.items removeAllObjects];
}

-(void)updateItems{
    //Item dynamics
    self.itemBehavior.elasticity = self.elasticitySlider.value;
    self.itemBehavior.friction = self.frictionSlider.value;
    self.itemBehavior.density = self.densitySlider.value;
    self.itemBehavior.resistance = self.resistanceSlider.value;
    self.itemBehavior.angularResistance = self.angularResistanceSlider.value;
    self.itemBehavior.allowsRotation = [self.allowRotationSwitch isOn];
    
    //Gravity
    if ([self.gravitySwitch isOn]) {
        [self.animator addBehavior:self.g];
    } else{
        [self.animator removeBehavior:self.g];
    }
    
    //Attachments
    for (UIAttachmentBehavior *attachment in self.attachmentBehaviors) {
        attachment.length = self.lengthSlider.value;
        attachment.damping = self.dampingSlider.value;
        attachment.frequency =self.frequencySlider.value;
    }
    
    //Snap
    for (UISnapBehavior *snap in self.snapBehaviors) {
        snap.damping = self.dampingSlider.value;
    }
    
    //Push - nothing
    //Collision
    if ([self.itemCollisionSwitch isOn]) {
        [self.animator addBehavior:self.collision];
    } else{
        [self.animator removeBehavior:self.collision];
    }
    
    //Collision wall - nothing
    if ([self.wallCollisionSwitch isOn]) {
        [self.animator addBehavior:self.collisionWall];
    } else{
        [self.animator removeBehavior:self.collisionWall];
    }
    
    [self updateDisplay];
}

-(void)updateDisplay{
    self.countLabel.text = [NSString stringWithFormat:@"%.1f",roundf(self.countSlider.value)];
    self.dampingLabel.text = [NSString stringWithFormat:@"%.1f",self.dampingSlider.value];
    self.lengthLabel.text = [NSString stringWithFormat:@"%.1f",self.lengthSlider.value];
    self.frequencyLabel.text = [NSString stringWithFormat:@"%.1f",self.frequencySlider.value];
    self.angularResistanceLabel.text = [NSString stringWithFormat:@"%.1f",self.angularResistanceSlider.value];
    self.densityLabel.text = [NSString stringWithFormat:@"%.1f",self.densitySlider.value];
    self.elasticityLabel.text = [NSString stringWithFormat:@"%.1f",self.elasticitySlider.value];
    self.frictionLabel.text = [NSString stringWithFormat:@"%.1f",self.frictionSlider.value];
    self.resistanceLabel.text = [NSString stringWithFormat:@"%.1f",self.resistanceSlider.value];
}

#pragma mark - actions

-(IBAction)sliderDidChange:(UISlider*)slider{
    if (slider == self.countSlider) {
        if (roundf(self.countSlider.value) != self.items.count) {
            [self deleteItems];
            [self createItems];
        }
    } else {
        [self updateItems];
    }
}

-(IBAction)switchDidChange:(UISwitch*)aSwitch{
    if (aSwitch == self.itemCollisionSwitch) {
        [self updateItems];
    } else if (aSwitch == self.wallCollisionSwitch) {
        [self updateItems];
    } else if (aSwitch == self.snapSwitch) {
        //nothing
    } else if (aSwitch == self.pushSwitch) {
        //nothing
    } else if (aSwitch == self.gravitySwitch) {
        [self updateItems];
    } else if (aSwitch == self.allowRotationSwitch) {
        [self updateItems];
    }
}

-(IBAction)redrawButtonPressed:(id)sender{
    [self deleteItems];
    [self createItems];
}

-(IBAction)segmentChanged:(id)sender{
    [self deleteItems];
    [self createItems];
}

-(IBAction)hideButtonPressed:(id)sender{
    CGRect newFrame = self.menuView.frame;
    newFrame.origin.x = - self.menuView.frame.size.width - 50;
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:.5
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.menuView.frame = newFrame;
                     }
                     completion:nil];
}

-(IBAction)showButtonPressed:(id)sender{
    CGRect newFrame = self.menuView.frame;
    newFrame.origin.x = 20;
    [UIView animateWithDuration:.9
                          delay:0
         usingSpringWithDamping:.5
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.menuView.frame = newFrame;
                     }
                     completion:nil];
}

#pragma mark - gesture

-(void)doubleTap:(UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.view];
    UIView *item = [self itemSelectedWithPoint:point];
    if (item) {
        if ([self.snapSwitch isOn]) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:item snapToPoint:item.center];
            snap.damping = self.dampingSlider.value;
            [self.animator addBehavior:snap];
            [self.snapBehaviors addObject:snap];
            item.backgroundColor = [UIColor redColor];
        }
    }else{
        if ([self.pushSwitch isOn]) {
            for (UIPushBehavior *push in self.pushBehaviors) {
                UIView *item = push.items[0];
                [push setPushDirection:CGVectorMake((item.center.x - point.x)/50.0,
                                                    (item.center.y - point.y)/50.0)];
                [push setActive:YES];
            }
        }
    }
    
}

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
        self.grabber.length = 0;
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
    for (UIView *item in self.items) {
        if (CGRectContainsPoint(item.frame, point)) {
            return item;
        }
    }
    return nil;
}

#pragma mark - setter and getter 

-(NSMutableArray *)items{
    if (!_items) _items = [NSMutableArray array];
    return _items;
}

-(NSMutableArray *)attachmentBehaviors{
    if (!_attachmentBehaviors) _attachmentBehaviors = [NSMutableArray array];
    return _attachmentBehaviors;
}

-(NSArray *)snapBehaviorsAtIndexes:(NSIndexSet *)indexes{
    if (_snapBehaviors)_snapBehaviors = [NSMutableArray array];
    return _snapBehaviors;
}

-(NSMutableArray *)pushBehaviors{
    if (!_pushBehaviors) _pushBehaviors = [NSMutableArray array];
    return _pushBehaviors;
}

#pragma mark - Menu set up

-(void)setUpMenu{
    //Add shadow
    //[self addShadowToMenuWithOpacity:.2];
    
    //...
}

-(void)addShadowToMenuWithOpacity:(CGFloat)opacity{
    self.menuView.layer.masksToBounds = NO;
    self.menuView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.menuView.layer.shadowRadius = 1;
    self.menuView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.menuView.layer.shadowOpacity = opacity;
}

@end
