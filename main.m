clc;
close all;
clear all;
format long e;

%..........................................................................
%% INSERISCI I DATI QUI
% devono essere in ordine
% NODI % [nodo,x,y]
n_nodi = 4;
NODI = ...
    [1,0,0
    2,0,1
    3,0,1
    4,1,1];
% ASTE % devono essere in ordine
% il tratteggio (destra o sinistra) lo decidi posizionandoti sul nodo1 e
% "guardando" il nodo2
n_aste = 2; % [n_asta,nodo1,nodo2,tratteggio(1:destra,2:sinistra)]
ASTE = ...
    [1,1,2,1
    2,3,4,1];
% REAZIONI A TERRA
n_rt = 4; % [nodo,direzione]
RT = ...
    [1,1
    1,2
    1,3
    4,2];
% REAZIONI A TERRA IPERSTATICA
n_rtIPER = 1; % [nodo,direzione,valore] come valore metti SEMPRE +1 o -1
RTIPER = [4,1,1];
% REAZIONI MASTER SLAVE
% la numerazione dei master deve essere sempre minore di quella degli slave
% se è presente una molla interna non mettere la relazione interna
% maste-slave, anche se ai fini statici ci sarebbe
n_ms = 2; % [master,slave,direzione]
MS = ...
    [2,3,1
    2,3,2];
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
   [2,-1,-1,0,0];
% VINCOLI ELASTICI A TERRA
n_velt = 1; % [nodo,direzione,valore]
VELT = ...
    [4,1,1];
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
corretto = 1;
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
