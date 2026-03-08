% TP Filtrage - Version compatible Octave
clear all;
close all;
clc;
pkg load image;

printf("=== TP Filtrage - Traitement d'Images ===\n");
printf("Début du traitement...\n\n");

%% 1. Chargement des images avec chemins absolus
printf("1. Chargement des images...\n");

% Définir le chemin de base (À MODIFIER selon votre dossier)
chemin_base = "/home/bmed/Documents/school/nf/pw-artificial-vision/tp-2/";

try
    img_lenna = imread(fullfile(chemin_base, "lena.png"));
    printf("   ✅ Image Lenna chargée avec succès\n");
catch
    printf("   ❌ Erreur: impossible de charger lena.png\n");
    return;
end_try_catch

try
    img_cameraman = imread(fullfile(chemin_base, "peppers.png"));
    printf("   ✅ Image Cameraman chargée avec succès\n");
catch
    printf("   ⚠️  peppers.png non trouvée, création d'une image de test\n");
    img_cameraman = 255 * ones(256, 256);
    img_cameraman(50:200, 50:200) = 0;
end_try_catch

%% 2. Conversion en niveaux de gris
printf("\n2. Conversion en niveaux de gris...\n");

if size(img_lenna, 3) == 3
    img_lenna = rgb2gray(img_lenna);
    printf("   ✅ Lenna convertie en niveaux de gris\n");
endif

if size(img_cameraman, 3) == 3
    img_cameraman = rgb2gray(img_cameraman);
    printf("   ✅ Cameraman converti en niveaux de gris\n");
endif

% Redimensionner pour avoir des images de même taille
img_lenna = imresize(img_lenna, [256 256]);
img_cameraman = imresize(img_cameraman, [256 256]);

%% 3. Ajout de bruit
printf("\n3. Ajout de bruit aux images...\n");

% Bruit gaussien
bruit_gaussien = 25 * randn(256, 256);
img_lenna_bruitee = double(img_lenna) + bruit_gaussien;
img_lenna_bruitee = uint8(max(0, min(255, img_lenna_bruitee)));

bruit_cameraman = 20 * randn(256, 256);
img_cameraman_bruite = double(img_cameraman) + bruit_cameraman;
img_cameraman_bruite = uint8(max(0, min(255, img_cameraman_bruite)));

printf("   ✅ Bruit gaussien ajouté\n");

% Bruit poivre et sel (pour les tests)
img_poivre_sel = img_lenna;
nb_pixels = numel(img_lenna);
nb_bruit = round(nb_pixels * 0.05);
indices = randperm(nb_pixels, nb_bruit);
moitie = round(nb_bruit/2);
img_poivre_sel(indices(1:moitie)) = 0;
img_poivre_sel(indices(moitie+1:end)) = 255;
printf("   ✅ Bruit poivre et sel ajouté (pour tests)\n");

%% 4. Affichage des images originales (SANS colorbar dans imhist)
figure(1);
set(gcf, 'Name', 'Images Originales', 'Position', [100, 100, 1400, 600]);

