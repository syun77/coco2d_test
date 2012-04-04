//
//  Token.m
//  Test6
//
//  Created by OzekiSyunsuke on 12/03/21.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import "Token.h"
#import "Math.h"

/**
 * トークン基底実装
 */
@implementation Token

@synthesize m_pSprite;
@synthesize _x;
@synthesize _y;
@synthesize _vx;
@synthesize _vy;
@synthesize _ax;
@synthesize _ay;

/**
 * 生成
 */
-(id) init {
    self = [super init];
    if (self) {
        return self;
    }
    
    self.m_pSprite = nil;
    m_isCreate = NO;
    
    return self;
}

/**
 * 破棄
 */
-(void) dealloc {
    
    [self vanish];
    
    self.m_pSprite = nil;
    
    [super dealloc];
}

/**
 * 初期化
 */
- (void)initialize {
    
    // 変数初期化
    m_isExist = NO;
    
    // 表示する
    [self setVisible:YES];
    
    // 色初期化
    [self setColor:ccWHITE];
    
    // α値初期化
    [self setAlpha:0xFF];
    
    // ブレンドモード初期化
    [self setBlend:eBlend_Normal];
}

/**
 * 表示開始
 */
- (void)create {
    
    // 存在フラグを立てる
    [self setExist:YES];
    
    // スケジューラーに登録
    [self scheduleUpdate];
    
    // 生成フラグを立てる
    m_isCreate = YES;
    
}

/**
 * 座標・移動量の設定
 */
- (void)set:(float)x y:(float)y vx:(float)vx vy:(float)vy ax:(float)ax ay:(float)ay {
    
    self._x  = x;  self._y  = y;
    self._vx = vx; self._vy = vy;
    self._ax = ax; self._ay = ay;
}

- (void)set2:(float)x y:(float)y rot:(float)rot speed:(float)speed ax:(float)ax ay:(float)ay {
    
    float vx = Math_CosEx(rot) * speed;
    float vy = Math_SinEx(rot) * speed;
    
    [self set:x y:y vx:vx vy:vy ax:ax ay:ay];
}

/**
 * 画面外に出たかどうか
 */
- (BOOL)isOut {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < 0) { return YES; }
    if (self._x > win.width) { return YES; }
    if (self._y < 0) { return YES; }
    if (self._y > win.height) { return YES; }
    
    return NO;
}

/**
 * 画面外に出たかどうか（矩形）
 */
- (BOOL)isOutRect:(float)w h:(float)h {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < -w) { return YES; }
    if (self._x > win.width+w) { return YES; }
    if (self._y < -h) { return YES; }
    if (self._y > win.height+h) { return YES; }
    
    return NO;
    
}

/**
 * 画面外に出たかどうか（円）
 */
- (BOOL)isOutCircle:(float)r {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < -r) { return YES; }
    if (self._x > win.width+r) { return YES; }
    if (self._y < -r) { return YES; }
    if (self._y > win.height+r) { return YES; }
    
    return NO;
    
}

/**
 * 画面外の跳ね返りチェック（矩形）
 */
- (BOOL)isBoundRect:(float)w h:(float)h {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < w) { return YES; }
    if (self._x > win.width - w) { return YES; }
    if (self._y < h) { return YES; }
    if (self._y > win.height - h) { return YES; }
    
    return NO;
}

/**
 * 画面外の跳ね返りチェック（矩形）
 */
- (BOOL)isBoundRectX:(float)w {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < w)
    {
        // 押し出し処理を入れる
        self._x = w;
        return YES;
    }
    
    if (self._x > win.width - w)
    {
        // 押し出し処理を入れる
        self._x = win.width - w;
        return YES;
    }
    
    return NO;
    
}

/**
 * 画面外の跳ね返りチェック（矩形）
 */
- (BOOL)isBoundRectY:(float)h {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._y < h)
    {
        // 押し出し処理を入れる
        self._y = h;
        return YES;
    }
    
    if (self._y > win.height - h)
    {
        // 押し出し処理を入れる
        self._y = win.height - h;
        return YES;
    }
    
    return NO;
    
}


/**
 * 画面外の跳ね返りチェック（円）
 */
- (BOOL)isBoundCircle:(float)r {
    CGSize win = [CCDirector sharedDirector].winSize;
    
    if (self._x < r) { return YES; }
    if (self._x > win.width-r) { return YES; }
    if (self._y < r) { return YES; }
    if (self._y > win.height-r) { return YES; }
    
    return NO;
    
}

/**
 * 移動する
 */
- (void)move:(float)dt {
    self._vx += self._ax;
    self._vy += self._ay;
    self._x  += self._vx * dt;
    self._y  += self._vy * dt;
    
    self.position = ccp(self._x, self._y);
}

/**
 * 要素番号の設定
 */
- (void)setIndex:(NSInteger)index {
    
    m_Index = index;
}

/**
 * 要素番号の取得
 */
- (NSInteger)getIndex {
    
    return m_Index;
}

/**
 * テクスチャをロードしてスプライトを生成
 */
- (void)load:(NSString *)filename {
    
    CCTexture2D* pTex = [[CCTextureCache sharedTextureCache] addImage:filename];
    self.m_pSprite = [CCSprite spriteWithTexture:pTex];
//    self.m_pSprite = [CCSprite spriteWithFile:filename];
    [self addChild:self.m_pSprite];
}

/**
 * 存在するかどうか
 */
- (BOOL)isExist {
    return m_isExist;
}

/**
 * 存在フラグを設定
 */
- (void)setExist:(BOOL)b {
    m_isExist = b;
}

/**
 * 消滅処理 
 */
- (void)vanish {
    
    if (m_isCreate) {
        
        // スケジューラから破棄
        [self removeAllChildrenWithCleanup:YES];
        
        // 存在フラグを下げる
        [self setExist:NO];
        
        m_isCreate = NO;
    }    
}

/**
 * 色を設定する
 */
- (void)setColor:(ccColor3B) color {
    
    self.m_pSprite.color = color;
}

/**
 * α値を設定する (0〜255)
 */
- (void)setAlpha:(int) alpha {
    
    self.m_pSprite.opacity = alpha;    
}

/**
 * ブレンドモードを設定する
 */
- (void)setBlend:(eBlend) mode {
    
    switch (mode) {
        case eBlend_Normal:
            // 通常合成 (透過・α付き)
        {
            self.m_pSprite.blendFunc = (ccBlendFunc) {CC_BLEND_SRC, CC_BLEND_DST};
        }
            break;
                        
        case eBlend_Add:
            // 加算合成
        {
            self.m_pSprite.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
        }
            break;
            
        case eBlend_Mul:     // 乗算合成
        {
            self.m_pSprite.blendFunc = (ccBlendFunc){GL_ZERO, GL_SRC_COLOR};
        }
            break;
            
        case eBlend_Reverse: // 反転合成
        {
            self.m_pSprite.blendFunc = (ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ZERO};
        }
            break;
            
        case eBlend_Screen:  // スクリーン合成
        {
            self.m_pSprite.blendFunc = (ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ONE};
        }
            break;
            
        case eBlend_XOR:     // 排他的論理和
        {
            self.m_pSprite.blendFunc = (ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR};
        }
            break;
            
        default:
            break;
    }
}

// テクスチャ描画範囲を指定する
- (void)setTexRect:(CGRect) rect {
    
    [self.m_pSprite setTextureRect:rect];
}


@end
