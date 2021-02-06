clc;
close all;
clear all;
format rat;

%..........................................................................
%% INSERISCI I DATI QUI
% devono essere in ordine
% NODI % [nodo,x,y]
n_nodi = 2;
NODI = ...
    [1,0,0
    2,1,1];
% ASTE % devono essere in ordine
% il tratteggio (destra o sinistra) lo decidi posizionandoti sul nodo1 e
% "guardando" il nodo2
n_aste = 1; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,2];
% REAZIONI A TERRA
n_rt = 3; % [nodo,direzione]
RT = ...
    [1,1
    1,2
    1,3];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
RTIPER = [];
% REAZIONI MASTER SLAVE
% la numerazione dei master deve essere sempre minore di quella degli slave
n_ms = 0; % [master,slave,direzione]
MS = ...
    [];
% CARICHI SUI NODI
n_cc = 0; % [nodo,direzione,valore]
CC = ...
    [];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 0; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
CCIPER = ...
    [];
% CARICHI DISTRIBUITI
n_cd = 1; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,-1,-1,0,0];
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
cond = 1;
% if (size(CCIPER,1) > 0) && (size(VELI,1) > 0)
%     if (CCIPER(1,1) == VELI(1)) && (CCIPER(2,1) == VELI(2))
%         cond = -1;
%     elseif (CCIPER(1,1) == VELI(2)) && (CCIPER(2,1) == VELI(1))
%         cond = -1;
%     end
% end
% if (size(CCIPER,1) > 0) && (size(VELT,1) > 0)
%     if(RTIPER(1) == VELT(1))
%         cond = -1;
%     end
% end
% Soluzione struttura 0
[coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT,cond);
% % Soluzione struttura *
% [coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,cond);
% % Soluzione struttura completa
% [coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,cond);
% % Merge dei coefficienti per il calcolo del valore di R
% [R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
% fprintf('Valore iperstatica R: %d\n\n', R);

%% PLOT
plot_diag(coeff0,NODI,ASTE,'STRUTTURA 0');
% plot_diag(coeffIPER,NODI,ASTE,'STRUTTURA *');
% plot_diag(coeffCOMPL,NODI,ASTE,'STRUTTURA COMPLETA');