subplot(2, 3, 1);
imshow(img_lenna);
title('Image Lenna Originale', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 3, 2);
imshow(img_cameraman);
title('Image Cameraman Originale', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 3, 3);
imshow(img_lenna_bruitee);
title('Lenna avec Bruit Gaussien', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 3, 4);
imshow(img_cameraman_bruite);
title('Cameraman avec Bruit', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 3, 5);
hist(img_lenna(:), 50);  % Utiliser hist() au lieu de imhist() avec colorbar
title('Histogramme Lenna', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Niveaux de gris');
ylabel('Fréquence');
xlim([0 255]);
grid on;

subplot(2, 3, 6);
hist(img_cameraman(:), 50);  % Utiliser hist() au lieu de imhist() avec colorbar
title('Histogramme Cameraman', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Niveaux de gris');
ylabel('Fréquence');
xlim([0 255]);
grid on;

%% 5. FILTRAGE PASSE-BAS (Moyenneur)
printf("\n4. Application des filtres moyenneurs...\n");

h3 = fspecial('average', 3);
h5 = fspecial('average', 5);
h7 = fspecial('average', 7);

img_moy3 = imfilter(double(img_lenna_bruitee), h3, 'replicate');
img_moy5 = imfilter(double(img_lenna_bruitee), h5, 'replicate');
img_moy7 = imfilter(double(img_lenna_bruitee), h7, 'replicate');

img_moy3 = uint8(img_moy3);
img_moy5 = uint8(img_moy5);
img_moy7 = uint8(img_moy7);

printf("   ✅ Filtres moyenneurs: 3x3, 5x5, 7x7\n");

%% 6. FILTRAGE GAUSSIEN
printf("\n5. Application des filtres gaussiens...\n");

hg1 = fspecial('gaussian', 5, 1);
hg2 = fspecial('gaussian', 5, 2);
hg3 = fspecial('gaussian', 7, 3);

img_gauss1 = imfilter(double(img_lenna_bruitee), hg1, 'replicate');
img_gauss2 = imfilter(double(img_lenna_bruitee), hg2, 'replicate');
img_gauss3 = imfilter(double(img_lenna_bruitee), hg3, 'replicate');

img_gauss1 = uint8(img_gauss1);
img_gauss2 = uint8(img_gauss2);
img_gauss3 = uint8(img_gauss3);

printf("   ✅ Filtres gaussiens: σ=1,2,3\n");

%% 7. FILTRAGE MÉDIAN
printf("\n6. Application des filtres médians...\n");

img_median3 = medfilt2(img_poivre_sel, [3 3]);
img_median5 = medfilt2(img_poivre_sel, [5 5]);

printf("   ✅ Filtres médians: 3x3, 5x5\n");

%% 8. DÉTECTION DE CONTOURS
printf("\n7. Application des détecteurs de contours...\n");

% Sobel
sobel_x = fspecial('sobel');
img_sobel_x = imfilter(double(img_lenna), sobel_x, 'replicate');
img_sobel_y = imfilter(double(img_lenna), sobel_x', 'replicate');
img_sobel = sqrt(img_sobel_x.^2 + img_sobel_y.^2);
img_sobel = uint8(img_sobel / max(img_sobel(:)) * 255);

% Prewitt
prewitt_x = fspecial('prewitt');
img_prewitt_x = imfilter(double(img_lenna), prewitt_x, 'replicate');
img_prewitt_y = imfilter(double(img_lenna), prewitt_x', 'replicate');
img_prewitt = sqrt(img_prewitt_x.^2 + img_prewitt_y.^2);
img_prewitt = uint8(img_prewitt / max(img_prewitt(:)) * 255);

% Laplacien
laplacien = fspecial('laplacian', 0.2);
img_laplacien = imfilter(double(img_lenna), laplacien, 'replicate');
img_laplacien = uint8(abs(img_laplacien));
img_laplacien = uint8(img_laplacien / max(img_laplacien(:)) * 255);

printf("   ✅ Détecteurs: Sobel, Prewitt, Laplacien\n");

%% 9. FIGURE 2: Résultats des filtres passe-bas
figure(2);
set(gcf, 'Name', 'Filtres Passe-Bas', 'Position', [50, 50, 1600, 800]);

subplot(2, 4, 1);
imshow(img_lenna);
title('Originale', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 2);
imshow(img_lenna_bruitee);
title('Bruitée', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 3);
imshow(img_moy3);
title('Moyenneur 3x3', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 4);
imshow(img_moy5);
title('Moyenneur 5x5', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 5);
imshow(img_moy7);
title('Moyenneur 7x7', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 6);
imshow(img_gauss2);
title('Gaussien σ=2', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 7);
imshow(img_median3);
title('Médian 3x3', 'FontSize', 12, 'FontWeight', 'bold');

subplot(2, 4, 8);
imshow(img_median5);
title('Médian 5x5', 'FontSize', 12, 'FontWeight', 'bold');

%% 10. FIGURE 3: Détection de contours
figure(3);
set(gcf, 'Name', 'Détection de Contours', 'Position', [50, 50, 1400, 500]);

subplot(1, 4, 1);
imshow(img_lenna);
title('Originale', 'FontSize', 12, 'FontWeight', 'bold');

subplot(1, 4, 2);
imshow(img_sobel);
title('Sobel', 'FontSize', 12, 'FontWeight', 'bold');

subplot(1, 4, 3);
imshow(img_prewitt);
title('Prewitt', 'FontSize', 12, 'FontWeight', 'bold');

subplot(1, 4, 4);
imshow(img_laplacien);
title('Laplacien', 'FontSize', 12, 'FontWeight', 'bold');

%% 11. ANALYSE FRÉQUENTIELLE
printf("\n8. Analyse fréquentielle...\n");

F = fft2(double(img_lenna));
F_shift = fftshift(F);
magnitude = log(abs(F_shift) + 1);

% Création de masques
[rows, cols] = size(img_lenna);
centre_x = floor(cols/2) + 1;
centre_y = floor(rows/2) + 1;
[X, Y] = meshgrid(1:cols, 1:rows);
dist = sqrt((X-centre_x).^2 + (Y-centre_y).^2);

% Passe-bas
sigma = 30;
masque_pb = exp(-dist.^2/(2*sigma^2));
F_pb = F_shift .* masque_pb;
img_pb = real(ifft2(ifftshift(F_pb)));
img_pb = uint8(max(0, min(255, img_pb)));

% Passe-haut
masque_ph = 1 - masque_pb;
F_ph = F_shift .* masque_ph;
img_ph = real(ifft2(ifftshift(F_ph)));
img_ph = uint8(max(0, min(255, abs(img_ph)*2)));

printf("   ✅ FFT et filtrage fréquentiel effectués\n");

%% 12. FIGURE 4: Analyse fréquentielle
figure(4);
set(gcf, 'Name', 'Analyse Fréquentielle', 'Position', [50, 50, 1400, 500]);

subplot(1, 4, 1);
imshow(img_lenna);
title('Image originale', 'FontSize', 12, 'FontWeight', 'bold');

subplot(1, 4, 2);
imshow(magnitude, []);
title('Spectre de magnitude', 'FontSize', 12, 'FontWeight', 'bold');
% Pas de colorbar pour éviter l'erreur

subplot(1, 4, 3);
imshow(img_pb);
title('Passe-bas', 'FontSize', 12, 'FontWeight', 'bold');

subplot(1, 4, 4);
imshow(img_ph);
title('Passe-haut', 'FontSize', 12, 'FontWeight', 'bold');

%% 13. SAUVEGARDE DES RÉSULTATS
printf("\n9. Sauvegarde des résultats...\n");

dossier_resultats = fullfile(chemin_base, "resultats_tp_octave");
mkdir(dossier_resultats);
printf("   Dossier: %s\n", dossier_resultats);

% Sauvegarder les images
imwrite(img_lenna, fullfile(dossier_resultats, "00_lenna_originale.png"));
imwrite(img_lenna_bruitee, fullfile(dossier_resultats, "01_lenna_bruitee.png"));
imwrite(img_moy3, fullfile(dossier_resultats, "02_moyenneur_3x3.png"));
imwrite(img_moy5, fullfile(dossier_resultats, "03_moyenneur_5x5.png"));
imwrite(img_moy7, fullfile(dossier_resultats, "04_moyenneur_7x7.png"));
imwrite(img_gauss2, fullfile(dossier_resultats, "05_gaussien_sigma2.png"));
imwrite(img_median3, fullfile(dossier_resultats, "06_median_3x3.png"));
imwrite(img_median5, fullfile(dossier_resultats, "07_median_5x5.png"));
imwrite(img_sobel, fullfile(dossier_resultats, "08_sobel.png"));
imwrite(img_prewitt, fullfile(dossier_resultats, "09_prewitt.png"));
imwrite(img_laplacien, fullfile(dossier_resultats, "10_laplacien.png"));
imwrite(img_pb, fullfile(dossier_resultats, "11_passe_bas_freq.png"));
imwrite(img_ph, fullfile(dossier_resultats, "12_passe_haut_freq.png"));
imwrite(uint8(magnitude*255/max(magnitude(:))), fullfile(dossier_resultats, "13_spectre.png"));

% Sauvegarder les figures
saveas(figure(1), fullfile(dossier_resultats, "figure1_originales.png"));
saveas(figure(2), fullfile(dossier_resultats, "figure2_filtres_passe_bas.png"));
saveas(figure(3), fullfile(dossier_resultats, "figure3_detection_contours.png"));
saveas(figure(4), fullfile(dossier_resultats, "figure4_analyse_frequentielle.png"));

%% 14. Calcul du PSNR (optionnel)
printf("\n10. Calcul du PSNR...\n");

psnr_bruitee = calculer_psnr(double(img_lenna), double(img_lenna_bruitee));
psnr_moy5 = calculer_psnr(double(img_lenna), double(img_moy5));
psnr_gauss2 = calculer_psnr(double(img_lenna), double(img_gauss2));
psnr_median5 = calculer_psnr(double(img_lenna), double(img_median5));

printf("   PSNR - Image bruitée: %.2f dB\n", psnr_bruitee);
printf("   PSNR - Moyenneur 5x5: %.2f dB\n", psnr_moy5);
printf("   PSNR - Gaussien σ=2: %.2f dB\n", psnr_gauss2);
printf("   PSNR - Médian 5x5: %.2f dB\n", psnr_median5);

%% 15. RÉSUMÉ FINAL
printf("\n" + "="*60 + "\n");
printf("✅ TRAITEMENT TERMINÉ AVEC SUCCÈS!\n");
printf("="*60 + "\n");
printf("Images sauvegardées dans:\n");
printf("  %s\n", dossier_resultats);
printf("\nFichiers générés: 13 images filtrées + 4 figures\n");
printf("="*60 + "\n");

%% Fonction pour calculer le PSNR
function psnr_val = calculer_psnr(img1, img2)
    mse = mean((img1(:) - img2(:)).^2);
    if mse == 0
        psnr_val = Inf;
    else
        psnr_val = 10 * log10(255^2 / mse);
    endif
endfunction
