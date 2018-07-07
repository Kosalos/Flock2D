#import "Boid.h"
#import "quartzView.h"

@implementation Boid
@synthesize position,velocity,imageIndex;

-(float)random {
    return (float)(rand() & 1023)/1024.0;
}

-(void)positionReset {
    position.x = XCENTER -200 + [self random] * 400;
    position.y = YCENTER -300 + [self random] * 600;
    
    velocity.x = velocity.y = 0;
    imageIndex = 0;
}

-(id)init {
    self = [super init];
    
    [self positionReset];
    
    return self;
}

@end
