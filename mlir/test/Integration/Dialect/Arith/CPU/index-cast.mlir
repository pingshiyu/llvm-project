// RUN: mlir-opt %s --convert-arith-to-llvm="index-bitwidth=64" --convert-vector-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | \
// RUN:   mlir-cpu-runner -e entry -entry-point-result=void \
// RUN:                   --shared-libs=%mlir_c_runner_utils | \
// RUN:   FileCheck %s --match-full-lines

func.func @index_cast_i32_index(%v1 : i32) {
    vector.print str "@index_cast_i32_index\n"
    %res = arith.index_cast %v1 : i32 to index
    vector.print %res : index
    return
}

func.func @index_castui_i32_index(%v1 : i32) {
    vector.print str "@index_castui_i32_index\n"
    %res = arith.index_castui %v1 : i32 to index
    vector.print %res : index
    return
}

func.func @index_castui_index_i3(%v1 : index) {
    vector.print str "@index_castui_index_i3\n"
    %res = arith.index_cast %v1 : index to i3
    vector.print %res : i3
    return
}

func.func @index_cast_index_i12(%v1 : index) {
    vector.print str "@index_cast_index_i12\n"
    %res = arith.index_cast %v1 : index to i12
    vector.print %res : i12
    return
}

func.func @index_cast_i64_index(%v1 : i64) {
    vector.print str "@index_cast_i64_index\n"
    %res = arith.index_cast %v1 : i64 to index
    vector.print %res : index
    return
}

func.func @index_cast() {
    // ------------------------------------------------
    // Test casting from i32
    // ------------------------------------------------
    %n1 = arith.constant -1 : i32
    %p1 = arith.constant 1 : i32

    // index casting of -1 : i32 -> 2^64 - 1
    // index_cast(-1 : i32) = 2^64 - 1;
    // CHECK-LABEL: @index_cast_i32_index
    // CHECK-NEXT:  18446744073709551615
    func.call @index_cast_i32_index(%n1) : (i32) -> ()

    // index should be represented as unsigned ints, and order is preserved by conversion:
    // index_cast(x) `slt` index_cast(y) == x `slt` y
    // CHECK-LABEL: @index_cast_i32_index
    // CHECK-NEXT:  1
    func.call @index_cast_i32_index(%p1) : (i32) -> ()

    // ------------------------------------------------
    // Test casting from index
    // ------------------------------------------------
    // index_cast casting down truncates bits
    // index_cast -3762 = 334 : i12
    %c3762 = arith.constant -3762 : index
    // CHECK-LABEL: @index_cast_index_i12
    // CHECK-NEXT:  334
    func.call @index_cast_index_i12(%c3762) : (index) -> ()

    // ------------------------------------------------
    // TODO: cast index <-> other types, e.g. i64, i16 etc
    // ------------------------------------------------
    return
}

func.func @index_castui() {
    // ------------------------------------------------
    // Test casting from i32
    // ------------------------------------------------
    %n1 = arith.constant -1 : i32

    // index_castui(-1 : i32) to index = 2^32 - 1
    // CHECK-LABEL: @index_castui_i32_index
    // CHECK-NEXT:  4294967295
    func.call @index_castui_i32_index(%n1) : (i32) -> ()

    // ------------------------------------------------
    // Test casting from index
    // ------------------------------------------------
    // index_castui casting down truncates bits
    // index_castui (32 + 1) = 1 : i3
    %p33 = arith.constant 33 : index
    // CHECK-LABEL: @index_castui_index_i3
    // CHECK-NEXT: 1
    func.call @index_castui_index_i3(%p33) : (index) -> ()

    // ------------------------------------------------
    // TODO: castui index <-> other types, e.g. i64, i16 etc
    // ------------------------------------------------
    return
}

func.func @entry() {
    func.call @index_cast() : () -> ()
    func.call @index_castui() : () -> ()
    return
}
