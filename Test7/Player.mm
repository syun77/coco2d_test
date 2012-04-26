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
#import "Aim.h"
#import "Charge.h"
#import "Gauge.h"
#import "GaugeHp.h"
#import "Particle.h"

// ダメージタイマー
static const int TIMER_DAMAGE = 30;

// ダメージ時の移動量
static const float SPEED_DAMAGE = 200;
static const float DECAY_DAMAGE = 0.95f; // 移動量の減衰値 

// 弾の移動量
static const float SPEED_SHOT = 360;

// チャージが有効となる開始時間
static const int TIMER_CHARGE_START = 60;

// チャージ最大量
static const int MAX_POWER = 120;

// HPの最大
static const int MAX_HP = 100;

// 回復用タイマー
static const int TIMER_RECOVER = 60;


/**
 * 状態
 */
enum eState {
    eState_Standby, // 待機
    eState_Damage,  // ダメージ
    eState_Vanish,  // 消滅
};


/**
 * 自機クラスを実装する
 */
@implementation Player

/**
 * 照準を取得
 */
- (Aim*)getAim {
    GameScene* scene = [GameScene sharedInstance];
    return scene.aim;
}

/**
 * チャージエフェクトを取得
 */
- (Charge*)getCharge {
    GameScene* scene = [GameScene sharedInstance];
    return scene.charge;
}

/**
 * ゲージ描画オブジェクトを取得する
 */
- (Gauge*)getGauge {
    GameScene* scene = [GameScene sharedInstance];
    return scene.gauge;
}

/**
 * HPゲージ描画オブジェクトを取得する
 */
- (GaugeHp*)getGaugeHp {
    GameScene* scene = [GameScene sharedInstance];
    return scene.gaugeHp;
}

/**
 * 状態遷移
 */
- (void)changeState:(eState)state {

    if (m_State == eState_Vanish) {
        // 消滅状態は状態変化不可
        return;
    }
    m_State = state;
}

/**
 * 初期化
 */
- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    [self load:@"all.png"];
    
    [self create];
    
    // 初期パラメータ設定
    self._x = System_CenterX();
    self._y = System_CenterY();
    m_Target.Set(self._x, self._y);
    
    [self setTexRect:Exerinya_GetRect(eExerinyaRect_Player1)];
    [self setScale:0.5f];
    [self setSize2:24];
    
    // 変数初期化
    m_State = eState_Standby;
    m_Timer = 0;
    m_tPast = 0;
    m_tShot = 0;
    m_tDamage = 0;
    m_tPower = 0;
    m_Combo = 0;
    m_ComboMax = 0;
    
    
    return self;
}

// 開始
- (void)initialize {
   
    // HP初期化
    m_Hp = MAX_HP;
    
    Gauge* gauge = [self getGauge];
    [gauge initialize:MAX_POWER];
    
    GaugeHp* gaugeHp = [self getGaugeHp];
    [gaugeHp initialize:MAX_HP];
}

// タッチ開始コールバック
- (void)cbTouchStart:(float)x y:(float)y {
    
    // コンボ初期化
    [self initCombo];
    
    m_Start.x = self._x;
    m_Start.y = self._y;
    
    if (m_State == eState_Damage) {
        
        // ダメージ中だったら待機状態に戻す
        [self changeState:eState_Standby];
    }
}

