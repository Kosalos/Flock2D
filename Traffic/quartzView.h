#import <UIKit/UIKit.h>

enum {
	XMAX = 768,
	YMAX = 1024,
    XCENTER = XMAX/2,
    YCENTER = YMAX/2,
	
    IMAGE_BIRD1 = 0,
    IMAGE_BIRD2,
    IMAGE_BIRD3,
    IMAGE_TARGET,
    IMAGE_OBSTACLE,
    IMAGE_SKY,
	NUM_IMAGES,
    
	BIRD_SIZE = 32,
    TARGET_SIZE = 20,
    OBSTACLE_SIZE = 44,
};

extern CGImageRef image[NUM_IMAGES];
extern CGLayerRef zLayer[NUM_IMAGES];

extern CGContextRef context;

@interface QuartzView : UIView
@end

