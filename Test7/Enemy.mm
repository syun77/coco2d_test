//
//  Enemy.mm
//  Test7
//
//  Created by OzekiSyunsuke on 12/04/04.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import "Enemy.h"

#import "Exerinya.h"
#import "GameScene.h"
#import "Particle.h"
#import "Bullet.h"

enum eState {
    eState_Appear,  // 出現
    eState_Main,    // メイン
    eState_Escape,  // 逃走
};

/**
 * 敵の実装
 */
@implementation Enemy

/**
 * コンストラクタ
 */
- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    [self load:@"all.png"];
    
    return self;
    
}

/**
 * 初期化
 */
- (void)initialize {
    [self setRotation:0];
    [self setScale:1];
    
    [self setScale:0.5];
    
    [self setSize2:32];
    
    m_Val = Math_Rand(360);
    m_Timer = 0;
    m_Hp    = 3;
    m_State = eState_Appear;
    
}

/**
 * 目標の相手を取得する
 */
- (Player*)getTarget {
    GameScene* scene = [GameScene sharedInstance];
    return scene.player;
}

/**
 * 敵種別の設定
 */
- (void)setType:(eEnemy)type {
    m_Id = type;
    
    switch (type) {
        case eEnemy_Nasu:    // ナス
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Nasu)];
            self._r = 16;
            m_HpMax = 3;
            break;
            
        case eEnemy_Tako:    // たこ焼き
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Tako)];
            self._r = 16;
            m_HpMax = 3;
            break;
            
        case eEnemy_5Box:    // ５箱
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_5Box)];
            self._r = 16;
            m_HpMax = 3;
            break;
            
        case eEnemy_Pudding: // プリン
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Pudding)];
            self._r = 48;
            m_HpMax = 50;
            break;
            
        case eEnemy_Milk:    // 牛乳
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Milk)];
            self._r = 48;
            m_HpMax = 3;
            break;
            
        case eEnemy_XBox:    // XBox
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_XBox)];
            self._r = 48;
            m_HpMax = 3;
            break;
            
        case eEnemy_Radish:  // 大根
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Radish)];
            self._r = 8;
            m_HpMax = 3;
            break;
            
        case eEnemy_Carrot:  // 人参
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Carrot)];
            self._r = 8;
            m_HpMax = 3;
            break;
            
        case eEnemy_Pokey:   // ポッキー
            [self setTexRect: Exerinya_GetRect(eExerinyaRect_Pokey)];
            self._r = 8;
            m_HpMax = 3;
            m_Timer = 300;
            break;
            
        default:
            break;
    }
    
    // HPを設定する
    m_Hp = m_HpMax;
}

/**
 * 敵の生成
 */

+ (Enemy*)add:(eEnemy)type x:(float)x y:(float)y rot:(float)rot speed:(float)speed {
    GameScene* scene = [GameScene sharedInstance];
    Enemy* e = (Enemy*)[scene.mgrEnemy add];
    if (e) {
        [e set2:x y:y rot:rot speed:speed ax:0 ay:0];
        [e setType:type];
    }
    
    return e;
}

/**
 * 狙い撃ち角度を取得する
 */
- (float)getAim {
    Player* p = [self getTarget];
    
    float dx = p._x - self._x;
    float dy = p._y - self._y;
    
    return Math_Atan2Ex(dy, dx);
}

/**
 * 指定の座標に一番近い敵を探す
 */
+ (Enemy*)getNearest:(float)x y:(float)y {
    Enemy* ret = nil;
    
    GameScene* scene = [GameScene sharedInstance];
    TokenManager* mgr = scene.mgrEnemy;
    
    float len = 9999999;
    for (Enemy* e in mgr.m_Pool) {
        if ([e isExist] == NO) {
            // 存在しない
            continue;
        }
        
        if ([e isOutCircle:0]) {
            // 画面外の敵は昇順をあわせない
            continue;
        }
        
        Vec2D d = Vec2D(e._x - x, e._y - y);
        float len2 = d.LengthSq();
        if (len2 < len) {
            ret = e;
            len = len2;
        }
    }
    
    return ret;
}