// タッチ終了コールバック
- (void)cbTouchEnd:(float)x y:(float)y {
    m_tPower -= TIMER_CHARGE_START;
    if (m_tPower < 0) {
        m_tPower = 0;
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

// 移動中かどうか
- (BOOL)isMoving {
    return [self isTouch];
}

/**
 * 弾を撃つ
 */
- (void)checkShot {
    if ([self isTouch] == NO) {
        // タッチしていない
        // 一番近い敵を探す
        Aim* aim = [self getAim];
        Enemy* e = [Enemy getNearest:aim._x y:aim._y];
        if (e) {
            [aim setTarget:e._x y:e._y];
        }
        
        float nearestLength = 9999999;
        e = [Enemy getNearest:self._x y:self._y];
        if (e) {
            Vec2D v = Vec2D(e._x - self._x, e._y - self._y);
            nearestLength = v.LengthSq();
        }

        // ショットタイマー更新
        if (m_tShot > 0) {
            m_tShot--;
        }
        if (m_tShot <= 0) {
            // 弾を撃つ
            [self shot];
            if (m_tPower > 0) {
                m_tPower--;
                m_tShot += 2;
                if (nearestLength < 20000) {
                    m_tShot = 0;
                }
            }
            else {
                // パワー切れ
                
                // 近くに敵がいるほど連射性能がアップ
                float ratio = nearestLength / (160 * 120);
                if (ratio > 1) {
                    ratio = 1;
                }
                m_tShot = SHOT_TIMER * ratio;
            }
        }
    }
    else {
        m_tShot = 0;
        
        // パワーをためる
        m_tPower++;
        if (m_tPower > MAX_POWER + TIMER_CHARGE_START) {
            m_tPower = MAX_POWER + TIMER_CHARGE_START;
        }
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
   
    m_tRecover++;
    if (m_tRecover > TIMER_RECOVER) {
        // HP 回復
        m_Hp++;
        if (m_Hp > MAX_HP) {
            m_Hp = MAX_HP;
        }
        
        m_tRecover -= TIMER_RECOVER * 0.2f;
    }
    
    // 弾を撃つ
    [self checkShot];
    
    Aim* aim = [self getAim];
    Charge* charge = [self getCharge];
    
    // 移動処理
    if ([self isTouch]) {
        // タッチ中
        InterfaceLayer* input = [self getInterfaceLayer];
        // 移動処理
        float startX = [input startX];
        float startY = [input startY];
        float nowX = [input getPosX];
        float nowY = [input getPosY];
        // 相対で移動する
        float dx = nowX - startX;
        float dy = nowY - startY;
        Vec2D v = Vec2D(m_Start.x + dx, m_Start.y + dy);
        [self clipScreen:&v];
        m_Target.Set(v.x, v.y);
        
        // 照準の動作フラグを設定
        [aim setActive:NO];
        
        // 照準も移動する
        [aim setTarget:[input getPosX] y:[input getPosY]];
        
        // チャージエフェクト有効
        if (m_tPower > TIMER_CHARGE_START) {
            
            [charge setParam:eCharge_Playing x:self._x y:self._y];
        }
        else {
            
            [charge setParam:eCharge_Wait x:self._x y:self._y];
        }
        
    }
    else {
        [aim setActive:YES];
        [charge setVisible:NO];
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
        [self changeState:eState_Standby];
        
        // 移動先を更新
        m_Target.Set(self._x, self._y);
        
        // タッチ開始座標をリセットする
        InterfaceLayer* input = [self getInterfaceLayer];
        [input resetStartPos];
        m_Start.Set(self._x, self._y);
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
    
    Aim* aim = [self getAim];
    if ((aim._x - self._x) > 0) {
        if (self.scaleX < 0) {
            self.scaleX = -self.scaleX;
        }
    }
    else {
        if (self.scaleX > 0) {
            self.scaleX = -self.scaleX;
        }
    }
    
}

/**
 * ゲージ更新
 */
- (void)updateGauge {
    Gauge* gauge = [self getGauge];
    
    [gauge set:m_tPower - TIMER_CHARGE_START x:self._x y:self._y];
    
    GaugeHp* gaugeHp = [self getGaugeHp];
    [gaugeHp set:m_Hp x:self._x y:self._y];
}

/**
 * 更新
 */
- (void)update:(ccTime)dt {
    
    if (m_State == eState_Vanish) {
        
        // 死亡したので何もしない
        return;
    }
    
    // タイマー更新
    m_tPast++;
    if (m_tDamage > 0) {
        m_tDamage--;
    }
    
    // 移動
    self._vx *= DECAY_DAMAGE;
    self._vy *= DECAY_DAMAGE;
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
            // 待機中
            [self updateStandby:dt];
            break;
        
        case eState_Damage:
            // ダメージ中
            [self updateDamage:dt];
            break;
            
        case eState_Vanish:
            // 消滅
            break;
            
        default:
            break;
    }
    
    // ゲージ更新
    [self updateGauge];
    
    // アニメーション更新
    [self updateAnime];
    
    m_PrevX = self._x;
    m_PrevY = self._y;
}

// HPが最大値かどうか
- (BOOL)isHpMax {
    return m_Hp == MAX_HP;
}

// 弾を撃つ
- (void)shot {
    
    // 照準に向けて弾を撃つ
    Aim* aim = [self getAim];
    Vec2D v = Vec2D(aim._x - self._x, aim._y - self._y);
    
    // 弾を撃つ
    float speed = SPEED_SHOT * (1 + ((float)m_tPower / MAX_POWER));
    [Shot add:self._x y:self._y rot:v.Rot() + Math_RandFloat(-5, 5) speed:speed];
    
    if ([self isHpMax]) {
        // フルパワー時は3Way
        [Shot add:self._x y:self._y rot:v.Rot() - 15 speed:speed];
        [Shot add:self._x y:self._y rot:v.Rot() + 15 speed:speed];
    }
}

// ダメージ
- (void)damage:(Token*)t {
    
    // コンボ回数初期化
    [self initCombo];
    
    // パワーゲージをリセット
    m_tPower = 0;
    
    // チャージエフェクト終了
    Charge* charge = [self getCharge];
    [charge setParam:eCharge_Disable x:self._x y:self._y];
   
    // 吹き飛ばす
    Vec2D d = Vec2D(self._x - t._x, self._y - t._y);
    d.Normalize();
    d *= SPEED_DAMAGE;
    self._vx = d.x;
    self._vy = d.y;
    
    // HPを減らす
    if (m_State == eState_Standby) {
        m_Hp -= MAX_HP * 0.2f; // 5回ダメージで死亡
    }
    else {
        m_Hp--;
        if (m_Hp < 1) {
            // 連続ダメージでは死なないようにする
            m_Hp = 1;
        }
    }
    
    if (m_Hp < 0) {
        
        // 死亡
        m_Hp = 0;
        
        // 全て非表示にする
        [self setVisible:NO];
        Charge* charge = [self getCharge];
        [charge setVisible:NO];
        Gauge* gauge = [self getGauge];
        [gauge setVisible:NO];
        GaugeHp* gaugeHp = [self getGaugeHp];
        [gaugeHp setVisible:NO];
        
        [self changeState:eState_Vanish];
        
        // 死亡エフェクト生成
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
    else {
        
        // 回復用タイマーをリセットする
        m_tRecover = 0;
        m_tDamage = TIMER_DAMAGE;
        m_Timer = TIMER_DAMAGE;
        
        [self changeState:eState_Damage];
    }
    
}

// パワーの取得
- (int)getPower {
    return m_tPower;
}

// 消滅したかどうか
- (BOOL)isVanish {
    return m_State == eState_Vanish;
}

// コンボ初期化
- (void)initCombo {
    
    m_Combo = 0;
    Combo* combo = [GameScene sharedInstance].combo;
    [combo end];
}

// コンボ回数増加
- (void)addCombo {
    
    if ([self isMoving]) {
        // 移動中は増えない
        return;
    }
    
    m_Combo++;
    if (m_Combo > m_ComboMax) {
        
        // コンボ回数更新
        m_ComboMax = m_Combo;
    }
    
    // コンボ演出開始
    Combo* combo = [GameScene sharedInstance].combo;
    [combo start:m_Combo];
}

// コンボ回数を取得
- (int)getCombo {
    return m_Combo;
}

// コンボ最大回数を取得
- (int)getComboMax {
    return m_ComboMax;
}

@end
