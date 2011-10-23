
cols = {'first', 'second', 'third'};
rows = {'A', 'B', 'Ces', 'D'};

data = rand(4,3);

create_table(data,'columnlabels',cols,'rowlabels',rows);

clear ans cols data rows
