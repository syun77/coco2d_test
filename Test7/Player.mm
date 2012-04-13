//
//  Player.mm
//  Test7
//
//  Created by OzekiSyunsuke on 12/03/30.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import "Player.h"

#import "GameScene.h"

#include "Vec.h"
#import "Exerinya.h"
#import "Enemy.h"
#import "Shot.h"

// ダメージタイマー
static const int TIMER_DAMAGE = 30;

// ダメージ時の移動量
static const float SPEED_DAMAGE = 200;

// 弾の移動量
static const float SPEED_SHOT = 360;


/**
 * 状態
 */
enum eState {
    eState_Standby, // 待機
    eState_Damage,  // ダメージ
};

/**
 * 自機クラスを実装する
 */
@implementation Player

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
    m_Target.Set(self._x, self._y);
    
    [self setTexRect:Exerinya_GetRect(eExerinyaRect_Player1)];
    [self setScale:0.5f];
    [self setSize2:32];
    
    m_State = eState_Standby;
    m_Timer = 0;
    m_tPast = 0;
    m_ShotRot = 0.0f;
    m_tShot = 0;
    m_tShot2 = 0;
    m_tDamage = 0;
    
    return self;
}

// 移動開始座標を設定
- (void)setStartPos:(float)x y:(float)y {
    m_Start.x = self._x;
    m_Start.y = self._y;
    
    if (m_State == eState_Damage) {
        
        // ダメージ中だったら待機状態に戻す
        m_State = eState_Standby;
    }
}

/**
 * 移動量を画面内に収める
 */
- (void)clipScreen:(Vec2D*)v {
    
    float s = self._r;
    float x1 = s;
    float y1 = s;
    float x2 = System_Width() - s;
    float y2 = System_Height() - s;
    
    if (v->x < x1) {
        v->x = x1;
    }
    if (v->x > x2) {
        v->x = x2;
    }
    if (v->y < y1) {
        v->y = y1;
    }
    if (v->y > y2) {
        v->y = y2;
    }
    
}

/**
 * タッチしているかどうか
 */
- (BOOL)isTouch {
    GameScene* scene = [GameScene sharedInstance];
    return [scene.interfaceLayer isTouch];
}

/**
 * 弾を撃つ
 */
- (void)checkShot {
    if ([self isTouch] == NO) {
        // タッチしていない
        // ショットタイマー更新
        if (m_tShot > 0) {
            m_tShot--;
        }
        if (m_tShot <= 0) {
            // 弾を撃つ
            [self shot];
            m_tShot2++;
            if (m_tShot2 > 3) {
                m_tShot = SHOT_TIMER;
                m_tShot2 = 0;
            }
        }
    }
    else {
        m_tShot = 0;
        m_tShot2 = 0;
    }
}

/**
 * 入力インターフェース受け取り
 */
- (InterfaceLayer*)getInterfaceLayer {
    GameScene* scene = [GameScene sharedInstance];
    return scene.interfaceLayer;
}

/**
 * 更新・待機中
 */
- (void)updateStandby:(ccTime)dt {
    
    // 弾を撃つ
    [self checkShot];
    
    // 移動処理
    if ([self isTouch]) {
        // タッチ中
        InterfaceLayer* input = [self getInterfaceLayer];
        // 移動処理
        float startX = [input startX];
        float startY = [input startY];
        float nowX = [input getPosX];
        float nowY = [input getPosY];
        float dx = nowX - startX;
        float dy = nowY - startY;
        Vec2D v = Vec2D(m_Start.x + dx, m_Start.y + dy);
        [self clipScreen:&v];
        m_Target.Set(v.x, v.y);
    }
    Vec2D vP = Vec2D(self._x, self._y);
    Vec2D vM = m_Target - vP;
    vM *= 10.0f;
    
    self._x += vM.x * dt;
    self._y += vM.y * dt;
    
}

/**
 * 更新・ダメージ中
 */
- (void)updateDamage:(ccTime)dt {
    m_Timer--;
    if (m_Timer < 1) {
        // ダメージ状態終了
        m_State = eState_Standby;
        
        // 移動先を更新
        m_Target.Set(self._x, self._y);
        
    }
    
}

/**
 * 更新・アニメ
 */
- (void)updateAnime {
    // アニメーション更新
    if (m_tPast%64 / 32) {
        [self setTexRect:Exerinya_GetRect(eExerinyaRect_Player1)];
    }
    else {
        [self setTexRect:Exerinya_GetRect(eExerinyaRect_Player2)];
    }
    
    if (m_tDamage > 0) {
        // ダメージ中画像
        [self setTexRect:Exerinya_GetRect(eExerinyaRect_PlayerDamage)];
    }
    
}

/**
 * 更新
 */
- (void)update:(ccTime)dt {
    
    // タイマー更新
    m_tPast++;
    if (m_tDamage > 0) {
        m_tDamage--;
    }
    
    // 移動
    self._vx *= 0.95f;
    self._vy *= 0.95f;
    [self move:dt];
    Vec2D v = Vec2D(self._x, self._y);
    [self clipScreen:&v];
    self._x = v.x;
    self._y = v.y;
    
    // 背景を動かす
    GameScene* scene = [GameScene sharedInstance];
    [scene.back setTarget:self._x y:self._y];
    
    // 各種更新
    switch (m_State) {
        case eState_Standby:
            [self updateStandby:dt];
            break;
        
        case eState_Damage:
            [self updateDamage:dt];
            break;
            
        default:
            break;
    }
    
    // アニメーション更新
    [self updateAnime];
}

// 弾を撃つ
- (void)shot {
    
    // 一番近い敵を探す
    Enemy* e = [Enemy getNearest:_x y:_y];
    if (e) {
        float dx = e._x - self._x;
        float dy = e._y - self._y;
        m_ShotRot = Math_Atan2Ex(dy, dx);
    }
    
    // 弾を撃つ
    [Shot add:self._x y:self._y rot:m_ShotRot speed:SPEED_SHOT];
    
    
}

// ダメージ
- (void)damage:(Token*)t {
    m_tDamage = TIMER_DAMAGE;
    m_Timer = TIMER_DAMAGE;
    m_State = eState_Damage;
    
    Vec2D d = Vec2D(self._x - t._x, self._y - t._y);
    d.Normalize();
    d *= SPEED_DAMAGE;
    self._vx = d.x;
    self._vy = d.y;
}

@end
