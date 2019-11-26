//
//  Person.m
//  BitDemo
//
//  Created by GoSun on 2019/11/26.
//  Copyright © 2019 ibiaoma. All rights reserved.
//

#import "Person.h"

#define PersonTallMask 0b00000001
#define PersonRichMask 0b00000010
#define PersonHandsomeMask 0b00000100

//#define PersonTallMask (1<<0)   //1 左移 0 位
//#define PersonRichMask (1<<1)   //1 左移 1 位
//#define PersonHandsomeMask (1<<2)   //1 左移 2 位

@interface Person ()
//{
//    struct{
//        char tall;
//        char rich;
//        char handsome;
//    }_tallRichHandsome;
//}
{
    union{
        char bits;

        struct{
            char tall;//位域 占1位
            char rich;
            char handsome;
        };

    }_tallRichHandsome;
}

@end

@implementation Person


- (void)setTall:(BOOL)tall
{
    if (tall) {
        _tallRichHandsome.bits |= PersonTallMask;
    }else{
        _tallRichHandsome.bits &= ~PersonTallMask;
    }
}
- (BOOL)tall
{
    return !!(_tallRichHandsome.bits & PersonTallMask);
}

- (void)setRich:(BOOL)rich
{
    if (rich) {
        _tallRichHandsome.bits |= PersonRichMask;
    }else{
        _tallRichHandsome.bits &= ~PersonRichMask;
    }
}
- (BOOL)rich
{
    return !!(_tallRichHandsome.bits & PersonRichMask);
}

- (void)setHandsome:(BOOL)handsome
{
    if (handsome) {
        _tallRichHandsome.bits |= PersonHandsomeMask;
    }else{
        _tallRichHandsome.bits &= ~PersonHandsomeMask;
    }
}
- (BOOL)handsome
{
    return !!(_tallRichHandsome.bits & PersonHandsomeMask);
}


/**
- (void)setTall:(BOOL)tall
{
    if (tall) {
        _tallRichHandsome.tall |= PersonTallMask;
    }else{
        _tallRichHandsome.tall &= ~PersonTallMask;
    }
}
- (BOOL)tall
{
    return !!(_tallRichHandsome.tall & PersonTallMask);
}

- (void)setRich:(BOOL)rich
{
    if (rich) {
        _tallRichHandsome.rich |= PersonRichMask;
    }else{
        _tallRichHandsome.rich &= ~PersonRichMask;
    }
}
- (BOOL)rich
{
    return !!(_tallRichHandsome.rich & PersonRichMask);
}

- (void)setHandsome:(BOOL)handsome
{
    if (handsome) {
        _tallRichHandsome.handsome |= PersonHandsomeMask;
    }else{
        _tallRichHandsome.handsome &= ~PersonHandsomeMask;
    }
}
- (BOOL)handsome
{
    return !!(_tallRichHandsome.handsome & PersonHandsomeMask);
}
*/

@end
