#import "ViewController.h"
#import "quartzView.h"
#import "Flock.h"

@implementation ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation :(UIInterfaceOrientation)i
{
    return i == UIInterfaceOrientationPortrait || i == UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction)speedChanged:(UISlider *)sender {
    targetDeltaAngle = sender.value / 10;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
