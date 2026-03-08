%% IMAGE PROCESSING - COMPLETE TP SCRIPT
%% GNU Octave - FIXED VERSION (no colorbar error)
%% TP2, TP3, TP5, TP6, TP7, TP8 - Image Quantification to 8 levels

% Clear workspace and load required packages
clear all;      % Clear all variables from memory
close all;      % Close all figure windows
clc;            % Clear command window
pkg load image; % Load image processing package

fprintf('=== IMAGE PROCESSING - PRACTICAL WORK ===\n\n');

%% 1. TP2: Opening and reading an image
fprintf('1. TP2: Opening and reading image...\n');

% IMPORTANT: Change this path to match YOUR image location
img = imread('/home/bmed/Documents/school/New Folder/lena.png');
% img = imread('lena.png'); % Use this if image is in current folder

fprintf('   ✓ Image loaded successfully\n\n');

% Display image information
fprintf('2. Image Information:\n');
img_size = size(img);
fprintf('   Image dimensions: %d x %d pixels\n', img_size(1), img_size(2));
if length(img_size) == 3
    fprintf('   Number of color channels: %d (RGB)\n', img_size(3));
end
fprintf('\n');

%% 2. TP3: RGB Histograms
fprintf('3. TP3: Creating RGB histograms...\n');

% Extract histograms for each channel
hr = imhist(img(:,:,1));  % Red channel histogram
hg = imhist(img(:,:,2));  % Green channel histogram
hb = imhist(img(:,:,3));  % Blue channel histogram

% Display RGB histograms
figure('Name', 'TP3 - RGB Histograms', 'Position', [100, 100, 800, 600]);
plot([hr, hg, hb], 'LineWidth', 1.5);
legend('Red', 'Green', 'Blue');
title('Histogram of RGB Channels');
xlabel('Intensity Value (0-255)');
ylabel('Frequency (Number of Pixels)');
grid on;
fprintf('   ✓ RGB histograms displayed\n\n');

%% 3. TP5: RGB Channel Separation
fprintf('4. TP5: Separating RGB channels...\n');

% Create copies for each channel
red_channel = img;
green_channel = img;
blue_channel = img;

% Zero out other channels to isolate each color
red_channel(:,:,[2 3]) = 0;     % Keep only red (kill green and blue)
green_channel(:,:,[1 3]) = 0;    % Keep only green (kill red and blue)
blue_channel(:,:,[1 2]) = 0;     % Keep only blue (kill red and green)

% Display channel separation
figure('Name', 'TP5 - RGB Channel Separation', 'Position', [100, 100, 1000, 800]);
subplot(2,2,1);
imshow(img);
title('Original RGB Image');

subplot(2,2,2);
imshow(red_channel);
title('Red Channel Only');

subplot(2,2,3);
imshow(green_channel);
title('Green Channel Only');

subplot(2,2,4);
imshow(blue_channel);
title('Blue Channel Only');
fprintf('   ✓ RGB channels separated and displayed\n\n');

%% 4. TP6: Grayscale Conversion
fprintf('5. TP6: Converting to grayscale...\n');

% Convert RGB to grayscale using luminance formula
% Gray = 0.2989*R + 0.5870*G + 0.1140*B
img_gray = rgb2gray(img);

% Display original vs grayscale
figure('Name', 'TP6 - Grayscale Conversion', 'Position', [100, 100, 1000, 400]);
subplot(1,2,1);
imshow(img);
title('Original RGB Image');

subplot(1,2,2);
imshow(img_gray);
title('Grayscale Image');
fprintf('   ✓ Image converted to grayscale\n');

% Display grayscale histogram - FIXED for Octave
figure('Name', 'TP6 - Grayscale Histogram', 'Position', [100, 100, 800, 600]);