/**
 * 登場時の移動量を設定
 */
- (void)moveAppear:(float)speed radius:(float)radius {
    if ([self isOutCircle:-radius]) {
        // 画面外の場合、画面内に入ろうとする
        float dx = System_CenterX() - self._x;
        float dy = System_CenterY() - self._y;
        if (abs(dx) > abs(dy)) {
            if (dx > 0) {
                self._vx = speed;
            }
            else {
                self._vx = -speed;
            }
        }
        else {
            if (dy > 0) {
                self._vy = speed;
            }
            else {
                self._vy = -speed;
            }
        }
    }
    
}

/**
 * 更新・ナス
 */
- (void)updateNasu {
    const float speedIn  = 100; // 画面に入る速度
    const float speedMove = 50; // 移動速度
    m_Timer++;
    if (m_Timer < 200) {
        // 登場シーケンス
        [self moveAppear:speedIn radius:self._r];
    }
    else if ([self isOutCircle:self._r]) {
        // 画面外に出たら消える
        [self vanish];
        return;
    }
    else if (m_Timer > 2000) {
        // 退場シーケンス
        // プレイヤーを逆方向に移動する
        float aim = [self getAim];
        float dx = Math_CosEx(aim) * -speedMove;
        float dy = -Math_SinEx(aim) * -speedMove;
        self._vx = dx;
        self._vy = dy;
    }
    else if (m_Timer%320 < 160) {
        // 移動シーケンス
        float dx = Math_CosEx(m_Timer) * speedMove;
        float dy = Math_SinEx(m_Timer) * speedMove;
        self._vx = dx;
        self._vy = dy;
        if (m_Timer%320 == 10) {
            // 弾を打つ
            float rot = [self getAim];
            [Bullet add:self._x y:self._y rot:rot speed:100];
        }
        
    }
    
    self._vx *= 0.9f;
    self._vy *= 0.9f;
    
    
    [self setRotation:Math_SinEx(m_Timer + m_Val) * 15];
}

/**
 * 更新・タコ
 */
- (void)updateTako {
    const float speedIn  = 100; // 画面に入る速度
    const float speedMove = 500; // 移動速度
    m_Timer++;
    if (m_Timer < 40) {
        // 登場シーケンス
        [self moveAppear:speedIn radius:self._r];
    }
    else if ([self isOutCircle:self._r]) {
        // 画面外に出たら消える
        [self vanish];
        return;
    }
    else if (m_Timer%200 == 0) {
        // 移動シーケンス
        // プレイヤーに向かって移動する
        float aim = [self getAim];
        float dx = Math_CosEx(aim) * speedMove;
        float dy = Math_SinEx(aim) * speedMove;
        self._vx = dx;
        self._vy = dy;
        
    }
    else if(m_Timer%200 > 0) {
        int t = m_Timer%200;
        self.rotation = self.rotation + t * 0.1;
    }
    
    self._vx *= 0.95f;
    self._vy *= 0.95f;
    
}

/**
 * 更新・5箱
 */
- (void)update5Box {
    
}

/**
 * 更新・牛乳
 */
- (void)updateMilk {
    
}

/**
 * 更新・プリン
 */
