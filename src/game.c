/*
 * game.c — the Iron Clad (ID-0220) prototype ROM set, shared by the player
 * and the generator so both load the program identically.
 */
#include "game.h"

/* MAME set "ironclad" (prototype). The 2 MB P ROM holds the banked half
 * first; the fixed $000000 half is its second MB. Both are stored
 * byte-swapped. This prototype has a single 4 MB ADPCM ROM, so .vrom lists
 * one file (the array is zero-padded). */
const ng_game_t k_ironclad = {
    .name = "ironclad",
    .title = "Choutetsu Brikin'ger / Iron Clad",
    .prom_size = 0x200000,
    .prom = {
        {"proto_220-p1.p1", 0x100000, 0x000000, 0x100000, 1},
        {"proto_220-p1.p1", 0x000000, 0x100000, 0x100000, 1},
    },
    .crom_size = 0x1000000,
    .crom_pairs = {
        {"proto_220-c1.c1", "proto_220-c2.c2"},
        {"proto_220-c3.c3", "proto_220-c4.c4"},
    },
    .srom = "proto_220-s1.s1",
    .m1 = "proto_220-m1.m1",
    .vrom = {"proto_220-v1.v1"},
};
