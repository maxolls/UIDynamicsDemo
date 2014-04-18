//
//  DDNodeView.m
//  DynamicsDemo
//
//  Created by Maxime Ollivier on 11/13/13.
//  Copyright (c) 2013 SolsticeConsulting. All rights reserved.
//

#import "DDNodeView.h"

@interface DDNodeView ()

@end

@implementation DDNodeView

- (id)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center
{
    self = [super initWithFrame:CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2)];
    if (self) {
        self.layer.cornerRadius = radius;
        self.layer.sublayerTransform = CATransform3DMakeTranslation(radius, radius, 0);
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = self.frame.size.width/2.0;
        self.layer.sublayerTransform = CATransform3DMakeTranslation(self.frame.size.width/2.0, self.frame.size.width/2.0, 0);
    }
    return self;
}
//
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [self.backgroundColor setFill];
//    CGContextFillEllipseInRect(context, rect);
//}

@end