- (void)updatePudding {
    
    const float speedIn  = 100; // 画面に入る速度
    const float speedMove = 150; // 移動速度
    
    switch (m_State) {
        case eState_Appear:
            // 登場シーケンス
            m_Timer++;
            [self moveAppear:speedIn radius:self._r];
            if ([self isOutCircle:-self._r] == NO || m_Timer > 200) {
                m_Timer = 0;
                m_State = eState_Main;
                // プレイヤーに向かって移動する
                float aim = [self getAim];
                float dx = Math_CosEx(aim) * speedMove;
                float dy = -Math_SinEx(aim) * speedMove;
                self._vx = dx;
                self._vy = dy;
            }
            self._vx *= 0.5f;
            self._vy *= 0.5f;
            break;
            
        case eState_Main:
            m_Timer++;
            if (Math_Rand(100) == 0) {
                m_Timer += 10;
            }
            if (m_Timer%180 == 11) {
                // 移動シーケンス
                // プレイヤーから直角に移動する
                float deg1 = Math_RandInt(-1, 1) * 90;
                float deg2 = Math_RandInt(-1, 1) * 90;
                
                float aim = [self getAim];
                float dx = Math_CosEx(aim + deg1) * speedMove;
                float dy = -Math_SinEx(aim + deg2) * speedMove;
                self._vx = dx;
                self._vy = dy;
                
                // 弾を打つ
                [Bullet add:self._x y:self._y rot:aim speed:100];
                
                // ポッキー発射
                float speed = 400;
                int cnt = 5;
                float rot = 180 + aim + (cnt / 2) * - 45;
                for (int i = 0; i < cnt; i++) {
                    [Enemy add:eEnemy_Pokey x:self._x y:self._y rot:rot speed:speed];
                    rot += 45;
                }
                
            }
            if([self isBoundRectX:self._r])
            {
                self._vx = -self._vx * 0.8;
            }
            if([self isBoundRectY:self._r])
            {
                self._vy = -self._vy * 0.8;
            }
            self._vx *= 0.95f;
            self._vy *= 0.95f;
            break;
            
        default:
            break;
    }
    
}

/**
 * 更新・XBox
 */
- (void)updateXBox {
    
}

/**
 * 更新・ポッキー
 */
- (void)updatePokey {
    const float SPEED = 300;
    
    switch (m_State) {
        case eState_Appear:
            m_Timer = m_Timer * 0.97;
            self._vx *= 0.9f;
            self._vy *= 0.9f;
            [self setRotation:m_Timer*4];
            if (m_Timer == 0) {
                m_State = eState_Main;
                float aim = [self getAim];
                
                [Bullet add:self._x y:self._y rot:aim speed:100];
                
                float dx = Math_CosEx(aim) * SPEED;
                float dy = Math_SinEx(aim) * SPEED;
                
                self._vx = dx;
                self._vy = dy;
                
                [self setRotation:Math_Atan2Ex(-dy, dx)];
            }
            break;
            
        default:
            break;
    }
    
    if ([self isOutCircle:self._r]) {
        // 画面外に出たら消える
        [self vanish];
    }
}

/**
 * 更新・だいこん
 */
- (void)updateRadish {
    
    if ([self isOutCircle:self._r]) {
        // 画面外に出たら消える
        [self vanish];
    }
}

/**
 * 更新・にんじん
 */
- (void)updateCarrot {
    
    if ([self isOutCircle:self._r]) {
        // 画面外に出たら消える
        [self vanish];
    }
}

/**
 * 更新
 */
- (void)update:(ccTime)dt {
    [self move:dt];
    
    switch (m_Id) {
        case eEnemy_Nasu:
            [self updateNasu];
            break;
            
        case eEnemy_Tako:
            [self updateTako];
            break;
            
        case eEnemy_5Box:
            [self update5Box];
            break;
            
        case eEnemy_Milk:
            [self updateMilk];
            break;
            
        case eEnemy_Pudding:
            [self updatePudding];
            break;
            
        case eEnemy_XBox:
            [self updateXBox];
            break;
            
        case eEnemy_Pokey:
            [self updatePokey];
            break;
            
        case eEnemy_Carrot:
            [self updateCarrot];
            break;
            
        case eEnemy_Radish:
            [self updateRadish];
            break;
            
        default:
            break;
    }
    
    if (m_Timer > 100) {
    }
}

/**
 * サイズ小
 */
