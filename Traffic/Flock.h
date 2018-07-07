#import <Foundation/Foundation.h>
#import "Boid.h"

enum { 
    MAX_BOIDS = 30,
    NUM_OBSTACLES = 3,
};

@interface Flock : NSObject {
    Boid *boids[MAX_BOIDS];
    CGPoint target;
}

-(void)reset;
-(void)update;
-(void)draw;

@end

extern CGPoint obstacle[NUM_OBSTACLES];
extern float targetDeltaAngle;

