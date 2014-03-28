//
//  LHSprite.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "LHNodeProtocol.h"

@interface LHSprite : SKSpriteNode <LHNodeProtocol>
{
    NSString* _uuid;
}

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt;

-(NSString*)uuid;

@end
