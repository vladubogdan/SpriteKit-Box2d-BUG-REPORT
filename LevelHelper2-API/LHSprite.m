//
//  LHSprite.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"

@implementation LHSprite

-(void)dealloc{
    LH_SAFE_RELEASE(_uuid);
    LH_SUPER_DEALLOC();
}

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[LHSprite alloc] initSpriteNodeWithDictionary:dict
                                                                   parent:prnt]);
}


- (instancetype)initSpriteNodeWithDictionary:(NSDictionary*)dict
                                      parent:(SKNode*)prnt{

    
    if(self = [super initWithColor:[SKColor whiteColor] size:CGSizeZero]){
        
        [prnt addChild:self];
        
        [self setName:[dict objectForKey:@"name"]];

        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        
        LHScene* scene = (LHScene*)[self scene];
        
        NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                      folder:[dict objectForKey:@"relativeImagePath"]
                                                      suffix:[scene currentDeviceSuffix]];

        SKTexture* texture = nil;
        
        NSString* spriteName = [dict objectForKey:@"spriteName"];
        if(spriteName){
            NSString* atlasName = [[imagePath lastPathComponent] stringByDeletingPathExtension];
            atlasName = [[scene relativePath] stringByAppendingPathComponent:atlasName];
            
            SKTextureAtlas *atlas = [scene textureAtlasWithImagePath:atlasName];
            texture = [atlas textureNamed:spriteName];
        }
        else{
            texture = [scene textureWithImagePath:imagePath];
        }
        
        
        if(texture){
            [self setTexture:texture];
            [self setSize:texture.size];
        }
        
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setXScale:scl.x];
        [self setYScale:scl.y];

        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            NSString* unitPosStr = [LHUtils devicePosition:devPositions];
            if(unitPosStr){
                CGPoint unitPos = CGPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        CGPoint anchor = [dict pointForKey:@"anchor"];
        anchor.y = 1.0f - anchor.y;
        [self setAnchorPoint:anchor];
                
        float alpha = [dict floatForKey:@"alpha"];
        [self setAlpha:alpha/255.0f];
        
        
        float rot = [dict floatForKey:@"rotation"];
        [self setZRotation:LH_DEGREES_TO_RADIANS(-rot)];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZPosition:z];
        
        [self loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"]];

        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
            NSString* nodeType = [childInfo objectForKey:@"nodeType"];
                if([nodeType isEqualToString:@"LHSprite"])
                {
                    LHSprite* spr = [LHSprite spriteNodeWithDictionary:childInfo
                                                                parent:self];
                    #pragma unused (spr)
                }
            }
        }
    }
    return self;
}

-(void)loadPhysicsFromDict:(NSDictionary*)dict{
    
    if(!dict)return;
    
    int shape = [dict intForKey:@"shape"];
    
    NSArray* fixturesInfo = nil;

#ifdef LH_DEBUG
    NSMutableArray* debugShapeNodes = [NSMutableArray array];
#endif
    
    
    if(shape == 0)//RECTANGLE
    {
        CGPoint offset = CGPointMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size
                                                           center:offset];
        
#ifdef LH_DEBUG
        SKShapeNode* debugShapeNode = [SKShapeNode node];
        debugShapeNode.path = CGPathCreateWithRect(CGRectMake(-self.size.width*0.5 + offset.x,
                                                         -self.size.height*0.5 + offset.y,
                                                         self.size.width,
                                                         self.size.height),
                                                       nil);
        
        [debugShapeNodes addObject:debugShapeNode];
#endif
        
    }
    else if(shape == 1)//CIRCLE
    {
        CGPoint offset = CGPointMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width*0.5
                                                          center:offset];
        
#ifdef LH_DEBUG
        SKShapeNode* debugShapeNode = [SKShapeNode node];
        debugShapeNode.path = CGPathCreateWithEllipseInRect(CGRectMake(-self.size.width*0.5 + offset.x,
                                                                  -self.size.width*0.5 + offset.y,
                                                                  self.size.width,
                                                                  self.size.width),
                                                       nil);
        [debugShapeNodes addObject:debugShapeNode];
