//
//  AMMacroUtils.h
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#ifndef AMMacroUtils_h
#define AMMacroUtils_h

//Size
#define kScreenSize [UIScreen mainScreen].bounds.size


//weakify & strongify
#ifndef AMWeakify
#if DEBUG
#if __has_feature(objc_arc)
#define AMWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define AMWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define AMWeakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define AMWeakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef AMStrongify
#if DEBUG
#if __has_feature(objc_arc)
#define AMStrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define AMStrongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define AMStrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define AMStrongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* AMMacroUtils_h */
