function [coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT,CED)
    %% se l'incognita iperstatica è a terra "anti-declasso" e aggiungo una
    % reazione vincolare all'originaria matrice delle reazioni vincolari
    if size(RTIPER,1) ~= 0
        nodo = RTIPER(1,1);
        direzione = RTIPER(1,2);
        RT(end+1,:) = [nodo direzione];
    end
    %% se l'incognita iperstatica è interna, "anti-declasso" e aggiungo una
    % reazione vincolare all'originaria matrice master-slave
    if size(CCIPER,1) ~= 0
        if size(CCIPER,1) ~= 2
            error('manca azione e reazione iperstatica interna, ricontrolla matrice CCIPER');
        end
        if CCIPER(1,1) > CCIPER(2,1)
            error('in CCIPER devi mettere prima il nodo più piccolo di numerazione');
        end
        if CCIPER(1,2) ~= CCIPER(2,2)
            error('azione e reazione in CCIPER devono avere la stessa direzione');
        end
        MS(end+1,:) = [CCIPER(1,1) CCIPER(2,1) CCIPER(1,2)];
    end
    %% devo togliere la reazione vincolare corrispondente al cedimento
    % vincolare
    if size(CED,1) ~= 0
        nodo = CED(1,1);
        direzione = CED(1,2);
        for i1 = 1:size(RT,1)
            if (RT(i1,1) == nodo) && (RT(i1,2) == direzione)
                RT(i1,:) = [0 0];
            end
        end
    end
    %% controllo vincoli elastici interni
    if size(VELI,1) ~= 0
        if size(CCIPER,1) ~= 0
            % se le due incognite iper sono messe in corrispondenza della
            % molla interna ho già aggiunto un grado di vincolo interno
            % alla matrice CD, grado di vincolo che non devo avere se c'è
            % una molla
            
            % controllo che iperstatica sia in corrispondenza di una molla
            % interna:
            if ((CCIPER(1,1) == VELI(1)) && (CCIPER(2,1) == VELI(2))) || ((CCIPER(1,1) == VELI(2)) && (CCIPER(2,1) == VELI(1)))
                cond_veli = -1;
                % elimino grado di vincolo interno corrispondente
                for i1 = 1:size(MS,1)
                    if ((MS(i1,1) == CCIPER(1,1)) && (MS(i1,2) == CCIPER(2,1))) || ((MS(i1,1) == CCIPER(2,1)) && (MS(i1,2) == CCIPER(1,1)))
                        if MS(i1,3) == CCIPER(1,2)
                            MS(i1,:) = [0,0,0];
                        end
                    end
                end
            end
        end
    end
    if size(VELI,1) ~= 0
        if size(CCIPER,1) == 0
            for i1 = 1:size(MS,1)
                if ((MS(i1,1) == VELI(1)) && (MS(i1,2) == VELI(2)) && (MS(i1,3) == VELI(3))) || ((MS(i1,1) == VELI(2)) && (MS(i1,2) == VELI(1))  && (MS(i1,3) == VELI(3)))
                    MS(i1,:) = [0,0,0];
                end
            end
        end
    end
    %% controllo vincoli elastici esterni
    if size(VELT,1) ~= 0 % se ci sono molle a terra
        % tolgo reazione vincolare a terra se in corrispondenza c'è la
        % molla a terra
        for i1 = 1:size(RT,1)
            for i2 = 1:size(VELT,1)
                if (RT(i1,1) == VELT(i2,1)) && (RT(i1,2) == VELT(i2,2))
                    RT(i1,:) = [0 0];
                end
            end
        end
    end
    %% creazione matrice nodale igl
    igl = zeros(n_nodi,3);
    % modifica a causa delle reazioni a terra
    for i1 = 1:n_nodi
        for i2 = 1:size(RT,1)
            if RT(i2,1) == i1
                if RT(i2,2) ~= 0
                    igl(i1,RT(i2,2)) = -1;
                end 
            end
        end
    end
    %% modifica a causa delle relazioni master-slave
    for i = 1:size(MS,1)
        if MS(i,1) ~= 0
            igl(MS(i,2),MS(i,3)) = MS(i,1);
        end
    end
    %% conteggio gradi di libertà
    n_gdl = 0;
    for i1 = 1:n_nodi
        for i2 = 1:3
            if igl(i1,i2) == 0
                n_gdl = n_gdl +1;
                igl(i1,i2) = n_gdl;
            elseif igl(i1,i2) > 0
                nodM = igl(i1,i2);
                igl(i1,i2) = igl(nodM,i2);
            end
        end
    end

    %% creazione matrice dei carichi esterni sui nodi
    car_con = zeros(n_gdl,1);
    for i1 = 1:size(CC,1)
        nodo = CC(i1,1);
        direzione = CC(i1,2);
        forza = CC(i1,3);
        jgl = igl(nodo,direzione);
        if jgl > 0
            car_con(jgl) = car_con(jgl) + forza;
        end
    end

    %% creazione matrice dei carichi distribuiti
    car_dis = zeros(n_aste,2);
    for i1 = 1:size(CD,1)
        elemento = CD(i1,1);
        car_dis(elemento,1:2) = car_dis(elemento,1:2) + ...
            CD(i1,2:3);
    end

    %% inizializzazione matrice di rigidezza totale
    KstfG = zeros(n_gdl,n_gdl);

    %% inizializzazione vettore  carichi globali
    F_extG = zeros(n_gdl,1);

    %% copia carichi concentrati ai nodi
    F_extG(1:n_gdl) = car_con(1:n_gdl);

    %% matrice forze globale
    for elem = 1:n_aste
        [Ke,Fe] = matrice_finaleCOMPL(elem,NODI,ASTE,CD);
        nodo1 = ASTE(elem,2);
        nodo2 = ASTE(elem,3);
        gdlE(1:6) = [igl(nodo1,1:3) igl(nodo2,1:3)];
        for i1 = 1:6
            if gdlE(i1) > 0
                F_extG(gdlE(i1))=F_extG(gdlE(i1))+Fe(i1);
                for i2 = 1:6
                    if gdlE(i2) > 0
                        KstfG(gdlE(i1),gdlE(i2))=KstfG(gdlE(i1),gdlE(i2))+Ke(i1,i2);
                    end
                end
            end
        end
    end
    
    %% Correzioni vincoli elastici
    [KstfG,F_extG] = vincoli_elastici(KstfG,F_extG,VELT,VELI,igl);
    
     %% Correzioni cedimenti vincolari
    [KstfG,F_extG] = cedimenti_vincolari(KstfG,F_extG,CED,igl,n_gdl);
    
    %% Soluzione del sistema
    disp_vec = zeros(n_gdl,1);
    disp_vec = KstfG\F_extG;

    %% Ricostruzione degli spostamenti per i diagrammi
    [coeffCOMPL] = final_evalCOMPL(n_aste,CD,ASTE,NODI,igl,disp_vec);
    
    %% Correzioni round-errors
    for i1 = 1:n_aste
        for i2 = 1:3
            for i3 = 1:4
                if abs(coeffCOMPL(i1,i2,i3)) < 1e-5
                    coeffCOMPL(i1,i2,i3) = 0;
                end
            end
        end
    end
end