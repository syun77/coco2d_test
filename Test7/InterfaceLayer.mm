//
//  InterfaceLayer.m
//  Test7
//
//  Created by OzekiSyunsuke on 12/03/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "InterfaceLayer.h"

#import "GameScene.h"

@implementation InterfaceLayer

/**
 * 開始
 */
- (void)onEnter {
    
    // スケジューラ起動
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    // タッチ座標を初期化
    m_isTouch = NO;
    m_X = 0;
    m_Y = 0;
}

/**
 * 終了
 */
- (void)onExit {
    
    // スケジューラ削除
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

/**
 * タッチ開始
 */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint locationView = [touch locationInView:[touch view]];
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationView];
    
    // タッチ座標を設定
    m_X = location.x;
    m_Y = location.y;
    
    // タッチ状態を更新
    m_isTouch = YES;
    
    return YES;
}

/**
 * タッチ座標更新
 */
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint locationView = [touch locationInView:[touch view]];
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationView];
    
    // タッチ座標を設定
    m_X = location.x;
    m_Y = location.y;
}

/**
 * タッチ終了
 */
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // タッチ状態を更新
    m_isTouch = NO;
}

/**
 * タッチキャンセル
 */
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // タッチ状態を更新
    m_isTouch = NO;
}

// タッチしているかどうか
- (BOOL)isTouch {
    return m_isTouch;
}

// タッチしている座標を取得
- (float)getPosX {
    return m_X;
}

- (float)getPosY {
    return m_Y;
}

@end