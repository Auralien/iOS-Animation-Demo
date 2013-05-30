//
//  ADMViewController.m
//  AnimationDemo
//
//  Created by Maxim Mikheev on 24.05.13.
//  Copyright (c) 2013 Maxim Mikheev. All rights reserved.
//

#import "ADMViewController.h"

CGFloat const barsSlideDelta = 210.0;
CGFloat const cardWidth = 200.0;
CGFloat const cardHeight = 287.0;

@interface ADMViewController ()

@property (nonatomic) BOOL boxIsClosed;

@property (nonatomic, weak) IBOutlet UIButton *startAnimationButton;
@property (nonatomic, weak) IBOutlet UIImageView *left;
@property (nonatomic, weak) IBOutlet UIImageView *right;
@property (nonatomic, weak) IBOutlet UIImageView *center;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundOpen;

@end

@implementation ADMViewController

/// Method handles user press on Hearthstone button and starts animation process
- (IBAction)buttonPressed:(id)sender {
    if (self.boxIsClosed) {
        [self animationStep1Rotation];
    }
}

/// Method animates first Pi rotation
- (void)animationStep1Rotation {
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.center.transform = CGAffineTransformMakeRotation(- M_PI + 0.0001);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Rotation 1 Finished");
                         [self animationStep2Rotation];
                     }];
}

/// Method animates second Pi rotation
- (void)animationStep2Rotation {
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center.transform = CGAffineTransformMakeRotation(0 + 0.0002);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Rotation 2 Finished");
                         [self animationStep3Slide];
                     }];
}

/// Method animated box bars sliding
- (void)animationStep3Slide {
    [UIView animateWithDuration:1.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         /// Show Background 
                         self.backgroundOpen.layer.opacity = 1;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:2
                     animations:^{
                         /// Left Bar Slide
                         self.left.frame = CGRectMake(self.left.frame.origin.x - barsSlideDelta,
                                                      self.left.frame.origin.y,
                                                      self.left.frame.size.width,
                                                      self.left.frame.size.height);
                         
                         /// Right Bar Slide
                         self.right.frame = CGRectMake(self.right.frame.origin.x + barsSlideDelta,
                                                       self.right.frame.origin.y,
                                                       self.right.frame.size.width,
                                                       self.right.frame.size.height);
                         
                         /// Center Slide
                         self.center.frame = CGRectMake(self.center.frame.origin.x + barsSlideDelta,
                                                        self.center.frame.origin.y,
                                                        self.center.frame.size.width,
                                                        self.center.frame.size.height);
                         self.center.layer.opacity = 0.0;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Slide Finished");
                         self.boxIsClosed = NO;
                         self.startAnimationButton.userInteractionEnabled = NO;
                         [self animationStep4Cards];
                     }];
}

/// Method animates cards appearance
- (void)animationStep4Cards {
    for (NSInteger i = 9; i > 0; i--) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"card0%d.png", i]]];
        NSInteger yStart = (i % 2 == 0) ? self.view.frame.size.height + 10 : - cardHeight - 10;
        imageView.frame = CGRectMake(self.view.center.x, yStart, cardWidth, cardHeight);
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        [imageView addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [imageView addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.delegate = self;
        [imageView addGestureRecognizer:longPress];
        
        [self.view insertSubview:imageView belowSubview:self.left];
        [self.images addObject:imageView];
        
        [UIView animateWithDuration:0.5
                              delay:(double)(9 - i) * 0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGFloat viewWidth, viewHeight;
                             if (self.view.frame.size.width > self.view.frame.size.height) {
                                 viewWidth = self.view.frame.size.width;
                                 viewHeight = self.view.frame.size.height;
                             } else {
                                 viewWidth = self.view.frame.size.height;
                                 viewHeight = self.view.frame.size.width;
                             }
                             
                             CGRect rect = CGRectMake(arc4random() % (int)(viewWidth - cardWidth),
                                                      arc4random() % (int)((viewHeight - cardHeight)),
                                                      imageView.frame.size.width,
                                                      imageView.frame.size.height);
                             imageView.frame = rect;
                             
                             CGFloat angle = - 0.1 + (double)arc4random()/RAND_MAX * 0.1;
                             NSLog(@"Card rotation angle = %f", angle);
                             imageView.transform = CGAffineTransformMakeRotation(angle);
                         }
                         completion:nil];
    }
}

/// Method removes card from screen and from cards array by user tap
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIImageView *imageView = (UIImageView *)[tapGestureRecognizer view];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([tapGestureRecognizer numberOfTouches] == 2) {
                             imageView.layer.opacity = 0;
                         } else {
                             [self.view bringSubviewToFront:imageView];
                         }
                     }
                     completion:^(BOOL finished){
                         if ([tapGestureRecognizer numberOfTouches] == 2) {
                             [self.images removeObject:imageView];
                         }
                     }];
}

/// Method changes card's position
- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *piece = [panGestureRecognizer view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = panGestureRecognizer.view;
        CGPoint locationInView = [panGestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [panGestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
    
    if ([panGestureRecognizer state] == UIGestureRecognizerStateBegan || [panGestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [panGestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

/// Method removes card by long press
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    UIImageView *imageView = (UIImageView *)[longPressGestureRecognizer view];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        imageView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished){
                        [self.images removeObject:imageView];
                     }];
}

/// Method resets graphic elements depending on screen's size (needed for iPhone 5)
- (void)prepareGraphics {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    /// Setting View
    if(screenRect.size.width > screenRect.size.height){
        self.view.frame = CGRectMake(screenRect.origin.x,
                                     screenRect.origin.y,
                                     screenRect.size.width,
                                     screenRect.size.height);
    } else {
        self.view.frame = CGRectMake(screenRect.origin.x,
                                     screenRect.origin.y,
                                     screenRect.size.height,
                                     screenRect.size.width);
    }
    
    /// Setting Left Bar Image Frame
    self.left.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.left.frame.size.width,
                                 self.view.frame.size.height - self.left.frame.size.height,
                                 self.left.frame.size.width,
                                 self.left.frame.size.height);
    
    /// Setting Right Bar Image Frame
    self.right.frame = CGRectMake(self.view.frame.size.width / 2.0,
                                 self.view.frame.size.height - self.right.frame.size.height,
                                 self.right.frame.size.width,
                                 self.right.frame.size.height);
    
    /// Setting Center Image Frame
    self.center.frame = CGRectMake((self.view.frame.size.width - self.center.frame.size.width) / 2.0,
                                   (self.view.frame.size.height - self.center.frame.size.height) / 2.0,
                                   self.center.frame.size.width,
                                   self.center.frame.size.height);
    
    /// Setting Start Animation Button Frame
    self.startAnimationButton.frame = CGRectMake((self.view.frame.size.width - self.center.frame.size.width) / 2.0,
                                                 (self.view.frame.size.height - self.center.frame.size.height) / 2.0,
                                                 self.center.frame.size.width,
                                                 self.center.frame.size.height);
    
    /// Setting Background Open Image Frame
    self.backgroundOpen.frame = self.view.frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareGraphics];
    
    self.boxIsClosed = YES;
    self.images = [NSMutableArray array];
}

@end
