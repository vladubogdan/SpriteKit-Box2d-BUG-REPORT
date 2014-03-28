//
//  LHScene.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "LHRopeShapeNode.h"


@implementation LHScene

-(void)dealloc{
    
    LH_SAFE_RELEASE(relativePath);
    LH_SAFE_RELEASE(ropeJoints);
    LH_SAFE_RELEASE(loadedTextures);
    LH_SAFE_RELEASE(loadedTextureAtlases);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(supportedDevices);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile]);
}

-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile
{
    NSString* path = [[NSBundle mainBundle] pathForResource:[levelPlistFile stringByDeletingPathExtension]
                                                     ofType:[levelPlistFile pathExtension]];
    if(!path)return nil;
    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!dict)return nil;

    int aspect = [dict intForKey:@"aspect"];
    CGSize designResolution = [dict sizeForKey:@"designResolution"];

    NSArray* devsInfo = [dict objectForKey:@"devices"];
    NSMutableArray* devices = [NSMutableArray array];
    for(NSDictionary* devInf in devsInfo){
        LHDevice* dev = [LHDevice deviceWithDictionary:devInf];
        [devices addObject:dev];
    }
    
    LHDevice* curDev = [LHUtils currentDeviceFromArray:devices];

    CGPoint childrenOffset = CGPointZero;
    
    CGSize sceneSize = curDev.size;
    float ratio = curDev.ratio;
    sceneSize.width = sceneSize.width/ratio;
    sceneSize.height = sceneSize.height/ratio;
    
    SKSceneScaleMode scaleMode = SKSceneScaleModeFill;
    if(aspect == 0)//exact fit
    {
        sceneSize = designResolution;
    }
    else if(aspect == 1)//no borders
    {
        float scalex = sceneSize.width/designResolution.width;
        float scaley = sceneSize.height/designResolution.height;
        scalex = scaley = MAX(scalex, scaley);
        
        childrenOffset.x = (sceneSize.width/scalex - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height/scaley - designResolution.height)*0.5;
        sceneSize = CGSizeMake(sceneSize.width/scalex, sceneSize.height/scaley);
        
        scaleMode = SKSceneScaleModeAspectFill;
    }
    else if(aspect == 2)//show all
    {
        childrenOffset.x = (sceneSize.width - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height - designResolution.height)*0.5;
    }

    if (self = [super initWithSize:sceneSize])
    {
        relativePath = [[NSString alloc] initWithString:[levelPlistFile stringByDeletingLastPathComponent]];
        
        designResolutionSize = designResolution;
        designOffset         = childrenOffset;
        self.scaleMode       = scaleMode;
        

        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }

        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        if([dict boolForKey:@"useGlobalGravity"])
        {
            //more or less the same as box2d
            CGPoint gravityVector = [dict pointForKey:@"globalGravityDirection"];
            float gravityForce    = [dict floatForKey:@"globalGravityForce"];
            [self.physicsWorld setGravity:CGVectorMake(gravityVector.x,
                                                       gravityVector.y*gravityForce)];
//            [self.physicsWorld setSpeed:gravityForce];
        }
        
        [self setBackgroundColor:[dict colorForKey:@"backgroundColor"]];
        
        
        
        //joints should be loaded after all objects have been loaded so that all objects exits
        NSMutableArray* jointsLateLoadingInfo = [NSMutableArray array];
        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        for(NSDictionary* childInfo in childrenInfo)
        {
            NSString* nodeType = [childInfo objectForKey:@"nodeType"];
            
            if([nodeType isEqualToString:@"LHSprite"])
            {
                LHSprite* spr = [LHSprite spriteNodeWithDictionary:childInfo
                                                            parent:self];
                #pragma unused (spr)
            }
            else if([nodeType isEqualToString:@"LHRopeJoint"])
            {
                [jointsLateLoadingInfo addObject:childInfo];
            }
        }
        
        
        
        for(NSDictionary* jointInfo in jointsLateLoadingInfo){
            
            NSString* nodeType = [jointInfo objectForKey:@"nodeType"];
            
            if([nodeType isEqualToString:@"LHRopeJoint"])
            {
                LHRopeShapeNode* jt = [LHRopeShapeNode ropeShapeNodeWithDictionary:jointInfo
                                                                            parent:self];
                if(!ropeJoints){
                    ropeJoints = [[NSMutableArray alloc] init];
                }
                
                [ropeJoints addObject:jt];
            }
        }
        

        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        NSDictionary* phyBoundInfo = [dict objectForKey:@"physicsBoundaries"];
        if(phyBoundInfo)
        {
            CGSize scr = LH_SCREEN_RESOLUTION;
            NSString* rectInf = [phyBoundInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
            if(!rectInf){
                rectInf = [phyBoundInfo objectForKey:@"general"];
            }
            
            if(rectInf){
                CGRect bRect = CGRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];
                CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
                                            (1.0f - bRect.origin.y)*designSize.height + offset.y,
                                            bRect.size.width*designSize.width ,
                                            -(bRect.size.height)*designSize.height);
                
                self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:skBRect];
                self.physicsBody.dynamic = NO;
