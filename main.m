clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% devono essere in ordine
% NODI % [nodo,x,y]
n_nodi = 16;
NODI = ...
    [1,0,0
    2,1,0
    3,3,0
    4,3,0
    5,4,0
    6,4,0
    7,4,1
    8,1,0
    9,1,1
    10,1,1
    11,2,1
    12,3,1
    13,3,1
    14,3,2
    15,3,2
    16,4,1];
% ASTE % devono essere in ordine
% il tratteggio (destra o sinistra) lo decidi posizionandoti sul nodo1 e
% "guardando" il nodo2
n_aste = 10; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,1
    2,2,3,1
    3,4,5,1
    4,6,7,1
    5,8,9,1
    6,10,11,1
    7,11,12,1
    8,13,16,1
    9,9,14,1
    10,13,15,1];
% REAZIONI A TERRA
n_rt = 5; % [nodo,direzione]
RT = ...
    [1,1
    1,2
    3,2
    7,1
    7,2];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
RTIPER = [];
% REAZIONI MASTER SLAVE
% la numerazione dei master deve essere sempre minore di quella degli slave
n_ms = 13; % [master,slave,direzione]
MS = ...
    [2,8,1
    2,8,2
    3,4,1
    3,4,2
    5,6,2
    5,6,3
    7,16,1
    7,16,2
    9,10,1
    9,10,2
    12,13,1
    12,13,3
    14,15,1];
% CARICHI SUI NODI
n_cc = 3; % [nodo,direzione,valore]
CC = ...
    [9,1,-1
    11,2,-1
    13,3,-1];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 2; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
CCIPER = ...
    [3,3,-1
    4,3,1];
% CARICHI DISTRIBUITI
n_cd = 8; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,0,0,0,0
   2,0,0,1,0
   3,0,0,0,0
   4,0,0,0,0
   5,0,0,0,0
   6,0,0,0,0
   7,0,0,0,0
   8,-1,-1,0,0
   9,0,0,0,0
   10,0,0,0,0];
% VINCOLI ELASTICI A TERRA
n_velt = 0; % [nodo,direzione,valore]
VELT = ...
    [];
% VINCOLI ELASTICI INTERNI
n_veli = 1; %[nodo1,nodo2,direzione,valore]
VELI = ...
    [3,4,3,13/4];
%..........................................................................

%% RISOLUZIONE
format short
cond = 1;
if (CCIPER(1,1) == VELI(1)) && (CCIPER(2,1) == VELI(2))
    cond = -1;
elseif (CCIPER(1,1) == VELI(2)) && (CCIPER(2,1) == VELI(1))
    cond = -1;
elseif (RTIPER(1) == VELT(1))
    cond = -1;
end
% Soluzione struttura 0
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT,cond);
% Soluzione struttura *
[coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,cond);
% Soluzione struttura completa
[coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,cond);
% Merge dei coefficienti per il calcolo del valore di R
[R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
fprintf('Valore iperstatica R: %d\n\n', R);

%% PLOT
plot_diag(coeff0,NODI,ASTE,'STRUTTURA 0');
plot_diag(coeffIPER,NODI,ASTE,'STRUTTURA *');
plot_diag(coeffCOMPL,NODI,ASTE,'STRUTTURA COMPLETA');
