//
//  ViewController.m
//  360 Exterior View
//
//  Created by Shubham on 07/09/17.
//  Copyright © 2017 Shubham. All rights reserved.
//

#import "ViewController.h"
#define SCROLL_STEP_WIDTH 2
#define SCROLL_MAX_WIDTH 99999
#define MIN_OFFSET 99900
#define MAX_OFFSET 110318
#define BASE_STRING @"https://imgd.aeplcdn.com/725x408/cw/360/marutisuzuki/1082/closed-door/"


@interface ViewController () <UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSInteger currentIndex,newIndex;
    NSMutableArray *imageArray;
    BOOL zoomed;
    CGFloat previousScale, currentScale;
    CGFloat currentOffset;
    CGFloat totalSize;
}

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIScrollView *gestureView;

@end

@implementation ViewController

-(UITapGestureRecognizer *)tapGestureRecognizer {
    if(!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        _tapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _tapGestureRecognizer;
}

-(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if(!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
        previousScale = currentScale = 1;
    }
    return _pinchGestureRecognizer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self configureGestureScrollView];
    [self addGestureRecognizers];
    
    totalSize = 0;
    imageArray = [NSMutableArray array];
    
    for (NSInteger index = 0; index < 36; index += 1)
    {
        NSNumber *imageSize = [NSNumber numberWithInt:(int)[self getImageForIndex:index]];
        totalSize += imageSize.floatValue;
    }
    
    NSLog(@"TOTAL SIZE -> %f MB",totalSize/(1024*1024));
    
    currentOffset = SCROLL_MAX_WIDTH;
    currentIndex = 0;
    
    [self setCarImageWithAnimation:NO];
}

-(void)configureGestureScrollView {
    
    _gestureView.contentSize = CGSizeMake(2*SCROLL_MAX_WIDTH, _gestureView.contentSize.height);
    _gestureView.contentOffset = CGPointMake(SCROLL_MAX_WIDTH, _gestureView.contentOffset.y);

    _gestureView.delegate = self;
    _gestureView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [_gestureView setShowsHorizontalScrollIndicator:NO];
    [_gestureView setShowsVerticalScrollIndicator:NO];
    [_gestureView setBounces:NO];
}

-(void)addGestureRecognizers {
    
    [self.gestureView addGestureRecognizer:self.tapGestureRecognizer];
    [self.gestureView addGestureRecognizer:self.pinchGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollDistance, scrollStep;
    
    scrollDistance = ((int)scrollView.contentOffset.x - (currentOffset));
    scrollStep = [self getScrollStepSizeForScrolledDistance:scrollDistance];
    
    if(scrollView.tracking)
        newIndex = currentIndex + ((int)([self signum:scrollDistance]*(scrollStep/SCROLL_STEP_WIDTH)));
    else
        newIndex = currentIndex + (int)([self signum:scrollDistance]*(scrollStep/1.5*SCROLL_STEP_WIDTH));
    
    newIndex = (newIndex + 36) % 36;
    
    if(newIndex != currentIndex)
    {
        currentIndex = newIndex;
        [self setCarImageWithAnimation:NO];
        
        currentOffset = (int)scrollView.contentOffset.x;
    }
    
    if(scrollView.contentOffset.x < MIN_OFFSET || scrollView.contentOffset.x > MAX_OFFSET)
    {
        currentOffset = SCROLL_MAX_WIDTH;
        [scrollView setContentOffset:CGPointMake(SCROLL_MAX_WIDTH, scrollView.contentOffset.y)];
    }
    NSLog(@"Curr offset -> %lf",scrollView.contentOffset.x);
    NSLog(@"OFFSET -> %lf",scrollDistance);
    NSLog(@"FACTOR -> %lf",scrollStep/SCROLL_STEP_WIDTH);
    NSLog(@"SCROLL");
    
    
}

- (void)didTap:(UITapGestureRecognizer *)sender {
    
    if(!zoomed)
        self.carImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    else
        self.carImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    zoomed = !zoomed;
}

-(void)didPinch:(UIPinchGestureRecognizer *)sender {

    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {

        currentScale = previousScale * sender.scale;
        
        if(currentScale < 1.0)
            currentScale = 1.0;
        else if(currentScale > 3.0)
            currentScale  = 3.0;

        self.carImageView.transform = CGAffineTransformMakeScale(currentScale, currentScale);
        previousScale = _carImageView.frame.size.width / _carImageView.bounds.size.width;
        sender.scale = 1.0;
    }
}

- (void)setCarImageWithAnimation:(BOOL)animation {
    [_carImageView setImage:[imageArray objectAtIndex:(currentIndex)%36]];

}

-(NSInteger)signum:(CGFloat)value {
    return ((value > 0) ? (1) : (-1));
}

-(CGFloat)getScrollStepSizeForScrolledDistance:(CGFloat)scrollDistance {
    return pow(fabs(scrollDistance),1.0/2.5);
}

-(NSInteger)getImageForIndex:(NSInteger)index {
    
    NSString *imageUrlString = [NSString stringWithFormat:@"%@%ld.jpg?wm=1&q=80",BASE_STRING,2*index+1];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    
    [imageArray addObject:image];
    return imageData.length;
}
















//- (void)didPan:(UIPanGestureRecognizer *)sender {
//
//
//    CGPoint velocity = [sender velocityInView:self.carImageView];
//
//    NSLog(@"VELOCITY -> %f",velocity.x);
//    NSLog(@"FACTOR -> %f\n\n",(float)sqrt((log(fabs(velocity.x))/log(1.023))));
//
//        newIndex = currentIndex - (fabs(velocity.x)/(velocity.x)) * (float)sqrt((log(fabs(velocity.x))/log(1.023)));
//        newIndex = (newIndex + 72) % 72;
//
//        if(newIndex != currentIndex) {
//
//            currentIndex = newIndex;
//
////            if(sender.state == UIGestureRecognizerStateChanged)
//                [self setCarImageWithAnimation:NO];
////            else
////                [self setCarImageWithAnimation:YES];
////        }
//    }
//}





@end
