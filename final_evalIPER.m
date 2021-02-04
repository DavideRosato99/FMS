function [azioni_interne] = final_evalIPER(n_aste,CD,ASTE,NODI,igl,disp_vec)
    % inizializzazione matrice di forze interne
    % agli estremi delle aste
    A = 1e8;
    ai_nod = zeros(n_aste,6);
    
    azioni_interne = zeros(n_aste,3,4);
    
    % ciclo sugli elementi
    for elem=1:n_aste
        nodo1 = ASTE(elem,2);
        nodo2 = ASTE(elem,3);
        xn1 = NODI(nodo1,2);
        xn2 = NODI(nodo2,2);
        yn1 = NODI(nodo1,3);
        yn2 = NODI(nodo2,3);
        dx = (xn2-xn1);
        dy = (yn2-yn1);
        l = sqrt(dx^2 + dy^2);
        
        % inizializzazione matrice simbolica
        Keprimo = zeros(6,6);
        % riempimento matrice
        Keprimo(1,1) = A/l;
        Keprimo(2,2) = 12/(l^3);
        Keprimo(3,3) = 4/l;
        Keprimo(4,4) = Keprimo(1,1);
        Keprimo(5,5) = Keprimo(2,2);
        Keprimo(6,6) = Keprimo(3,3);
        Keprimo(1,4) = -Keprimo(1,1);
        Keprimo(2,3) = 6/(l^2);
        Keprimo(2,5) = -Keprimo(2,2);
        Keprimo(2,6) = Keprimo(2,3);
        Keprimo(3,5) = -Keprimo(2,3);
        Keprimo(3,6) = 2/l;
        Keprimo(5,6) = -Keprimo(2,3);
        % elementi simmetrici uguali
        for i1 = 1:6
            for i2 = i1+1:6
                Keprimo(i2,i1) = Keprimo(i1,i2);
            end
        end
        % coseno e seno sistema di riferimento locale
        ca = dx/l;
        sa = dy/l;
        T0 = zeros(3,3);
        T0 = [ca -sa 0; sa ca 0; 0 0 1];
        T = [T0 zeros(3,3); zeros(3,3) T0];
        % trasformazione matrice di rigidezza
        Feprimo = zeros(6,1);
        dispg = zeros(6,1);
        displ = zeros(6,1);
        % lettura gradi di libertà
        gdlE(1:6) = [igl(nodo1,1:3) igl(nodo2,1:3)];
        % ciclo sui gradi di libertà
        for i1=1:6
            % grado di libertà
            jgl = gdlE(i1);
            % test grado di libertà o di vincolo
            if jgl == -1
                % grado di vincolo
                % spostamento nullo
                dispg(i1) = 0;
            else
                % grado di libertà
                % lettura spostamento
                dispg(i1) = disp_vec(jgl);
            end
        end
        % calcolo spostamenti locali
        displ = (T')*dispg;
        % calcolo forze interne 
        % alle estremità delle travi
        for i1=1:6
            % copiatura forze nodali equivalenti
            ai_nod(elem,i1) = -Feprimo(i1);
            % ciclo effetto spostamenti
            for i2 = 1:6
                % aggiornamento forze interne
                ai_nod(elem,i1) = ai_nod(elem,i1) + Keprimo(i1,i2)*displ(i2);
            end
        end
        % calcolo dei coefficienti delle azioni interne
        % per il plot delle azioni nei grafici N/T/M
        % valori per N(x')
        azioni_interne(elem,1,1)=-ai_nod(elem,1);
        azioni_interne(elem,1,2)=0;
        azioni_interne(elem,1,3)=0;
        azioni_interne(elem,1,4)=0;
        % valori per T(x')
        azioni_interne(elem,2,1)=ai_nod(elem,2);
        azioni_interne(elem,2,2)=0;
        azioni_interne(elem,2,3)=0;
        azioni_interne(elem,2,4)=0;
        % valori per M(x')
        azioni_interne(elem,3,1)=-ai_nod(elem,3);
        azioni_interne(elem,3,2)=ai_nod(elem,2);
        azioni_interne(elem,3,3)=0;
        azioni_interne(elem,3,4)=0;
    end
    
end