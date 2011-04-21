function [elf] = remove_rev_cons(elf)

[~,locs] = find_like('^ELF_REV_CON$',elf.rownames);
elf.rev_cons.A = elf.A(locs,:);
elf.rev_cons.b = elf.b(locs);

elf.A(locs,:) = 0;
elf.b(locs) = 0;
