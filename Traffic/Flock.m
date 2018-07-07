#import "quartzView.h"
#import "Flock.h"

CGPoint obstacle[NUM_OBSTACLES];

float targetWeight   = 10;
float neighborWeight = 20;
float obstacleWeight = 100;

float birdStayAwayDistance = 50;
float obstacleStayAwayDistance = 90;
float targetDeltaAngle = 0.03;

@implementation Flock

-(id)init {
    self = [super init];
    
    for(int i=0;i<MAX_BOIDS;++i) 
        boids[i] = [[Boid alloc]init];
    
    CGPoint o1 = { XCENTER-100,YCENTER-100 };   obstacle[0]= o1;    
    CGPoint o2 = { XCENTER+100,YCENTER-100 };   obstacle[1]= o2;    
    CGPoint o3 = { XCENTER,YCENTER+100 };       obstacle[2]= o3;
    
    return self;
}

-(void)reset {
    for(int i=0;i<MAX_BOIDS;++i) 
        [boids[i] positionReset];
}

// MARK: ======================== draw

-(void)drawObstacles {
    CGPoint pt;

    for(int i=0;i<NUM_OBSTACLES;++i) {
        pt.x = obstacle[i].x - OBSTACLE_SIZE/2;
        pt.y = obstacle[i].y - OBSTACLE_SIZE/2;
        
        CGContextDrawLayerAtPoint(context, pt,zLayer[IMAGE_OBSTACLE]);
    }
}

-(void)drawTarget {
	CGPoint pt;
	pt.x = target.x - TARGET_SIZE/2;
	pt.y = target.y - TARGET_SIZE/2;
    
	CGContextDrawLayerAtPoint(context, pt,zLayer[IMAGE_TARGET]);
}

-(void)drawBoids {
    CGPoint pt;
    
    for(int i=0;i<MAX_BOIDS;++i) {
        pt.x = boids[i].position.x - BIRD_SIZE/2;
        pt.y = boids[i].position.y - BIRD_SIZE/2;
        
        float tx = pt.x + BIRD_SIZE/2;
        float ty = pt.y + BIRD_SIZE/2;
        float angle = atan2(boids[i].velocity.y,boids[i].velocity.x) + 2.5;
        
        CGContextSaveGState(context);
        
            CGContextTranslateCTM(context,tx,ty);
            CGContextRotateCTM(context,angle);
            CGContextTranslateCTM(context,-tx,-ty);
            
            CGContextDrawLayerAtPoint(context, pt,zLayer[IMAGE_BIRD1 + boids[i].imageIndex]);

        CGContextRestoreGState(context);
    }
}

-(void)draw {	
    static CGSize sz = { 3,3 };
	CGContextSetShadow(context,sz,1);	

    [self drawTarget];    
    [self drawObstacles];
    [self drawBoids];
}

// MARK: ======================== updateTarget

float targetAngle;
float targetxs = 400;
float targetys = 400;

-(void)updateTarget {
    target.x = XCENTER + cosf(targetAngle) * targetxs;
    target.y = YCENTER + sinf(targetAngle) * targetys;
    
    targetAngle += targetDeltaAngle;
    if(targetAngle > M_PI*2) targetAngle -= M_PI*2;
}

// MARK: ======================== updateBoid

CGPoint newPos;

-(float)vectorDistance :(CGPoint)v1 :(CGPoint)v2 {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    return sqrtf(dx*dx + dy*dy);
}

-(void)vectorAngleWeight :(CGPoint)v1 :(CGPoint)v2 :(float)weight {
    float angle = atan2(v2.y - v1.y,v2.x - v1.x);
    newPos.x += cosf(angle) * weight;
    newPos.y += sinf(angle) * weight;
}

-(void)updateBoid :(int)index {
    Boid *b = boids[index];
    float dist,ratio;
    
    newPos = b.position;
    
    // move toward target
    [self vectorAngleWeight:b.position:target:targetWeight];
    
    // move away from obstacles
    for(int i=0;i<NUM_OBSTACLES;++i) {
        dist = [self vectorDistance:b.position:obstacle[i]];
        if(dist < obstacleStayAwayDistance) {
            ratio = logf(dist * 5.0);
            if(ratio < 1) ratio = 1;
            [self vectorAngleWeight:b.position:obstacle[i]:-obstacleWeight / ratio];
        }
    }
    
    // move away from other boids
    for(int i=0;i<MAX_BOIDS;++i) {
        if(i == index) continue;
        dist = [self vectorDistance:b.position:boids[i].position];
        if(dist < birdStayAwayDistance) {
            ratio = logf(dist * 5.0);
            if(ratio < 1) ratio = 1;
            [self vectorAngleWeight:b.position:boids[i].position:-neighborWeight / ratio];
        }
    }
    
    // newVel = new dx,dy
    CGPoint newVel;
    newVel.x = newPos.x - b.position.x;
    newVel.y = newPos.y - b.position.y;
    
    // smooth dx,dy changes
    newVel.x = (b.velocity.x * 5 + newVel.x)/6.0;
    newVel.y = (b.velocity.y * 5 + newVel.y)/6.0;

    // memorize for next cycle
    b.velocity = newVel;
    
    // apply velocity to position
    newPos.x = b.position.x + b.velocity.x;
    newPos.y = b.position.y + b.velocity.y;    
    b.position = newPos;
    
    // flap wings
    if((rand() & 7) < 5) {
        if(++b.imageIndex > 2) b.imageIndex = 0;
    }
}

-(void)update {	
    [self updateTarget];
    
	for(int i=0;i<MAX_BOIDS;++i) 
        [self updateBoid:i];
}

@end
