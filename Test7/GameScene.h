//
//  GameScene.h
//  Test7
//
//  Created by OzekiSyunsuke on 12/03/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "InterfaceLayer.h"
#import "TokenManager.h"

/**
 * ゲームシーン
 */
@interface GameScene : CCScene {
    CCLayer*        baesLayer;
    TokenManager*   mgr;
    TokenManager*   mgrParticle;
    InterfaceLayer* interfaceLayer;
}

@property (nonatomic, retain)CCLayer* baseLayer;
@property (nonatomic, retain)TokenManager*   mgr;
@property (nonatomic, retain)TokenManager*   mgrParticle;
@property (nonatomic, retain)InterfaceLayer* interfaceLayer;

// シングルトンを取得
+ (GameScene*)sharedInstance;

@end
