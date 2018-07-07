#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Boid : NSObject

@property (assign) CGPoint position,velocity;
@property (assign) int imageIndex;

-(void)positionReset;

@end