- (void)vanishSmall {
    Particle* p = [Particle add:eParticle_Ring x:self._x y:self._y rot:0 speed:0];
    if (p) {
        [p setScale:0.125];
        [p setAlpha:255];
    }
    
    float rot = 0;
    for (int i = 0; i < 3; i++) {
        rot += Math_RandFloat(30, 60);
        float scale = Math_RandFloat(.1725, .3725);
        float speed = Math_RandFloat(60, 320);
        Particle* p2 = [Particle add:eParticle_Ball x:self._x y:self._y rot:rot speed:speed];
        if (p2) {
            [p2 setScale:scale];
        }
    }
    
}

/**
 * 通常サイズの敵の消滅
 */
- (void)vanishNormal {
    Particle* p = [Particle add:eParticle_Ring x:self._x y:self._y rot:0 speed:0];
    if (p) {
        [p setScale:0.25];
        [p setAlpha:255];
    }
    
    float rot = 0;
    for (int i = 0; i < 6; i++) {
        rot += Math_RandFloat(30, 60);
        float scale = Math_RandFloat(.35, .75);
        float speed = Math_RandFloat(120, 640);
        Particle* p2 = [Particle add:eParticle_Ball x:self._x y:self._y rot:rot speed:speed];
        if (p2) {
            [p2 setScale:scale];
        }
    }
}

/**
 * 巨大サイズ
 */
- (void)vanishBig {
    Particle* p = [Particle add:eParticle_Ring x:self._x y:self._y rot:0 speed:0];
    if (p) {
        [p setScale:1.5];
        [p setAlpha:0xff];
    }
    
    float rot = 0;
    for (int i = 0; i < 6; i++) {
        rot += Math_RandFloat(30, 60);
        float scale = Math_RandFloat(.75, 1.5);
        float speed = Math_RandFloat(120, 640);
        Particle* p2 = [Particle add:eParticle_Ball x:self._x y:self._y rot:rot speed:speed];
        if (p2) {
            [p2 setScale:scale];
        }
    }
    rot = 0;
    for (int i = 0; i < 3; i++) {
        rot += Math_RandFloat(60, 120);
        float scale = Math_RandFloat(1, 2);
        float speed = Math_RandFloat(30, 120);
        float x = self._x + speed * Math_CosEx(rot);
        float y = self._y + speed * -Math_SinEx(rot);
        Particle* p2 = [Particle add:eParticle_Blade x:x y:y rot:rot speed:speed];
        if (p2) {
            [p2 setScale:scale];
            [p2 setRotation:rot];
        }
    }
    
}

/**
 * 弾がヒットした
 */
- (BOOL)hit:(float)dx y:(float)dy {
    
    m_Hp--;
    
    Vec2D v = Vec2D(dx, dy);
    v.Normalize();
    v *= 20;
    self._vx += v.x;
    self._vy += v.y;
    
    if (m_Hp <= 0) {
        
        // エフェクトの生成
        switch (m_Id) {
            case eEnemy_Carrot:
            case eEnemy_Radish:
            case eEnemy_Pokey:
                // 小サイズ
                [self vanishSmall];
                break;
                
            case eEnemy_Nasu:
            case eEnemy_5Box:
            case eEnemy_Tako:
                // 通常サイズ
                [self vanishNormal];
                break;
                
            case eEnemy_Milk:
            case eEnemy_XBox:
            case eEnemy_Pudding:
                // 大サイズ
                [self vanishBig];
                break;
                
            default:
                break;
        }
        [self vanish];
    }
    
    return YES;
}


// 残りHPの割合を取得(0〜1)
- (float)getHpRatio {
    return (float)m_Hp / (float)m_HpMax;
}

- (void)visit {
    [super visit];
    
    switch (m_Id) {
        case eEnemy_Milk:
        case eEnemy_Pudding:
        case eEnemy_XBox:
            // バリアの描画
            if ([self getHpRatio] > 0.3f) {
                glLineWidth(1);
                for (int i = 0; i < 2; i++) {
                    glColor4f(Math_Randf(0.5), 1, Math_Randf(0.5), 1);
                    [self drawCircle:self._x cy:self._y radius:self._r + 8 + Math_Randf(2)];
                }
            }
            break;
            
        default:
            break;
    }
}
@end
