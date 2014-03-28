//
//  LHSceneSubclass.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 26/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScene.h"

@interface LHSceneSubclass : LHScene
{
    SKNode* touchedNode;
    BOOL oldBodyState;
}
@end
