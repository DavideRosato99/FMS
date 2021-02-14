clc;
close all;
clear all;
format long e;

%..........................................................................
%% INSERISCI I DATI QUI
% devono essere in ordine
% NODI % [nodo,x,y]
n_nodi = 14;
NODI = ...
    [1,0,0
    2,0,0
    3,1,0
    4,1,0
    5,1,2
    6,1,2
    7,1,2
    8,1,3
    9,0,3
    10,0,2
    11,0,2
    12,0,2
    13,0,2
    14,1,3];
% ASTE % devono essere in ordine
% il tratteggio (destra o sinistra) lo decidi posizionandoti sul nodo1 e
% "guardando" il nodo2
n_aste = 8; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,3,1
    2,5,4,1
    3,7,8,1
    4,14,9,1
    5,9,10,1
    6,11,6,1
    7,3,12,1
    8,2,13,1];
% REAZIONI A TERRA
n_rt = 3; % [nodo,direzione]
RT = ...
    [8,1
    8,2
    10,1];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 0; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
RTIPER = [];
% REAZIONI MASTER SLAVE
% la numerazione dei master deve essere sempre minore di quella degli slave
% se è presente una molla interna non mettere la relazione interna
% maste-slave, anche se ai fini statici ci sarebbe
n_ms = 15; % [master,slave,direzione]
MS = ...
    [1,2,1
    3,4,2
    3,4,3
    5,6,1
    5,6,2
    5,7,1
    5,7,2
    8,14,1
    8,14,2
    10,11,1
    10,11,2
    10,12,1
    10,12,2
    10,13,1
    10,13,2];
% CARICHI SUI NODI
n_cc = 1; % [nodo,direzione,valore]
CC = ...
    [3,3,-1];
% CARICHI SUI NODI IPERSTATICA
n_ccIPER = 2; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
CCIPER = ...
    [8,3,-1
    14,3,1];
% CARICHI DISTRIBUITI
n_cd = 3; % [asta,carico distr.sul nodo 1 (controlla matrice ASTE),carico distr.....]
CD = ...
   [1,0,0,-1,-1
   4,1,1,0.5,-0.5
   5,-1,-1,0,0];
% VINCOLI ELASTICI A TERRA
n_velt = 0; % [nodo,direzione,valore]
VELT = ...
    [];
% VINCOLI ELASTICI INTERNI
n_veli = 0; %[nodo1,nodo2,direzione,valore]
VELI = ...
    [];
% CEDIMENTI VINCOLARI
n_cedv = 0; % [nodo,direzione,valore]
CED = ...
    [];
%..........................................................................

%% RISOLUZIONE
% fill della matrice CD
CD_ip = [];
controllore = -1;
for i1 = 1:size(ASTE,1)
    controllore1 = -1;
    for i2 = 1:size(CD,1)
        if ASTE(i1,1) == CD(i2,1)
            controllore1 = 1;
            controllore2 = i2;
        end
    end
    if controllore1 == -1
        CD_ip = [CD_ip;ASTE(i1,1),0,0,0,0];
    else
        CD_ip = [CD_ip;CD(controllore2,:)];
    end
end
CD = CD_ip;

%% cotrollo che i dati immessi siano corretti
plot_corretto(NODI,ASTE,RT,RTIPER,CC,CCIPER,CD,VELI,VELT,CED,MS);
corretto = input('Digita 1 se è corretto, 0 se è sbagliato:\n');
fprintf('\n\n\n');
if corretto == 1
    % Soluzione struttura 0
    [coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT,CED,CCIPER);
    % Soluzione struttura *
    [coeffIPER] = strutturaIPER(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,CED);
    % % Soluzione struttura completa
    [coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,CED);
    % Merge dei coefficienti per il calcolo del valore di R
    [R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste);
    [num,den,rad,cond] = gen_frazione(R,NODI,ASTE);
    fprintf('Valore iperstatica R:  %d / %d   (%.5f)\n\n', num,den,R);

    %% PLOT
    plot_diag(coeff0,NODI,ASTE,'STRUTTURA 0');
    plot_diag(coeffIPER,NODI,ASTE,'STRUTTURA *');
    plot_diag(coeffCOMPL,NODI,ASTE,'STRUTTURA COMPLETA');
else
    fprintf('Ricontrolla i dati inseriti\n\n\n');
end