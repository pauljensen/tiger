function [elf] = restore_rev_cons(elf)
% RESTORE_REV_CONS  Restore reversibility constraints in an ELF model

[~,locs] = find_like('^ELF_REV_CON',elf.rownames);
elf.A(locs,:) = elf.rev_cons.A;
elf.b(locs) = elf.rev_cons.b;
