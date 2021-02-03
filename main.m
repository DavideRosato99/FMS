clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% NODI % devono essere in ordine
n_nodi = 4;
NODI = ...
    [1,0,1
    2,1,1
    3,1,1
    4,1,0];
% ASTE % devono essere in ordine
n_aste = 2; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,1
    2,3,4,1];
% REAZIONI A TERRA
n_rt = 4;
RT = ...
    [1,1
    1,2
    4,1
    4,2];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0;
RTIPER = [];
% REAZIONI MASTER SLAVE
n_ms = 2;
MS = ...
    [2,3,1
    2,3,2];
% CARICHI SUI NODI
n_cc = 0;
CC = ...
    [];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 0;
CCIPER = ...
    [2,3,-1
    3,3,1];
% CARICHI DISTRIBUITI
n_cd = 1; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,0,0,1,1
   2,0,0,0,0];
%..........................................................................

%% RISOLUZIONE
format short
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD);
[coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER);
[coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER);
[R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
fprintf('Valore iperstatica R: %d\n\n', R);
