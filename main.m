clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% devono essere in ordine
% NODI % [nodo,x,y]
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
% il tratteggio (destra o sinistra) lo decidi posizionandoti sul nodo1 e
% "guardando" il nodo2
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
n_rt = 4; % [nodo,direzione]
RT = ...
    [1,1
    1,2
    4,2
    4,3];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
RTIPER = [];
% REAZIONI MASTER SLAVE
% la numerazione dei master deve essere sempre minore di quella degli slave
n_ms = 11; % [master,slave,direzione]
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
n_cc = 2; % [nodo,direzione,valore]
CC = ...
    [12,2,3
    7,3,-2];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 2; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
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
% VINCOLI ELASTICI A TERRA
n_velt = 0; % [nodo,direzione,valore]
VELT = ...
    [];
% VINCOLI ELASTICI INTERNI
n_veli = 0; %[nodo1,nodo2,direzione,valore]
VELI = ...
    [];
%..........................................................................

%% RISOLUZIONE
format short
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT);
[coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER);
[coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT);
[R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
fprintf('Valore iperstatica R: %d\n\n', R);

%% PLOT
plot_diag(coeff0,NODI,ASTE,'STRUTTURA 0');
plot_diag(coeffIPER,NODI,ASTE,'STRUTTURA *');
plot_diag(coeffCOMPL,NODI,ASTE,'STRUTTURA COMPLETA');