#ifdef LH_DEBUG
                SKShapeNode* debugShapeNode = [SKShapeNode node];
                debugShapeNode.path = CGPathCreateWithRect(skBRect,
                                                           nil);
                debugShapeNode.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                [self addChild:debugShapeNode];
#endif
            }
        }
    }
    return self;
}

-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath
{
    if(!loadedTextureAtlases){
        loadedTextureAtlases = [[NSMutableDictionary alloc] init];
    }
 
    SKTextureAtlas* textureAtlas = nil;
    if(atlasPath){
        textureAtlas = [loadedTextureAtlases objectForKey:atlasPath];
        if(!textureAtlas){
            textureAtlas = [SKTextureAtlas atlasNamed:atlasPath];
            if(textureAtlas){
                [loadedTextureAtlases setObject:textureAtlas forKey:atlasPath];
            }
        }
    }
    
    return textureAtlas;
}

-(SKTexture*)textureWithImagePath:(NSString*)imagePath
{
    if(!loadedTextures){
        loadedTextures = [[NSMutableDictionary alloc] init];
    }
    
    SKTexture* texture = nil;
    if(imagePath){
        texture = [loadedTextures objectForKey:imagePath];
        if(!texture){
            texture = [SKTexture textureWithImageNamed:imagePath];
            if(texture){
                [loadedTextures setObject:texture forKey:imagePath];
            }
        }
    }
    
    return texture;
}

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)removeRopeShapeNode:(LHRopeShapeNode*)node{
    [ropeJoints removeObject:node];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        ropeJointsCutStartPt = location;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        for(LHRopeShapeNode* rope in ropeJoints){
            if([rope canBeCut]){
                [rope cutWithLineFromPointA:ropeJointsCutStartPt
                                   toPointB:location];
            }
        }
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
}


-(NSString*)currentDeviceSuffix{
    
    CGSize scrSize = LH_SCREEN_RESOLUTION;
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            NSString* suffix = [dev suffix];
            suffix = [suffix stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
            return suffix;
        }
    }
    return @"";
}
-(float)currentDeviceRatio{
    CGSize scrSize = LH_SCREEN_RESOLUTION;
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            return [dev ratio];
        }
    }
    return 1.0f;
}

-(CGSize)designResolutionSize{
    return designResolutionSize;
}
-(CGPoint)designOffset{
    return designOffset;
}

-(NSString*)relativePath{
    return relativePath;
}

-(SKNode*)childNodeWithUUID:(NSString*)uuid{
    for(SKNode* node in [self children])
    {
        if([node respondsToSelector:@selector(uuid)]){
            NSString* nodeUUID = [node performSelector:@selector(uuid)];
            if(nodeUUID && [nodeUUID isEqualToString:uuid]){
                return node;
            }
            
            if([node respondsToSelector:@selector(childNodeWithUUID:)])
            {
                SKNode* retNode = [node performSelector:@selector(childNodeWithUUID:) withObject:uuid];
                if(retNode){
                    return retNode;
                }
            }
        }
    }
    return nil;
}

- (void)update:(NSTimeInterval)currentTime{
    for(LHRopeShapeNode* jt in ropeJoints){
        [jt update:currentTime];
    }
}
@end
