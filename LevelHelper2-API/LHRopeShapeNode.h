//
//  LHRopeShapeNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 27/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LHRopeShapeNode : SKShapeNode
{
    NSString* _uuid;
    
    SKPhysicsJointLimit* joint;
    SKShapeNode* debugShapeNode;

    CGPoint relativePosA;
    CGPoint relativePosB;
    
    int segments;
    float thickness;

    CGRect colorInfo;
    BOOL canBeCut;
    BOOL removeAfterCut;
    float fadeOutDelay;
    
    SKShapeNode* ropeShape;//nil if drawing is not enabled
    
    SKNode* nodeA;
    SKNode* nodeB;

    
    SKShapeNode* debugCutAShapeNode;
    SKPhysicsJointLimit* cutJointA;
    SKShapeNode* debugCutBShapeNode;
    SKPhysicsJointLimit* cutJointB;
    
    SKShapeNode* cutShapeNodeA;//nil if drawing is not enabled
    SKShapeNode* cutShapeNodeB;//nil if drawing is not enabled
    
    float cutJointALength;
    float cutJointBLength;
    NSTimeInterval cutTimer;
    BOOL wasCutAndDestroyed;
}
+(instancetype)ropeShapeNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;

- (void)update:(NSTimeInterval)currentTime;

-(NSString*)uuid;

-(CGPoint)anchorA;
-(CGPoint)anchorB;

-(BOOL)canBeCut;

-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB;

@end
