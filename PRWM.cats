/* ****** ****** */
//
// PRWM
// Author: Ryan King <rtking@bu.edu>
//
/* ****** ****** */

#ifndef PRWM_CATS
#define PRWM_CATS

#include <stdio.h>
#include <signal.h>
#include <sys/wait.h>
#include <X11/X.h>
#include <X11/Xlib.h>

#define NUM_DESKTOPS 10

/* ****** ****** */

// C Forward declarations

/* ****** ****** */

typedef struct client Client;

typedef struct desktop Desktop;

/* ****** ****** */

// Global Variables

/* ****** ****** */

int mode;
int size;
Client* head;
Client* current;
Desktop* desktops;

/* ****** ****** */

// C Structs

/* ****** ****** */

struct client {
  Window win;

  Client *next;
  Client *parent;
};

struct desktop {
  int mode;
  int size;

  Client* head;
  Client* current;
};

/* ****** ****** */

// C Functions

/* ****** ****** */

ATSinline()
void prwm_sigchld(int signum) {
  if (signal(SIGCHLD, prwm_sigchld) == SIG_ERR) {
    fprintf(stderr, "Could not setup the SIGCHLD handler.\n");
    exit(-1);
  }

  while (0 < waitpid(-1, NULL, WNOHANG));
}

ATSinline()
void prwm_make_desktops() {
  desktops = malloc(NUM_DESKTOPS * sizeof(Desktop));
  for (int i = 0; i < NUM_DESKTOPS; i++) {
    desktops[i].mode = mode;
    desktops[i].size = size;
    desktops[i].head = NULL;
    desktops[i].current = NULL;
  }
}

ATSinline()
void prwm_open_windows(Display* display) {
  if (head != NULL)
    for (Client* c = head; c; c = c->next)
      XMapWindow(display, c->win);
}

ATSinline()
void prwm_close_windows(Display* display) {
  if (head != NULL)
    for (Client* c = head; c; c = c->next)
      XUnmapWindow(display, c->win);
}

ATSinline()
void prwm_save_desktop(int num) {
  desktops[num].mode = mode;
  desktops[num].size = size;
  desktops[num].head = head;
  desktops[num].current = current;
}

ATSinline()
Desktop prwm_load_desktop(int num) {
  mode = desktops[num].mode = mode;
  size = desktops[num].size = size;
  head = desktops[num].head;
  current = desktops[num].head;
}


/* ****** ****** */

#endif

/* End of [PRWM.cats] */
