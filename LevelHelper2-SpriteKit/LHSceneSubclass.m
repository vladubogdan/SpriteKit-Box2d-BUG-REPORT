//
//  LHSceneSubclass.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 26/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSceneSubclass.h"

#import "MyScene.h"



@implementation LHSceneSubclass

-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile{
    if(self = [super initWithContentOfFile:levelPlistFile]){
        //initialize your stuff here
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Drag one of the blue or green robots in order to see the crash.";
        myLabel.fontColor = [UIColor purpleColor];
        myLabel.fontSize = 20;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        NSArray* foundNodes = [self nodesAtPoint:location];
        for(SKNode* foundNode in foundNodes)
        {
            if(foundNode.physicsBody){
                touchedNode = foundNode;
                //doing it this way will work
                //oldBodyState = touchedNode.physicsBody.affectedByGravity;
                //touchedNode.physicsBody.affectedByGravity = NO;
                
                //we save the dynamic state of the body in order to revert it back when the touch ends/gets canceled
                oldBodyState = touchedNode.physicsBody.isDynamic;
                touchedNode.physicsBody.dynamic = NO;
                
                /*
                 Because the blue and green robots have physicsBody with categoryBitMask and collisionBitMask setup so that they wont collide with each other
                 and because in this setup the robots are on top of each other, when we try to make one of the touched robots into a static body
                 Box2d will assert as you see below.
                 
                 
                 Cannot find executable for CFBundle 0x98e25c0 </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.1.sdk/System/Library/AccessibilityBundles/CertUIFramework.axbundle> (not loaded)
                 Assertion failed: (typeA == b2_dynamicBody || typeB == b2_dynamicBody), function SolveTOI, file /SourceCache/PhysicsKit_Sim/PhysicsKit-6.5.4/PhysicsKit/Box2D/Dynamics/b2World.cpp, line 678.
                 
                 
                 
                 Looking at the Box2d source code we can see that this assert is related to the fact that we cannot have a dynamic body on top of a static body.
                 So while i consider this is a box2d bug, SpriteKit own implementation should handle this. 
                 The SolveTOI function should not assert if the collision mask is set so that the bodies wont collide. 
                 This is something that is not checked in the SolveTOI function.
                 
                 
                 
                 */
                
                return;
            }
        }
    }
    
    [super touchesBegan:touches withEvent:event];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if(touchedNode && touchedNode.physicsBody){
            [touchedNode setPosition:location];
        }
    }
    
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(touchedNode){
        //touchedNode.physicsBody.affectedByGravity = oldBodyState;
        touchedNode.physicsBody.dynamic = oldBodyState;
        touchedNode = nil;
    }
    
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(touchedNode){
//        touchedNode.physicsBody.affectedByGravity = oldBodyState;
        touchedNode.physicsBody.dynamic = oldBodyState;
        touchedNode = nil;
    }
    
    [super touchesCancelled:touches withEvent:event];
}

@end