% Manual histogram calculation to avoid colorbar error
[counts, bins] = imhist(img_gray);
bar(bins, counts, 'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'black');
title('Histogram of Grayscale Image');
xlabel('Intensity Value (0-255)');
ylabel('Frequency (Number of Pixels)');
xlim([0, 255]);
grid on;
fprintf('   ✓ Grayscale histogram displayed\n\n');

%% 5. TP7: Histogram Analysis
fprintf('6. TP7: Analyzing histogram statistics...\n');

% Calculate histogram statistics
[counts, bins] = imhist(img_gray);
min_intensity = find(counts>0, 1) - 1;
max_intensity = find(counts>0, 1, 'last') - 1;
[peak_freq, peak_idx] = max(counts);
most_frequent = peak_idx - 1;
mean_intensity = mean2(img_gray);
std_intensity = std2(img_gray);

% Display statistics
fprintf('\n   Histogram Statistics:\n');
fprintf('   - Minimum intensity: %d\n', min_intensity);
fprintf('   - Maximum intensity: %d\n', max_intensity);
fprintf('   - Most frequent value: %d (frequency: %d)\n', most_frequent, peak_freq);
fprintf('   - Mean intensity: %.2f\n', mean_intensity);
fprintf('   - Standard deviation: %.2f\n\n', std_intensity);

% Show histogram with statistics
figure('Name', 'TP7 - Histogram Analysis', 'Position', [100, 100, 800, 600]);
bar(bins, counts, 'FaceColor', [0.5, 0.5, 0.8], 'EdgeColor', 'blue');
title('Grayscale Histogram with Statistics');
xlabel('Intensity Value (0-255)');
ylabel('Frequency');
xlim([0, 255]);
grid on;

% Add text with statistics on the graph
text(180, max(counts)*0.8, sprintf('Mean: %.1f', mean_intensity), 'FontSize', 10);
text(180, max(counts)*0.7, sprintf('Std Dev: %.1f', std_intensity), 'FontSize', 10);
text(180, max(counts)*0.6, sprintf('Most frequent: %d', most_frequent), 'FontSize', 10);

%% 6. TP8: IMAGE QUANTIZATION TO 8 LEVELS ★ THIS IS WHAT YOU NEED ★
fprintf('7. TP8: Quantizing image to 8 gray levels...\n');

N = 8;  % Number of quantization levels (8 levels as requested)

% QUANTIZATION PROCESS - Step by step:
% 1. Convert to double for calculations: double(img_gray)
% 2. Normalize to 0-1 range: /256
% 3. Scale to 0-(N-1) range: * (N-1)
% 4. Round to nearest integer: round()
% 5. Scale back to 0-255 range: * (256/(N-1))
% 6. Convert back to uint8 for display: uint8()

img_quantized = round(double(img_gray) / 256 * (N-1)) * (256/(N-1));
img_quantized = uint8(img_quantized);

% Display original vs quantized image
figure('Name', 'TP8 - Image Quantization (8 levels)', 'Position', [100, 100, 1000, 400]);
subplot(1,2,1);
imshow(img_gray);
title(sprintf('Original Grayscale\n(256 levels)'));

subplot(1,2,2);
imshow(img_quantized);
title(sprintf('Quantized Image\n(%d levels)', N));
fprintf('   ✓ Quantization to %d levels complete\n', N);

% Display histograms comparison - FIXED for Octave
figure('Name', 'TP8 - Histogram Comparison', 'Position', [100, 100, 800, 800]);

subplot(2,1,1);
[counts_orig, bins_orig] = imhist(img_gray);
bar(bins_orig, counts_orig, 'FaceColor', [0.3, 0.3, 0.8], 'EdgeColor', 'blue');
title(sprintf('Original Histogram (256 levels)\nUnique values: %d', length(unique(img_gray))));
xlabel('Intensity');
ylabel('Frequency');
xlim([0, 255]);
grid on;

subplot(2,1,2);
[counts_quant, bins_quant] = imhist(img_quantized);
bar(bins_quant, counts_quant, 'FaceColor', [0.8, 0.3, 0.3], 'EdgeColor', 'red');
title(sprintf('Quantized Histogram (%d levels)\nUnique values: %d', N, length(unique(img_quantized))));
xlabel('Intensity');
ylabel('Frequency');
xlim([0, 255]);
grid on;
fprintf('   ✓ Histogram comparison displayed\n\n');

%% 7. Verification of Quantization
fprintf('=== QUANTIZATION VERIFICATION ===\n');
original_levels = length(unique(img_gray));
quantized_levels = length(unique(img_quantized));

fprintf('Original image: %d unique gray levels\n', original_levels);
fprintf('Quantized image: %d unique gray levels\n', quantized_levels);

if quantized_levels <= N
    fprintf('✓ SUCCESS: Image successfully quantized to %d levels or less\n', N);
    fprintf('  Actual number of levels used: %d\n', quantized_levels);
else
    fprintf('✗ ERROR: Quantization failed - image still has %d levels\n', quantized_levels);
end

% Display the actual values present in the quantized image
fprintf('\nGray levels present in quantized image:\n');
quantized_values = unique(img_quantized)';
fprintf('  [ ');
for val = quantized_values
    fprintf('%d ', val);
end
fprintf(']\n\n');

%% 8. Show the quantized image with its actual values
figure('Name', 'TP8 - Quantized Image Analysis', 'Position', [100, 100, 1200, 400]);

subplot(1,3,1);
imshow(img_quantized);
title(sprintf('Quantized Image (%d levels)', N));

subplot(1,3,2);
% Create a colorbar manually
image(reshape(quantized_values, [1, length(quantized_values), 1]));
colormap(gray(length(quantized_values)));
title('Gray Levels Used');
set(gca, 'XTick', 1:length(quantized_values));
set(gca, 'XTickLabel', cellstr(num2str(quantized_values')));
xlabel('Level Value');

subplot(1,3,3);
% Show distribution
[counts_quant, bins_quant] = imhist(img_quantized);
bar(bins_quant, counts_quant, 'FaceColor', 'k');
title('Distribution');
xlabel('Intensity');
ylabel('Frequency');
xlim([0, 255]);
grid on;

%% 9. Bonus: Show the effect of different quantization levels
fprintf('8. BONUS: Comparing different quantization levels...\n');

levels_to_test = [2, 4, 8, 16, 32, 64, 128];
figure('Name', 'Bonus - Quantization Comparison', 'Position', [100, 100, 1200, 600]);

for i = 1:length(levels_to_test)
    k = levels_to_test(i);
    img_test = round(double(img_gray) / 256 * (k-1)) * (256/(k-1));
    img_test = uint8(img_test);

    subplot(2,4,i);
    imshow(img_test);
    title(sprintf('%d levels', k));

    if k == 8  % Highlight the 8-level result
        xlabel('★ TP8 RESULT ★', 'Color', 'red', 'FontWeight', 'bold');
    end
end

% Add original for comparison
subplot(2,4,8);
imshow(img_gray);
title('Original (256 levels)');

fprintf('   ✓ Comparison complete - Look for figure "Bonus - Quantization Comparison"\n');
fprintf('     The subplot with 8 levels is your TP8 result\n\n');

%% Summary
fprintf('=== SUMMARY ===\n');
fprintf('All TP exercises completed successfully:\n');
fprintf('✓ TP2: Image loaded\n');
fprintf('✓ TP3: RGB histograms\n');
fprintf('✓ TP5: Channel separation\n');
fprintf('✓ TP6: Grayscale conversion\n');
fprintf('✓ TP7: Histogram analysis\n');
fprintf('✓ TP8: Quantization to 8 levels ★ MAIN RESULT ★\n\n');

fprintf('Total figures created: 8\n');
fprintf('Look for these figures:\n');
fprintf('- Figure 1: TP3 - RGB Histograms\n');
fprintf('- Figure 2: TP5 - RGB Channel Separation\n');
fprintf('- Figure 3: TP6 - Grayscale Conversion\n');
fprintf('- Figure 4: TP6 - Grayscale Histogram (fixed bar chart)\n');
fprintf('- Figure 5: TP7 - Histogram Analysis\n');
fprintf('- Figure 6: TP8 - Image Quantization (8 levels) ★\n');
fprintf('- Figure 7: TP8 - Histogram Comparison ★\n');
fprintf('- Figure 8: TP8 - Quantized Image Analysis ★\n');
fprintf('- Figure 9: Bonus - Quantization Comparison ★\n\n');

fprintf('The 8-level quantization result is in Figures 6, 7, and 8!\n');
