% Simulacia riadenia krizovatky

% miesto * nastavit vlastne data

clear; clc; close all;

% rezim: 1 - slaba premavka
% rezim: 2 - hustejsia premavka
% rezim: 3 - dopravna spicka zo smeru C
% rezim: 4 - dopravna spicka zo smeru B
% rezim: 5 - dopravna spicka zo smeru A
% rezim: 6 - kombinovana dopravna spicka
rezim = 6; % *

% fuzzy_volba: 0 = bez fuzzy riadenia, 1 = s fuzzy riadenim
% Ked je fuzzy_volba = 0 tak premenna vlastne_intervaly rozhoduje o tom, ci
% na riadenie bude pouzity vektor: intervaly alebo riadenie nenastane
% Ked je fuzzy_volba = 1 tak sa reguluje interval pre dlzku zelenej na
% semaforoch fuzzy logikou
fuzzy_volba = 1;

% nazov zvoleneho fuzzy suboru (meno.fis)
fuzzy_meno = 'bagin';

% Pre priebeh bez riadenia: 0
% Pre pouzitie vlastnych intervalov: 1
vlastne_intervaly = 0;

% Dlzky intervalov zelenej v jednotlivych smeroch
% Smery: [A, B, C]
intervaly = [10, 10, 10]; % [*,*,*]

% vizualizacia
viz = 0;

init_krizovatka(rezim, fuzzy_volba, fuzzy_meno, intervaly, vlastne_intervaly, viz);

