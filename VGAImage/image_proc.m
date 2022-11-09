function image_proc(filename)
    filename = "avatar.jpg";
    rgb = imread(filename);
    figure;
    imshow(rgb);
    title("Original Image");
    rgb = imresize(rgb, [480 640]);
    figure;
    imshow(rgb);
    title("Scaled Image");
    [ind, map] = rgb2ind(rgb, 256);
    figure;
    imagesc(ind);
    colormap(map);
    title("Scaled 8 bits Image");
    fprintf(1, "Generating intel-hex data files...\n");
    fid = fopen("image_index.mif", "w");
    for row = 1:size(ind, 1)
        for col = 1:size(ind, 2)
            fprintf(fid, "%02x\n", ind(row, col));
        end
    end
    fclose(fid);
    fid = fopen("image_map.mif", "w");
    map = uint8(map*255);
    for i = 1:size(map, 1)
        fprintf(fid, "%02x%02x%02x\n", map(i, 1), map(i, 2), map(i, 3));
    end
    fclose(fid);
    disp("finished.");
end