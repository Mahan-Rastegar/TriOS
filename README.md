# TriOS

A research microkernel which aims to bring together efficiency with formal verification together.
Built around a small low-level Rust core.
C and assembly are used for bootstrapping and hardware-specific interfaces;
the kernel’s core logic is written in Rust. Formal verification is developed
in Lean 4, with Aeneas used to translate supported Rust code into Lean for proof.

Inspired by :

- https://www.redox-os.org/
- https://sel4.systems/
- https://sele4n.org/
- https://lean-lang.org/
