/// Cast void to memset to ignore its return value
///
/// The return of memset_s and memcpy_s is never checked and therefore
/// cast it to void to explicitly ignore while adhering to MISRA-C.
//
// Confidence: High
// Copyright (c) 2017 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

virtual patch

@depends on patch && !(file in "third_party")@
expression e1,e2,e3;
@@
(
+ (void)
memset_s(e1,e2,e3);
|
+ (void)
memcpy_s(e1,e2,e3);
)
