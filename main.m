clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% NODI % devono essere in ordine
n_nodi = 13;
NODI = ...
    [1,0,1
    2,1,1
    3,1,0
    4,0,0
    5,1,0
    6,1,0
    7,2,0
    8,1,1
    9,2,1
    10,2,1
    11,2,0
    12,3,0
    13,3,0];
% ASTE % devono essere in ordine
n_aste = 8; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,1
    2,2,3,1
    3,4,5,1
    4,6,7,1
    5,8,9,1
    6,7,9,1
    7,10,12,1
    8,11,13,1];
% REAZIONI A TERRA
n_rt = 4;
RT = ...
    [1,1
    1,2
    4,2
    4,3];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0;
RTIPER = [];
% REAZIONI MASTER SLAVE
n_ms = 11;
MS = ...
    [3,5,1
    3,5,2
    3,6,1
    3,6,2
    2,8,1
    9,10,1
    9,10,2
    7,11,2
    7,11,3
    12,13,1
    12,13,2];
% CARICHI SUI NODI
n_cc = 2;
CC = ...
    [12,2,3
    7,3,-2];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 2;
CCIPER = ...
    [2,2,-1
    8,2,1];
% CARICHI DISTRIBUITI
n_cd = 8; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,0,0,0,0
   2,0,0,0,0
   3,2,2,0,0
   4,-4,-4,0,0
   5,0,0,3,0
   6,0,0,0,0
   7,0,0,0,0
   8,0,0,0,0];
%..........................................................................

%% RISOLUZIONE
format short
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD);
[coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER);
[coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER);
[R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
fprintf('Valore iperstatica R: %d\n\n', R);

%% PLOT
plot_diag(coeff0,NODI,ASTE,'STRUTTURA 0');
plot_diag(coeffIPER,NODI,ASTE,'STRUTTURA *');
plot_diag(coeffCOMPL,NODI,ASTE,'STRUTTURA COMPLETA');