#endif
    }
    else if(shape == 3)//CHAIN
    {
        CGPoint offset = CGPointMake(0, 0);
        CGRect rect = CGRectMake(-self.size.width*0.5 + offset.x,
                                 -self.size.height*0.5 + offset.y,
                                 self.size.width,
                                 self.size.height);
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
#ifdef LH_DEBUG
        SKShapeNode* debugShapeNode = [SKShapeNode node];
        debugShapeNode.path = CGPathCreateWithRect(rect,
                                              nil);
        [debugShapeNodes addObject:debugShapeNode];
#endif
    }
    else if(shape == 4)//OVAL
    {
        fixturesInfo = [dict objectForKey:@"ovalShape"];
    }
    else if(shape == 5)//TRACED
    {
        NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];        
        LHScene* scene = (LHScene*)[self scene];
        fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
    }
    
    
    
    if(fixturesInfo)
    {
        NSMutableArray* fixBodies = [NSMutableArray array];
        
        for(NSArray* fixPoints in fixturesInfo)
        {
            int count = (int)[fixPoints count];
            CGPoint points[count];
            
            int i = count - 1;
            for(int j = 0; j< count; ++j)
            {
                NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                CGPoint point = CGPointFromString(pointStr);
                
                //flip y for sprite kit coordinate system
                point.y =  self.size.height - point.y;
                point.y = point.y - self.size.height;
                
                
                points[j] = point;
                i = i-1;
            }
            
            CGMutablePathRef fixPath = CGPathCreateMutable();
            
            bool first = true;
            for(int k = 0; k < count; ++k)
            {
                CGPoint point = points[k];
                if(first){
                    CGPathMoveToPoint(fixPath, nil, point.x, point.y);
                }
                else{
                    CGPathAddLineToPoint(fixPath, nil, point.x, point.y);
                }
                first = false;
            }
            
            CGPathCloseSubpath(fixPath);
            
#ifdef LH_DEBUG
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            debugShapeNode.path = fixPath;
            [debugShapeNodes addObject:debugShapeNode];
#endif
            
            [fixBodies addObject:[SKPhysicsBody bodyWithPolygonFromPath:fixPath]];
            
            CGPathRelease(fixPath);
        }
        self.physicsBody = [SKPhysicsBody bodyWithBodies:fixBodies];
    }
    
    
    int type = [dict intForKey:@"type"];
    if(type == 0)//static
    {
        [self.physicsBody setDynamic:NO];
    }
    else if(type == 1)//kinematic
    {
    }
    else if(type == 2)//dynamic
    {
        [self.physicsBody setDynamic:YES];
    }
    
    
    NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
    if(fixInfo && self.physicsBody)
    {
        self.physicsBody.categoryBitMask = [fixInfo intForKey:@"category"];
        self.physicsBody.collisionBitMask = [fixInfo intForKey:@"mask"];
        
        self.physicsBody.density = [fixInfo floatForKey:@"density"];
        self.physicsBody.friction = [fixInfo floatForKey:@"friction"];
        self.physicsBody.restitution = [fixInfo floatForKey:@"restitution"];
        
        self.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
        self.physicsBody.usesPreciseCollisionDetection = [dict boolForKey:@"bullet"];
        
        if([dict intForKey:@"gravityScale"] == 0){
            self.physicsBody.affectedByGravity = NO;
        }
    }
    
    
#ifdef LH_DEBUG
    for(SKShapeNode* debugShapeNode in debugShapeNodes)
    {
        debugShapeNode.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
        debugShapeNode.fillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.1];
        debugShapeNode.lineWidth = 0.1;
        if(self.physicsBody.isDynamic){
            debugShapeNode.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
            debugShapeNode.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
        }
        [self addChild:debugShapeNode];
    }
#endif

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
                SKNode* retNode = [node performSelector:@selector(childNodeWithUUID:)
                                             withObject:uuid];
                if(retNode){
                    return retNode;
                }
            }
        }
    }
    return nil;
}

-(NSString*)uuid{
    return _uuid;
}
@end
