
% Viritysparametrit mit� lasketaan
Kc = 0;
tauI = 0;
tauD = 0;



% Erikoistapaukset ensin!!! 
% TODO: erikoistapaukset

disp('Viimeinen tapaus, mille viritysparametrej� voidaan laskea on aito systeemimalli,');
disp('jossa on maksimissaan napoja, nollia, viive sek� vakio');

% Ohjelma kysyy k�ytt�j�lt� prosessin navat ja nollat
kyssari = 'Sy�t� prosessin napojen aikavakiot vaakavektorina: ';
navat = input(kyssari);
% eliminoidaan nollat, sill� niit� ei saisi olla

kyssari = 'Sy�t� prosessin nollien aikavakiot vaakavektorina: ';
nollat = input(kyssari);

kyssari = 'Sy�t� prosessin viivetermi: ';
theta0 = input(kyssari);

kyssari = 'Sy�t� prosessin vahvistus: ';
k = input(kyssari);

% Ehk� mielummin sy�tet��n siirtofunktio, mist�
% lasketaan navat ja nollat?

% Tarkastus sille, onko kyseess� aito tai vahvasti aito siirtofunktio (onko napoja enemm�n
% tai yht�paljon kuin nollia)

% J�rjest�� vektorit suurimmasta pienimp��n 
navat = sort(navat, 'descend');
nollat = sort(nollat, 'descend');

tarkistus1 = false;
tarkistus2 = false;
while tarkistus1 == false
    kyssari = 'Haluatko s��t�� PI vai PID s��dint�? (PI/PID) ';
    saadin = input(kyssari, 's');
    saadin = upper(saadin);
    disp(saadin);
    tau1 = 0;
    tau2 = 0;
    theta = 0;
    
    if strcmp('PI', saadin) == 1
        
        % PI viritys
        % Approksimaatio ensimm�iseen kertaluokkaan
        [tau1, theta] = piapp(navat, nollat, theta0);
        
        % Valitaan oletusarvo viritysparametrille tauc
        tauc = theta;

        while tarkistus2 == false
            
            Kc = 1/k*tau1/(tauc+theta);
            tauI = min(tau1, 4*(tauc+theta));
            tauD = 0;

            fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
            fprintf('Kc = %d \n', Kc);
            fprintf('tauI = %d \n', tauI);

            [tauc, tarkistus2] = tarkistus(tauc);
        end
        
        tarkistus1 = true;
        
    elseif strcmp('PID', saadin) == 1
        % PID viritys
        
        [tau1, tau2, theta] = pidapp(navat, nollat, theta0);
        
        while tarkistus2 == false
            
            Kc = 1/k*tau1/(tauc+theta);
            tauI = min(tau1, 4*(tauc+theta));
            tauD = tau2;

            fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
            fprintf('Kc = %d \n', Kc);
            fprintf('tauI = %d \n', tauI);
            fprintf('tauD = %d \n', tauD);

            [tauc, tarkistus2] = tarkistus(tauc);
        end
        
        tarkistus1 = true;
        
    else
        disp('Sy�tt�isitk� jommankumman tarjotuista vaihtoehdoista? (PI/PID) ');
    end
end

clearvars -except Kc tauI tauD

function [tauc, tarkistus1] = tarkistus(tauc)

    kyssari = ('Oletko tyytyv�inen tuloksiin? (Y/N) ');
    vast = input(kyssari, 's');
    vast = upper(vast);
    if vast == 'Y'
        tarkistus1 = true;
        tauc = tauc;
        
    elseif vast == 'N'
        kyssari = ('Sy�t� uusi tau_c: ');
        tauc = input(kyssari);
        tarkistus1 = false;
    end
 
end

function [tau1, theta] = piapp(navat, nollat, theta0)

    for i = 1:length(navat)
        % mit� navoille tehd��n
        if i == 1
            tau1 = navat(i);
            theta = theta0;
        elseif i == 2
            tau1 = tau1 + navat(i)/2;
            theta = theta + navat(i)/2;
        else
            theta = theta + navat(i);
        end
    end

    for i = 1:length(nollat)
        % mit� nollille tehd��n
        if nollat(i) < 0
            % negatiiviset nollat
            theta = theta + abs(nollat(i));

        elseif nollat(i) > 0
            % positiiviset nollat

            if nollat(i) > theta/2
                tau1 = tau1 - nollat(i);
            else
                theta = theta - nollat(i);
            end

        else 
            % nollien ei pit�isi olla nolla eli ei tehd� mit��n
        end
    end

end

function [tau1, tau2, theta] = pidapp(navat, nollat, theta0) 
    for i = 1:length(navat)
        % mit� navoille tehd��n
        if i == 1
            tau1 = navat(i);
            theta = theta0;
        elseif i == 2
            tau2 = navat(i);
        elseif i == 3
            tau2 = tau2 + navat(i)/2;
            theta = theta + navat(i)/2;
        else
            theta = theta + navat(i);
        end
    end

    for i = 1:lenght(nollat)
        % mit� nollille tehd��n
        if nollat(i) < 0
            % negatiiviset nollat
            theta = theta + abs(nollat(i));

        elseif nollat(i) > 0
            % positiiviset nollat

            if nollat(i) > theta/2
                tau1 = tau1 - nollat(i);
            else
                theta = theta - nollat(i);
            end

        else 
            % nollien ei pit�isi olla nolla eli ei tehd� mit��n
        end
    end
end

function [Kc, tauI] = intsimc(theta, k, tauc)
    Kc = 1/k*1/(tauc + theta);
    tauI = 4*(tauc + theta);
end

function [Kc, tauI, tauD] = doupintsimc(theta, k, tauc)
    Kc = 1/k*1/(4*(tauc + theta)^2);
    tauI = 4*(tauc + theta);
    tauD = 4*(tauc + theta);
end

function [Kc, tauI, tauD] = intnapasimc(theta, k, tau2, tauc)
    Kc = 1/k*1/(tauc + theta);
    tauI = 4*(tauc + theta);
    tauD = tau2;
end