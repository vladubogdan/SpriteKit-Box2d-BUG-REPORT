SpriteKit-Box2d-BUG-REPORT
==========================

This repository demonstrate a very hard to reproduce bug in Box2d and Apple SpriteKit.

This bug was submited to Apple with id 16454959

Please look at file LHSceneSubclass.m at line 51 method -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

Because the blue and green robots have physicsBody with categoryBitMask and collisionBitMask setup so that they wont collide with each other
and because in this setup the robots are on top of each other, when we try to make one of the touched robots into a static body
Box2d will assert as you see below.


Cannot find executable for CFBundle 0x98e25c0 </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.1.sdk/System/Library/AccessibilityBundles/CertUIFramework.axbundle> (not loaded)
Assertion failed: (typeA == b2_dynamicBody || typeB == b2_dynamicBody), function SolveTOI, file /SourceCache/PhysicsKit_Sim/PhysicsKit-6.5.4/PhysicsKit/Box2D/Dynamics/b2World.cpp, line 678.



Looking at the Box2d source code we can see that this assert is related to the fact that we cannot have a dynamic body on top of a static body.
So while i consider this is a box2d bug, SpriteKit own implementation should handle this. 
The SolveTOI function should not assert if the collision mask is set so that the bodies wont collide. 
This is something that is not checked in the SolveTOI function.

