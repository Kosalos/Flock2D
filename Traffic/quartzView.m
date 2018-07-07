#import <QuartzCore/QuartzCore.h>
#import "quartzView.h"
#import "ViewController.h"
#import "Flock.h"

CGImageRef image[NUM_IMAGES];
CGLayerRef zLayer[NUM_IMAGES];
CGContextRef context;

Flock *hk = nil;

@implementation QuartzView

-(void)InitLayer :(CGLayerRef*)dest :(CGImageRef)image :(int)xs :(int)ys {
	static CGSize sz;
	static CGRect rect = { 0,0,0,0 };
    
    sz.width = rect.size.width = xs;
    sz.height = rect.size.height = ys;
    
	*dest = CGLayerCreateWithContext(context,sz,NULL);
	
	CGContextRef ref = CGLayerGetContext(*dest);
    
    CGContextTranslateCTM(ref,0,ys);
    CGContextScaleCTM(ref, 1.0, -1.0);

	CGContextDrawImage(ref,rect,image);	
}

-(void)loadImage :(int)index :(NSString *)filename :(int)xs :(int)ys {
    image[index] = CGImageRetain([UIImage imageNamed:filename].CGImage);
    [self InitLayer:&zLayer[index]:image[index]:xs:ys];
}

// MARK: ======================== sky

#define SKY_OFFSET 200

-(void)drawSky {
    static CGPoint skyPt = { 0,0 };
    static float skyAngle = 0;

    CGContextDrawLayerAtPoint(context,skyPt,zLayer[IMAGE_SKY]);
    skyPt.x = -SKY_OFFSET + cosf(skyAngle) * SKY_OFFSET;
    skyPt.y = -SKY_OFFSET + sinf(skyAngle) * SKY_OFFSET;
    skyAngle += 0.003;
}

// MARK: ======================== heartBeatTimer

-(void)heartBeatTimer {
    [hk update];
	[self setNeedsDisplay];
}

// MARK:  ======================== draw

CADisplayLink *displayLink;

-(void)drawRect :(CGRect)rect {
	context = UIGraphicsGetCurrentContext();	
    
	static bool first = true;
	if(first) {
		first = false;
        
        hk = [[Flock alloc]init];
        
        [self loadImage:IMAGE_BIRD1:    @"bird.png":    BIRD_SIZE:BIRD_SIZE];
        [self loadImage:IMAGE_BIRD2:    @"bird2.png":   BIRD_SIZE:BIRD_SIZE];
        [self loadImage:IMAGE_BIRD3:    @"bird3.png":   BIRD_SIZE:BIRD_SIZE];
        [self loadImage:IMAGE_TARGET:   @"fifteenD.png":TARGET_SIZE:TARGET_SIZE];
        [self loadImage:IMAGE_OBSTACLE: @"fifteen2.png":OBSTACLE_SIZE:OBSTACLE_SIZE];
        [self loadImage:IMAGE_SKY:      @"sky.png":     XMAX+SKY_OFFSET*2:YMAX+SKY_OFFSET*2];
        
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(heartBeatTimer)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}	
    
    [self drawSky]; 
    [hk draw];
}

// MARK: ======================== touch

int oIndex= -1;

-(void)touchesBegan :(NSSet *)touches withEvent :(UIEvent *)event {
	UITouch *touch = [touches anyObject];	
	CGPoint pt = [touch locationInView: [touch view]];
    
    if(pt.x < 50 && pt.y < 50) { [hk reset]; return; }
    
    float dist = 99999;
    for(int i=0;i<NUM_OBSTACLES;++i) {
        float dx = pt.x - obstacle[i].x;
        float dy = pt.y - obstacle[i].y;
        float d = dx*dx + dy*dy;
        if(d < dist) {
            dist = d;
            oIndex = i;
        }
    }
    
    obstacle[oIndex] = pt;
}

-(void)touchesMoved :(NSSet *)touches withEvent :(UIEvent *)event {
	UITouch *touch = [touches anyObject];	
	CGPoint pt = [touch locationInView: [touch view]];
    
    obstacle[oIndex] = pt;
}

-(void)touchesEnded :(NSSet *)touches withEvent :(UIEvent *)event {
}

@end
