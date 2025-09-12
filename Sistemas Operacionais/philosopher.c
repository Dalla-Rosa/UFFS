#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#define N 5
#define LEFT (i + N - 1) % N
#define RIGHT (i + 1) % N
#define THINKING 0
#define HUNGRY 1
#define EATING 2

int state[N];
sem_t mutex;
sem_t s[N];

void test(int i);
void take_forks(int i);
void put_forks(int i);
void think(int i);
void eat(int i);

void* philosopher(void* num) {
    int i = *(int*)num;
    while (1) {
        think(i);
        take_forks(i);
        eat(i);
        put_forks(i);
    }
    return NULL;
}

void think(int i) {
    printf("Philosopher %d is thinking\n", i);
    sleep(1);
}

void eat(int i) {
    printf("Philosopher %d is eating\n", i);
    sleep(1);
}

void take_forks(int i) {
    sem_wait(&mutex);
    state[i] = HUNGRY;
    test(i);
    sem_post(&mutex);
    sem_wait(&s[i]);
}

void put_forks(int i) {
    sem_wait(&mutex);
    state[i] = THINKING;
    test(LEFT);
    test(RIGHT);
    sem_post(&mutex);
}

void test(int i) {
    if (state[i] == HUNGRY &&
        state[LEFT] != EATING &&
        state[RIGHT] != EATING) {
        state[i] = EATING;
        sem_post(&s[i]);
    }
}

int main() {
    pthread_t threads[N];
    int i;
    int* ids[N];

    sem_init(&mutex, 0, 1);
    for (i = 0; i < N; i++) {
        sem_init(&s[i], 0, 0);
        state[i] = THINKING;
    }

    for (i = 0; i < N; i++) {
        ids[i] = malloc(sizeof(int));
        *ids[i] = i;
        pthread_create(&threads[i], NULL, philosopher, ids[i]);
    }

    for (i = 0; i < N; i++) {
        pthread_join(threads[i], NULL);
        free(ids[i]);
    }

    return 0;
}
