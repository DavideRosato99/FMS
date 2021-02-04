function [coeff0] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT,cond)
    % creazione matrice nodale igl
    igl = zeros(n_nodi,3);
    % modifica a causa delle reazioni a terra
    for i1 = 1:n_nodi
        for i2 = 1:size(RT,1)
            if RT(i2,1) == i1
                igl(i1,RT(i2,2)) = -1;
            end
        end
    end

    %% modifica a causa delle relazioni master-slave
    for i = 1:size(MS,1)
        igl(MS(i,2),MS(i,3)) = MS(i,1);
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
    F_extG(1:n_gdl)=car_con(1:n_gdl);

    %% matrice forze globale
    for elem = 1:n_aste
        [Ke,Fe] = matrice_finale0(elem,NODI,ASTE,CD);
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
    if cond == 1
        [KstfG,F_extG] = vincoli_elastici(KstfG,F_extG,VELT,VELI,igl);
    end
    
    %% Soluzione del sistema
    disp_vec = zeros(n_gdl,1);
    disp_vec = KstfG\F_extG;

    %% Ricostruzione degli spostamenti per i diagrammi
    [coeff0] = final_eval0(n_aste,CD,ASTE,NODI,igl,disp_vec);
    
    %% Correzioni round-errors
    for i1 = 1:n_aste
        for i2 = 1:3
            for i3 = 1:4
                if abs(coeff0(i1,i2,i3)) < 1e-5
                    coeff0(i1,i2,i3) = 0;
                end
            end
        end
    end
end