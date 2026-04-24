/*
 * Project: A Deterministic User-Space NVMe Driver
 * Author: Guillaume Wantiez 
 * License: Creative Commons Attribution 4.0 International (CC BY 4.0)
 * 
 * You are free to use, modify, and distribute this software as long as 
 * the original author is credited.
*/

#ifndef WORKERS_H
#define WORKERS_H

#include <stdint.h>

typedef struct {
    Scheduler_ctx *self;
    uint8_t queue_ID;
    rnd_bench_ctx_t* bench;
} worker_arg_t;

typedef struct {
    Scheduler_ctx *self;
    rnd_bench_ctx_t* bench;
} reaper_arg_t;

void* worker(void* arg);
void* reap_worker(void* arg);


#endif /* WORKERS_H */