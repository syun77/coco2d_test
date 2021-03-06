//
//  Vec.h
//  Test3
//
//  Created by OzekiSyunsuke on 12/03/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef __JP_2DGAMES_MATH2_H__
#define __JP_2DGAMES_MATH2_H__

#include "math.h"

// 数学関数の初期化
void Math_Init();

// 度をラジアンに変換する
float Math_Deg2Rad(float deg);

// ラジアンを度に変換する
float Math_Rad2Deg(float rad);

// コサインを求める
float Math_Cos(float rad);

// サインを求める
float Math_Sin(float rad);

// 平方根を求める
float Math_Sqrt(float a);

// コサインを求める（度）
float Math_CosEx(float deg);

// サインを求める（度）
float Math_SinEx(float deg);

// 乱数の取得
int Math_Rand(int range);

// 乱数の取得 (float 指定)
float Math_Randf(float range);

#endif // __JP_2DGAMES_MATH2_H__
