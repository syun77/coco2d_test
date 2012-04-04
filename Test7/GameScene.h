//
//  GameScene.h
//  Test7
//
//  Created by OzekiSyunsuke on 12/03/22.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "InterfaceLayer.h"
#import "TokenManager.h"
#import "Back.h"
#import "Player.h"
#import "AsciiFont.h"

/**
 * ゲームシーン
 */
@interface GameScene : CCScene {
    CCLayer*        baesLayer;      // 描画レイヤー
    Back*           back;           // 背景画像
    Player*         player;         // プレイヤー
    TokenManager*   mgrBullet;      // 敵弾
    TokenManager*   mgrParticle;    // パーティクル
    InterfaceLayer* interfaceLayer; // 入力受け取り
    AsciiFont*      ascciFont;      // フォント
    AsciiFont*      ascciFont2;     // フォント
}

@property (nonatomic, retain)CCLayer*           baseLayer;
@property (nonatomic, retain)Back*              back;
@property (nonatomic, retain)Player*            player;
@property (nonatomic, retain)TokenManager*      mgrBullet;
@property (nonatomic, retain)TokenManager*      mgrParticle;
@property (nonatomic, retain)InterfaceLayer*    interfaceLayer;
@property (nonatomic, retain)AsciiFont*         asciiFont;
@property (nonatomic, retain)AsciiFont*         asciiFont2;

// シングルトンを取得
+ (GameScene*)sharedInstance;

@end
