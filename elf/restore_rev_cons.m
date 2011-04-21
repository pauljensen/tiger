function [elf] = restore_rev_cons(elf)

[~,locs] = find_like('^ELF_REV_CON$',elf.rownames);
elf.A(locs,:) = elf.rev_cons.A;
elf.b(locs) = elf.rev_cons.b;
