function test_tiger()
% TEST_TIGER  Run unit tests on the TIGER package
%
%   Before running this function, move to the TIGER/test/unit directory.
%   Unit tests are located in TIGER/test/unit/tests.

home;
fprintf('\nTIGER unit testing:\n\n');

PREFIX = 'test__';

files = dir('tests');
to_run = {};
for f = 1 : length(files)
    if length(files(f).name) > length(PREFIX) ...
        && strcmp(files(f).name(1:length(PREFIX)),PREFIX) ...
        && strcmp(files(f).name(end-1:end),'.m')
        to_run{end+1} = files(f).name(1:end-2);
    end
end

error_count = 0;
error_messages = {};

cd('tests');
for file = 1 : length(to_run)
    prev_error_count = error_count;
    try
        eval(to_run{file});
    catch ME
        error_count = error_count + 1;
        error_messages{end+1} = ME.message;
    end
    Nerror = error_count - prev_error_count;
    if Nerror == 0
        show_padded(['Running ' to_run{file} '.m'],'ok');
    else
        show_padded(['Running ' to_run{file} '.m'],'FAIL');
        disp('   Error(s):');
        for errorj = prev_error_count+1 : error_count
            disp(['      ',error_messages{errorj}]);
        end
    end
end
cd('..');

if error_count == 0
    fprintf('\nTesting completed with no errors.\n\n');
else
    fprintf('\nTesting FAILED with %i error(s).\n\n',error_count);
end

