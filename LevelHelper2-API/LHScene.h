//
//  LHScene.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)


#import "LHSprite.h"

@class LHRopeShapeNode;

@interface LHScene : SKScene <LHNodeProtocol>
{
    NSMutableDictionary* loadedTextures;
    NSMutableDictionary* loadedTextureAtlases;
    NSDictionary* tracedFixtures;

    NSArray* supportedDevices;
    CGSize  designResolutionSize;
    CGPoint designOffset;

    NSString* relativePath;
    
    NSMutableArray* ropeJoints;
    CGPoint ropeJointsCutStartPt;
}

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;

-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath;
-(SKTexture*)textureWithImagePath:(NSString*)imagePath;

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid;

-(NSString*)currentDeviceSuffix;
-(float)currentDeviceRatio;

-(CGSize)designResolutionSize;
-(CGPoint)designOffset;

-(NSString*)relativePath;

-(SKNode*)childNodeWithUUID:(NSString*)uuid;

-(void)removeRopeShapeNode:(LHRopeShapeNode*)node;

@end
