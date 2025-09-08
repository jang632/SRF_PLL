clear; clc; close all;

% Parametry
fs = 64000;            % Częstotliwość próbkowania [Hz]
f = 50;                % Częstotliwość podstawowa [Hz]
T = 2;               % Czas trwania [s]
N = fs * T;            % Liczba próbek
t = (0:N-1)/fs;        % Oś czasu

% Generacja sygnału tylko dla jednej fazy (np. Faza A)
vA = sin(2*pi*f*t) + 0.3*sin(2*pi*7*f*t) + 0.1*sin(2*pi*4*f*t);

% Skalowanie do zakresu int32
scale = 2^31 - 1;                 % maksymalna wartość int32
max_val = max(abs(vA), [], 'all'); % normalizacja względem maksimum
vA_int32 = int32(vA / max_val * scale);

% Zapis do pliku tekstowego – 1 kolumna binarna (32 bity)
fileID = fopen('OnePhaseHarmonics_64kHz_32bit.txt', 'w');

for k = 1:N
    binA = dec2bin(typecast(vA_int32(k), 'uint32'), 32);
    fprintf(fileID, '%s\n', binA);
end

fclose(fileID);
disp('Zapisano plik "OnePhaseHarmonics_64kHz_32bit.txt".');
