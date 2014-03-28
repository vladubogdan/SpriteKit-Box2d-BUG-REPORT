//
//  LHUtils.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"

@implementation LHUtils

+(NSString*)imagePathWithFilename:(NSString*)filename
                           folder:(NSString*)folder
                           suffix:(NSString*)suffix
{
    NSString* ext = [filename pathExtension];
    NSString* fileNoExt = [filename stringByDeletingPathExtension];
    return [[[folder stringByAppendingString:fileNoExt] stringByAppendingString:suffix] stringByAppendingPathExtension:ext];
}

+(NSString*)devicePosition:(NSDictionary*)availablePositions{
    CGSize curScr = LH_SCREEN_RESOLUTION;
    return [availablePositions objectForKey:[NSString stringWithFormat:@"%dx%d", (int)curScr.width, (int)curScr.height]];
}

+(CGPoint)positionForNode:(SKNode*)node
                 fromUnit:(CGPoint)unitPos
{
    LHScene* scene = (LHScene*)[node scene];
    
    CGSize designSize = [scene designResolutionSize];
    CGPoint offset = [scene designOffset];
    
    CGPoint designPos = CGPointZero;
    if([node parent] == scene){
        designPos = CGPointMake(designSize.width*unitPos.x,
                           (designSize.height - designSize.height*unitPos.y));
    }
    else{
        designPos = CGPointMake(designSize.width*unitPos.x,
                           designSize.height*(-unitPos.y));
    }
    
    designPos.x += offset.x;
    designPos.y += offset.y;
    
    return designPos;
}

+(LHDevice*)currentDeviceFromArray:(NSArray*)arrayOfDevs{
    for(LHDevice* dev in arrayOfDevs){
        if(CGSizeEqualToSize([dev size], LH_SCREEN_RESOLUTION))
        {
            return dev;
        }
    }
    return nil;
}
@end


@implementation LHDevice

-(void)dealloc{
    LH_SAFE_RELEASE(suffix);
    LH_SUPER_DEALLOC();
}

+(id)deviceWithDictionary:(NSDictionary*)dict{
    return LH_AUTORELEASED([[LHDevice alloc] initWithDictionary:dict]);
}
-(id)initWithDictionary:(NSDictionary*)dict{
    if(self = [super init]){
        
        size = [dict sizeForKey:@"size"];
        suffix = [[NSString alloc] initWithString:[dict objectForKey:@"suffix"]];
        ratio = [dict floatForKey:@"ratio"];
        
    }
    return self;
}

-(CGSize)size{
    return size;
}
-(NSString*)suffix{
    return suffix;
}
-(float)ratio{
    return ratio;
}

@end
