//
//  TitleScene.h
//  Test7
//
//  Created by OzekiSyunsuke on 12/04/21.
//  Copyright 2012年 2dgames.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InterfaceLayer.h"
#import "AsciiFont.h"
#import "BackTitle.h"

/**
 * タイトル画面
 */
@interface TitleScene : CCScene {
    
    BackTitle*      back;           // 背景
    CCLayer*        baseLayer;      // 描画レイヤー
    InterfaceLayer* interfaceLayer; // 入力受け取り
    AsciiFont*      asciiFont;      // フォント
    AsciiFont*      fontHiScore;    // フォント (ハイスコア)
    AsciiFont*      fontRank;       // フォント (ランク)
    AsciiFont*      fontRankMax;    // フォント (最大ランク)
    
    BOOL            m_bNextScene;   // 次のシーンに進む
    float           m_TouchStartX;  // タッチ開始座標 (X)
    float           m_TouchStartY;  // タッチ開始座標 (Y)
    int             m_RankPrev;     // タッチ前のランク
}

@property (nonatomic, retain)BackTitle*         back;
@property (nonatomic, retain)CCLayer*           baseLayer;
@property (nonatomic, retain)InterfaceLayer*    interfaceLayer;
@property (nonatomic, retain)AsciiFont*         asciiFont;
@property (nonatomic, retain)AsciiFont*         fontHiScore;
@property (nonatomic, retain)AsciiFont*         fontRank;
@property (nonatomic, retain)AsciiFont*         fontRankMax;

+ (TitleScene*)sharedInstance;
+ (void)releaseInstance;

@end
