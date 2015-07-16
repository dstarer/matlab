function [output] = imageSet(rootdir)
% get all the subfolders
subfolders = dir(rootdir);
sub_length = length(subfolders);
sub_path = cell(sub_length-2, 1);
output.Count = sub_length - 2;

k = 1;
for i = 1: sub_length
    if strcmp(subfolders(i).name,'.') == 0 && strcmp(subfolders(i).name, '..')==0 && subfolders(i).isdir
        sub_path{k} = fullfile(rootdir, subfolders(i).name);
        k = k + 1;
    end
end

end
