clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% NODI % devono essere in ordine
n_nodi = 2;
NODI = ...
    [1,0,0
    2,-1,1];
% ASTE % devono essere in ordine
n_aste = 1; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,2,1,1];
% REAZIONI A TERRA
n_rt = 3;
RT = ...
    [1,1
    1,2
    1,3];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0;
RTIPER = [];
% REAZIONI MASTER SLAVE
n_ms = 0;
MS = ...
    [];
% CARICHI SUI NODI
n_cc = 1;
CC = ...
    [2,1,1];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 0;
CCIPER = ...
    [];
% CARICHI DISTRIBUITI
n_cd = 0; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [];
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
