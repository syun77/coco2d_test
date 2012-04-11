//
//  Back.m
//  Test7
//
//  Created by OzekiSyunsuke on 12/04/04.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import "Back.h"
#import "Exerinya.h"
#import "System.h"

/**
 * 背景トークン実装
 */
@implementation Back

/**
 * 初期化
 */
- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    [self load:@"all-hd.png"];
    
    [self create];
    
    self._x = System_CenterX();
    self._y = SYstem_CenterY();
    [self move:0];
    
    // 背景画像を設定
    [self setTexRect:Exerinya_GetRect(eExerinyaRect_Back)];
    
    // 変数初期化
    m_TargetX = self._x;
    m_TargetY = self._y;
    
    return self;
}

// 移動座標の設定
- (void)setTarget:(float)x y:(float)y {
    
    // 画面の中心からの移動量に対するスクロールの割合
    const float RATIO_X = -0.35;
    const float RATIO_Y = -0.5;
    
    float dx = x - System_CenterX();
    float dy = y - SYstem_CenterY();
    float px = System_CenterX() + (dx * RATIO_X);
    float py = SYstem_CenterY() + (dy * RATIO_Y);
    m_TargetX = px;
    m_TargetY = py;
}

/**
 * 更新
 */
- (void)update:(ccTime)dt {
    float dx = m_TargetX - self._x;
    float dy = m_TargetY - self._y;
    
    self._vx = dx * 30;
    self._vy = dy * 30;
    
    [super move:dt];
}
@end
