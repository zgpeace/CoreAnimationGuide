//
//  ViewController.m
//  CoreAnimationGuide
//
//  Created by zgpeace on 15/07/2017.
//  Copyright © 2017 zgpeace. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *animationImage;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
- (IBAction)clickOpacity:(id)sender;
- (IBAction)clickBounce:(id)sender;
- (IBAction)clickGroup:(id)sender;
- (IBAction)clickViewBlock:(id)sender;
- (IBAction)clickTransition:(id)sender;
- (IBAction)clickKeyframePause:(id)sender;
- (IBAction)clickKeyframeResume:(id)sender;
- (IBAction)clickExplicitTransaction:(id)sender;
- (IBAction)clickNestTransaction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layer Pausing and Resuming Animations

- (void)pauseLayer:(CALayer *)layer
{
    CFTimeInterval pauseTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pauseTime;
}

- (void)resumeLayer:(CALayer *)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark - button action
- (IBAction)clickOpacity:(id)sender {
    // implicit animation
//    _animationImage.layer.opacity = 0.0;
    
    // explicit animation
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:_animationImage.layer.opacity];
    fadeAnimation.toValue = [NSNumber numberWithFloat:_animationImage.layer.opacity == 1.0 ? 0.0 : 1.0];
    fadeAnimation.duration = 1.0;
    [_animationImage.layer addAnimation:fadeAnimation forKey:@"opacity"];

    // Change the actual data value in the layer to the final value.
    _animationImage.layer.opacity = ((NSNumber *)fadeAnimation.toValue).floatValue;
    
}

- (IBAction)clickBounce:(id)sender {
    // create a CGPath that implements two arcs (a bounce)
    CGMutablePathRef thePath = CGPathCreateMutable();
    
    CGPathMoveToPoint(thePath,NULL,74.0,74.0);
    CGPathAddCurveToPoint(thePath,NULL,74.0,500.0,
                          160.0,500.0,
                          160.0,74.0);
    CGPathAddCurveToPoint(thePath,NULL,160.0,500.0,
                          280.0,500.0,
                          280.0,74.0);
    
    CAKeyframeAnimation *theAnimation;
    
    // Create the animation object, specifying the position property as the key path.
    theAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.path = thePath;
    theAnimation.duration = 5.0;
    
    // Add the animation to the layer.
    [_animationImage.layer addAnimation:theAnimation forKey:@"position"];
}

- (IBAction)clickGroup:(id)sender {
    // Animation 1
    CAKeyframeAnimation *widthAnimation = [CAKeyframeAnimation animationWithKeyPath:@"borderWidth"];
    NSArray *widthValues = [NSArray arrayWithObjects:@1.0, @10.0, @5.0, @30.0, @0.5, @15.0, @2.0, @50.0, @0.0, nil];
    widthAnimation.values = widthValues;
    widthAnimation.calculationMode = kCAAnimationPaced;
    
    // Animation 2
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"borderColor"];
    NSArray *colorValues = [NSArray arrayWithObjects:(id)[UIColor greenColor].CGColor, (id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor, nil];
    colorAnimation.values = colorValues;
    colorAnimation.calculationMode = kCAAnimationPaced;
    
    // Animation group
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[widthAnimation, colorAnimation];
    group.duration = 5.0;
    
    [_animationImage.layer addAnimation:group forKey:@"BorderChanges"];
}

- (IBAction)clickViewBlock:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        // Change the opacity implicity.
//        _animationImage.layer.opacity = ((_animationImage.layer.opacity == 1.0)? 0.0 : 1.0);
        
        // Change the position explicityly.
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        theAnimation.fromValue = [NSValue valueWithCGPoint:_animationImage.layer.position];
        theAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 100)];
        theAnimation.duration = 3.0;
        [_animationImage.layer addAnimation:theAnimation forKey:@"AnimateFrame"];
    }];
}

- (IBAction)clickTransition:(id)sender {
    
    
    CATransition *transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 1.0;
    
    // Add the transition animation to both layers
    [_view1.layer addAnimation:transition forKey:@"transition"];
    [_view2.layer addAnimation:transition forKey:@"transition"];
    
    // Finally, change the visibility of the layers.
    _view1.hidden = YES;
    _view2.hidden = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _view1.hidden = NO;
        _view2.hidden = NO;
    });
}

- (IBAction)clickKeyframePause:(id)sender {
    [self pauseLayer:_animationImage.layer];
}

- (IBAction)clickKeyframeResume:(id)sender {
    [self resumeLayer:_animationImage.layer];
}

- (IBAction)clickExplicitTransaction:(id)sender {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:10.0f] forKey:kCATransactionAnimationDuration];
    // Perform the animations
    _animationImage.layer.zPosition = 200.0;
    _animationImage.layer.opacity = _animationImage.layer.opacity == 0.0 ? 1.0 : 0.0;
    [CATransaction commit];
}

- (IBAction)clickNestTransaction:(id)sender {
    [CATransaction begin]; //Outer transaction
    
    // Change the animation duration to two seconds
    [CATransaction setValue:[NSNumber numberWithFloat:2.0f] forKey:kCATransactionAnimationDuration];
    // Move the layer to a new position
    _animationImage.layer.position = CGPointMake(0.0, 0.0);
    
    [CATransaction begin];  // Inner transaction
    // Change the aniamtion duration to five seconds
    [CATransaction setValue:[NSNumber numberWithFloat:5.0f] forKey:kCATransactionAnimationDuration];
    
    // Change the zPosition and opacity
    _animationImage.layer.zPosition = 200.0;
    _animationImage.layer.opacity = 0.0;
    
    [CATransaction commit]; // Inner transaction
    [CATransaction commit]; // Outer transaction
}



@end























